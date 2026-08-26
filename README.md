# RISC-V Emulator in x86-64 Assembly

An emulator for the RISC-V architecture (RV32I + M) written entirely in x86-64
assembly with NASM, with no libraries: it issues Linux syscalls directly and
starts at `_start` rather than `main`.

It runs machine code produced by RARS from hexadecimal memory dumps, renders
video to the text console, and captures keyboard input through memory-mapped
I/O. Two full games — a Pong and a Bomberman, written independently of this
emulator — run identically here and in RARS.

## Building and running

```bash
make              # build
make pong         # run the Pong
make bomberman    # run the Bomberman
make pong-traza   # run the Pong and write traza.txt
make test         # both test suites, assembled with rvasm
make test-rars    # the same suites, from RARS-produced dumps
make doc-check    # verify every path cited in the READMEs exists
make limpiar      # remove generated files
```

To run any other program, pass the two dumps as arguments:

```bash
./emulador -q programs/bomberman/punto_text_hex.txt \
              programs/bomberman/punto_data_hex.txt
```

### Options

```
./emulador [-q] [-t file] [text_dump [data_dump]]
```

| Invocation | Trace | Video | Guest program output |
|---|---|---|---|
| `./emulador` | stdout | stderr | stdout |
| `./emulador -q` | not generated | stderr | stdout |
| `./emulador -t file` | file | stderr | stdout |

There are three output streams but only two standard descriptors, which is why
`-t` exists: it gives the trace its own descriptor and keeps all three separate.
If the `open` fails, the trace falls back to stdout instead of aborting.

Both dump paths default to `punto_text_hex.txt` and `punto_data_hex.txt` in the
current directory when omitted.

## Repository layout

```
src/        emulador.asm — the emulator itself
tools/      rvasm.py — minimal RV32I/M assembler, for iterating without RARS
tests/      self-checking test programs
programs/   guest programs, each with its source and dumps
```

## Input files

Two hexadecimal dumps, one word per line. Generate them from RARS via
`File → Dump Memory`, format *Hexadecimal Text*, dumping each segment
separately.

The loader reads the whole file and then parses it, accepting upper or lower
case, LF or CRLF line endings, arbitrary whitespace, and a missing final
newline. If a dump exceeds the array that holds it, the emulator says so on
stderr rather than silently discarding the remainder.

---

## Architecture

The emulator is a straightforward interpreter: a fetch-decode-execute loop over
an array of instruction words, with all guest state held in host memory. There
is no JIT, no basic-block caching, and no instruction pre-decoding — each
instruction is decoded from scratch every time it executes. For targets that
spend most of their time asleep between animation frames, that simplicity costs
nothing and keeps the code readable.

### Guest state

All emulated state lives in `.bss`, which the kernel zeroes at load time. That
zeroing is load-bearing in one specific case: `x0` is hardwired to zero in
RISC-V, and it stays zero here because the array starts at zero and `write_reg`
refuses to write index 0.

| Symbol | Size | Holds |
|---|---|---|
| `registers` | 33 words | `x0`–`x31` plus the PC at index 32 |
| `text_memory` | 16384 words | the `.text` segment |
| `data_memory` | 8192 words | the `.data` segment |
| `framebuffer` | 8192 words | video memory |
| `stack_mem` | 4096 words | the guest stack |
| `key_status`, `key_data` | 1 word each | the two MMIO registers |

Keeping the PC inside the register array rather than in a separate variable
means the whole machine state is one contiguous block, which is what makes the
register dump a simple loop.

### Execution cycle

```
_start
  ├── parse arguments (-q, -t, dump paths)
  ├── read_text_file  →  text_memory
  ├── read_data_file  →  data_memory
  ├── initialise sp, gp, pc
  ├── term_init       →  raw mode
  └── main_loop
        ├── fetch: (pc − 0x400000) / 4  →  index into text_memory
        ├── print_trace  →  disasm
        ├── pc += 4                     (jumps overwrite it)
        └── decode_instruction  →  handler  →  write_reg / mem_write
```

The PC is incremented **before** the instruction executes, and jumps overwrite
it. This is the single most important structural decision in the emulator, and
it has a consequence that is easy to get wrong: `auipc`, `jal`, `jalr` and the
branches all compute their result relative to the address of the instruction
*itself*, not the next one. They therefore read `r12d`, which holds the
pre-increment PC, rather than `registers[32]`. Computing from the incremented
value would shift every one of those results by four bytes — and because the
guests use `auipc` for nearly every data access, the damage would be widespread
and hard to localise.

The alternative design — leaving the PC alone and adding four only when the
instruction did not modify it — was rejected because it cannot represent a jump
to the current address. The Pong's final instruction is `j 0`, an infinite
self-loop marking the end of the program; under that scheme it would fall
through instead of halting.

The PC is checked for 4-byte alignment on every fetch. Without that check a
jump to an odd address would be silently rounded down by the index arithmetic,
hiding the bug — a gap that mutation testing exposed.

### Register conventions on the host side

The emulator is written in flat assembly with no external ABI to honour, so it
defines its own conventions. Holding them consistently is what keeps the code
from turning into a register-shuffling mess.

| Register | Role |
|---|---|
| `edx` | current instruction word, passed to `decode_instruction` |
| `r12d` | PC of the instruction being executed (pre-increment) |
| `r13d` | current instruction word, preserved across calls |
| `rbx` | base of `registers`, reloaded where needed |
| `r10d`, `r11d` | scratch inside the memory routines |
| `rdi` | write cursor in every buffer emitter |

Two small calling conventions carry most of the traffic. `read_reg` takes a
register index in `ecx` and returns its value in `eax`; `write_reg` takes the
index in `ecx` and the value in `eax`, and silently drops writes to `x0`.
Routing every register write through one place is what makes the `x0` guarantee
a single line of code instead of a rule to remember at forty call sites.

The second convention governs text output: **every emitter writes at `[rdi]` and
leaves `rdi` pointing just past what it wrote**. `put_hex8`, `emit_dec8`,
`e_reg`, `e_coma`, `e_dec` and `e_str` all obey it, so a formatted line is built
by calling them in sequence and the final length is simply how far the pointer
moved. No emitter needs to know or return a length.

One hazard deserves naming, because it produced the nastiest bug in the
project: **`syscall` destroys `rcx` and `r11`, and `div` writes its remainder
into `rdx`** — which is where the current instruction lives. `decode_csr`
originally extracted its destination register after calling the clock routine,
so `rdtime` wrote into whichever register the leftover nanoseconds happened to
name. It failed roughly one run in six. The destination is now extracted first
and pushed to the stack.

### Memory subsystem

Guest addresses span from `0x00400000` to `0xFFFF0004` — a 4 GB space of which
only a few windows actually exist. `mem_read` and `mem_write` are the address
decoder: they walk the regions in order, and on a match subtract the region base
and divide by four to get an index into the corresponding host array. It is the
same arithmetic the instruction fetch performs, generalised from one region to
five.

Range comparisons use **unsigned** branches (`jb`/`jae`). With signed
comparisons `0xFFFF0000` would be a negative number and the MMIO region would
never fall inside any range.

Byte and half-word accesses sit on top of the word-granular core. Reads fetch
the containing word and shift; writes are read-modify-write, so the other bytes
of the word survive. The shift amount is the low bits of the address times
eight, which assumes the host is little-endian like RISC-V — true on x86.

### Instruction decode

`decode_instruction` masks off the low seven bits and dispatches through a chain
of comparisons to a per-format decoder, which extracts its fields into shared
variables (`rd`, `rs1`, `rs2`, `funct3`, `funct7`, `imm`) and then dispatches
again on `funct3` to the actual operation. Opcode `0x33` dispatches on `funct7`
first, since `0x01` there selects the M extension rather than the base ALU.

The immediate formats are where most of the subtlety lives:

- **I-type** immediates fall out of a single `sar ecx, 20`. An *arithmetic*
  shift moves the field into the low bits and replicates bit 31 upward in the
  same instruction, so sign extension is free. Using `shr` instead would turn
  every negative offset into a large positive one.
- **S-type** immediates arrive split in two pieces, `instr[31:25]` and
  `instr[11:7]`.
- **B-type** immediates are the most fragmented in the ISA: four
  non-contiguous pieces covering thirteen bits using only twelve encoded bits,
  because bit 0 is always zero. Sign extension is `shl 19` / `sar 19`.
- **U-type** immediates need no extension; the field is already positioned.
- **J-type** immediates are reassembled from four pieces and sign-extended with
  `shl 11` / `sar 11`.

Signedness distinctions are not cosmetic. `slt` uses `setl` while `sltu` uses
`setb`; `blt` uses `jl` while `bltu` uses `jb`. Confusing them produces code
that works for small values and fails only once an operand crosses bit 31.

`jalr` computes its target *before* writing the link register, because
`jalr ra, ra, 0` uses the same register for both and writing first would destroy
the destination.

### Division

The M extension's divides cannot be handed straight to `idiv`. On x86, dividing
by zero or overflowing `INT_MIN / -1` raises a hardware exception that would
kill the process — exactly what must never happen here. RISC-V instead defines
concrete results and raises nothing:

| Case | `div` | `rem` | `divu` | `remu` |
|---|---|---|---|---|
| divisor is zero | all ones | the dividend | all ones | the dividend |
| `INT_MIN / -1` | `INT_MIN` | 0 | — | — |

All four cases are intercepted before the division instruction is reached.

### Video pipeline

RARS presents a 64×32 grid of display units. The renderer draws it with the
upper-half-block character `▀`: the foreground colour is the pixel above and the
background colour the pixel below, so the grid fits in 64×16 terminal cells and
keeps its proportions. Drawing one cell per pixel would double the height and
distort the image, because terminal cells are taller than they are wide.

Two decisions keep it fast enough to look smooth:

- **Colour codes are emitted only when the colour changes** from the previous
  cell. A frame costs about 9,700 bytes instead of the roughly 42,000 it would
  take to emit both codes for all 1,024 cells. On a mostly-black board, most
  cells inherit.
- **Repainting happens at `ecall`** — the natural frame boundary, since the
  guest draws and then sleeps — and only when the `fb_dirty` flag says a store
  landed in the framebuffer. Repainting on every store would mean nearly 3,000
  redraws per frame.

The dirty flag has a second effect that matters for generality: text-only
programs never touch the framebuffer, so the flag never rises and the renderer
never runs. Their output is not polluted by escape codes.

The framebuffer *region* is larger than the visible grid, spanning `0x10008000`
to just below `.data`. In RARS the data segment covers that whole range, so a
program that draws one row past the bottom of the screen writes to valid memory
and simply sees nothing. An emulator that aborted there would be stricter than
the system it emulates, which is its own kind of bug — the Bomberman does
exactly this.

The whole frame is assembled in one buffer and issued as a single `write`, and
the cursor is homed with `ESC[H` rather than clearing the screen, which is what
avoids flicker.

### Input pipeline

The guest polls `0xFFFF0000` for a pending key and reads it from `0xFFFF0004`.
`poll_key` hooks into the MMIO path of `mem_read`, which is exactly the moment
the guest asks — no polling loop of its own is needed.

The terminal is put in raw mode by clearing three `c_lflag` bits: `ICANON` so
bytes arrive without waiting for Enter, `ECHO` so keystrokes are not painted
over the board, and `ISIG` so Ctrl+C arrives as byte `0x03` instead of a signal.
Clearing `ISIG` is deliberate — it lets the emulator handle the interrupt itself
and restore the terminal before exiting. With `ISIG` left on, the process would
die instantly and leave the terminal in raw mode with echo off, forcing the user
to type `reset` blind.

`VMIN` and `VTIME` are both zero and `stdin` is additionally marked
`O_NONBLOCK`, so `read` returns immediately whether or not input is waiting.
The `O_NONBLOCK` is redundant for a raw terminal but essential when input comes
from a pipe, where the emulator would otherwise freeze. The original terminal
settings are restored on every exit path.

### Trace subsystem

The disassembler is deliberately **independent of execution**. It has its own
immediate extractors (`imm_uj`, `imm_b`, `imm_s`) and its own field variables
(`d_rd`, `d_rs1`, …) rather than sharing the ones the handlers use. Reading an
instruction must not disturb any state — if the two shared variables, the trace
could corrupt execution or vice versa, and a debugging tool that changes the
behaviour it observes is worse than none.

Each trace line is written with a direct `write`, without an intermediate
buffer. That costs syscalls, but it means nothing is lost even if the process
dies abruptly — which is precisely when the last few lines matter most.

### Error handling

Every failure path prints a diagnosable message and exits cleanly. There is no
path that produces a segmentation fault.

| Condition | Response |
|---|---|
| Input file missing | message, exit 3 |
| Dump larger than its array | warning on stderr, execution continues |
| Unimplemented opcode | PC, instruction, register dump, exit 2 |
| Unmapped or misaligned address | address, PC, register dump, exit 4 |
| Misaligned PC | same as above |
| Write into `.text` | treated as an invalid access |
| Unimplemented syscall or CSR | the offending value, register dump, exit 5 |

Writing into `.text` is rejected on purpose. RISC-V permits self-modifying code,
but in practice a store into program memory is almost always a stray pointer,
and it is far better to see it immediately than to corrupt an instruction that
has not executed yet and watch the symptom appear a thousand instructions later
somewhere unrelated. Enabling it is a one-line change.

The same reasoning motivates the alignment checks. In an emulator you are
debugging two programs at once — the host in x86 and the guest in RISC-V — and
without these guardrails there is no way to tell which one is at fault.

### Routine map

| Routine | Purpose |
|---|---|
| `main_loop` | fetch-decode-execute cycle |
| `decode_instruction` | opcode dispatch |
| `decode_u` / `decode_uj` / `decode_r` | U, J and R format decode and execute |
| `decode_i_load` / `decode_i_alu` | I format, loads and arithmetic |
| `decode_s` / `decode_b` / `decode_jalr` | stores, branches, indirect jump |
| `decode_ecall` / `decode_csr` | syscalls and counter reads |
| `mem_read` / `mem_write` | word access, address decode |
| `mem_read_byte` / `mem_read_half` | sub-word reads |
| `mem_write_byte` / `mem_write_half` | sub-word read-modify-write |
| `read_reg` / `write_reg` | register file access, `x0` guard |
| `render_frame` | framebuffer to ANSI |
| `poll_key` / `term_init` / `term_restore` | keyboard and terminal state |
| `disasm` | instruction to text |
| `put_hex8` / `put_dec` / `emit_dec8` / `e_dec` | number formatting |
| `cargar_archivo` / `parsear_hex` | dump loading |
| `cleanup` | restore terminal, close trace file |

---

## Memory map

| Region | Range | Contents |
|---|---|---|
| `.text` | `0x00400000` – `0x0043FFFF` | 16384 instructions (read-only) |
| Framebuffer | `0x10008000` – `0x1000FFFF` | base of `gp`; first 2048 words visible |
| `.data` | `0x10010000` – `0x10017FFF` | 8192 words |
| Stack | `0x7FFFB000` – `0x7FFFF000` | 16 KB, `sp` starts at `0x7FFFEFFC` |
| MMIO | `0xFFFF0000` – `0xFFFF000F` | `0000` key status, `0004` key data |

The `.data` base was determined empirically, by cross-checking three separate
`auipc`+`lw` pairs against RARS's disassembly listing and confirming that all
three implied the same base.

## Supported instructions

RV32I complete except `fence`, `ebreak` and CSR writes, plus the M extension
and the read-only counters.

| Format | Instructions |
|---|---|
| R | `add` `sub` `sll` `slt` `sltu` `xor` `srl` `sra` `or` `and` |
| M | `mul` `mulh` `mulhsu` `mulhu` `div` `divu` `rem` `remu` |
| I arithmetic | `addi` `slli` `slti` `sltiu` `xori` `srli` `srai` `ori` `andi` |
| I load | `lb` `lh` `lw` `lbu` `lhu` |
| S | `sb` `sh` `sw` |
| B | `beq` `bne` `blt` `bge` `bltu` `bgeu` |
| U | `lui` `auipc` |
| J | `jal` `jalr` |
| System | `ecall`, `rdcycle` `rdtime` `rdinstret` and their high halves |

## Syscalls (RARS services)

| `a7` | Service | Implementation |
|---|---|---|
| 1 | print integer | signed decimal |
| 4 | print string | byte-by-byte to the terminator |
| 5 | read integer | accepts sign and leading whitespace |
| 10 | exit | status 0 |
| 11 | print character | |
| 12 | read character | −1 at end of input |
| 31 | MIDI note | no-op (asynchronous in RARS) |
| 32 | sleep | `nanosleep`, milliseconds in `a0` |
| 34 | print hexadecimal | 8 digits |
| 93 | exit with status | status in `a0` |

## Trace format

Every executed instruction is printed with its address, its encoding, and its
disassembly:

```
0x00400b48  0x40730333  sub   x6, x6, x7
0x00400b54  0x00030463  beq   x6, x0, 0x00400b5c
```

Branches and jumps show the **absolute target address** rather than the relative
offset RARS prints, because in a trace thousands of lines long that saves doing
the arithmetic by hand on every jump.

---

## Testing

Three layers, from narrow to broad.

**Self-checking unit tests.** `tests/test_rv32i.asm` and `tests/test_rv32m.asm`
are RISC-V programs that compute a result, compare it against the expected
value, and print `PASS`/`FAIL` with the offending numbers. 45 tests covering
sign-extension edges, signed-versus-unsigned comparisons, shift-amount masking,
`x0` immutability, sub-word stores preserving their neighbours, stack
discipline, recursion, and every division edge case.

Because they are ordinary RISC-V programs, they run in RARS too — and the two
outputs must match byte for byte. That cross-check is what catches a
misunderstanding shared between the bundled assembler and the emulator, which
neither could detect alone.

```bash
make test
```

**Mutation testing.** Deliberately breaking the emulator and confirming the
suite notices. `sra`→`srl`, `setb`→`setl`, dropping a sign extension, dropping
`jalr`'s address mask: each should turn into a specific `FAIL`. A mutation that
survives is a coverage gap — that is how the missing PC alignment check was
found. Some survivors are *equivalent* mutations that genuinely cannot change
behaviour, and those are worth recognising rather than chasing.

**End-to-end.** Two complete games in `programs/`, written independently of this
emulator, both verified to behave identically here and in RARS.

The Bomberman was where generality got tested for real: running it required the
M extension, the cycle counters, larger memory arrays, the truncation warning,
and the framebuffer region fix — five gaps the Pong never exercised.

## Requirements

A 64-bit Linux system with NASM and GNU `ld`. The video output needs a terminal
with 24-bit colour support and at least 64 columns by 17 rows. `tools/rvasm.py`
needs Python 3.

## Game controls

`1` one player · `2` two players · `W`/`S` left · `O`/`L` right ·
`Ctrl+C` quit

## Credits

The Pong used as the primary test workload — `programs/pong/riscv1.asm`,
together with its dumps and listings — was written by Professor Ernesto Rivera
Alvarado for the course EL-4314 Computer Architecture I at the Instituto
Tecnológico de Costa Rica, and is included with credit as its licence header
requests.

The emulator itself (`src/emulador.asm`), the test suites and the bundled
assembler are my own work, developed with AI assistance.
