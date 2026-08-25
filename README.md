# RISC-V Emulator in x86-64 Assembly

An emulator for the RISC-V architecture (RV32I) written entirely in x86-64
assembly with NASM, with no libraries: it issues Linux syscalls directly and
starts at `_start` rather than `main`.

It runs machine code produced by RARS from hexadecimal memory dumps, renders
video to the text console, and captures keyboard input through memory-mapped
I/O.

## Building and running

```bash
make            # build
make jugar      # run without trace
make traza      # run and write traza.txt
make limpiar    # remove generated files
```

The executable must be run **from the project directory**, because the input
filenames are relative paths.

### Options

| Invocation | Trace | Video | Guest program output |
|---|---|---|---|
| `./emulador` | stdout | stderr | stdout |
| `./emulador -q` | not generated | stderr | stdout |
| `./emulador -t file` | file | stderr | stdout |

There are three output streams but only two standard descriptors, which is why
`-t` exists: it gives the trace its own descriptor and keeps all three separate.
If the `open` fails, the trace falls back to stdout instead of aborting.

## Input files

- `punto_text_hex.txt` — the `.text` segment, one 8-digit hex instruction per line
- `punto_data_hex.txt` — the `.data` segment, one word per line

Generate them from RARS via `File → Dump Memory`, format *Hexadecimal Text*,
dumping each segment separately. Only lowercase digits and lines of exactly
eight characters are accepted.

---

## Architecture

The emulator is a straightforward interpreter: a fetch-decode-execute loop over
an array of instruction words, with all guest state held in host memory. There
is no JIT, no basic-block caching, and no instruction pre-decoding — each
instruction is decoded from scratch every time it executes. For a target that
spends most of its time asleep between animation frames, that simplicity costs
nothing and keeps the code readable.

### Guest state

All emulated state lives in `.bss`, which the kernel zeroes at load time. That
zeroing is load-bearing in one specific case: `x0` is hardwired to zero in
RISC-V, and it stays zero here because the array starts at zero and `write_reg`
refuses to write index 0.

| Symbol | Size | Holds |
|---|---|---|
| `registers` | 33 words | `x0`–`x31` plus the PC at index 32 |
| `text_memory` | 2000 words | the `.text` segment |
| `data_memory` | 1024 words | the `.data` segment |
| `framebuffer` | 2048 words | video memory |
| `stack_mem` | 4096 words | the guest stack |
| `key_status`, `key_data` | 1 word each | the two MMIO registers |

Keeping the PC inside the register array rather than in a separate variable
means the whole machine state is one contiguous block, which is what makes the
register dump a simple loop.

### Execution cycle

```
_start
  ├── parse arguments (-q, -t)
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
guest uses `auipc` for nearly every data access, the damage would be widespread
and hard to localise.

The alternative design — leaving the PC alone and adding four only when the
instruction did not modify it — was rejected because it cannot represent a jump
to the current address. The guest's final instruction is `j 0`, an infinite
self-loop that marks the end of the program; under that scheme it would fall
through instead of halting.

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
a single line of code instead of a rule to remember at thirty call sites.

The second convention governs text output: **every emitter writes at `[rdi]` and
leaves `rdi` pointing just past what it wrote**. `put_hex8`, `emit_dec8`,
`e_reg`, `e_coma` and `e_dec` all obey it, so a formatted line is built by
calling them in sequence and the final length is simply how far the pointer
moved. No emitter needs to know or return a length.

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
again on `funct3` to the actual operation.

The immediate formats are where most of the subtlety lives:

- **I-type** immediates fall out of a single `sar ecx, 20`. An *arithmetic*
  shift moves the field into the low bits and replicates bit 31 upward in the
  same instruction, so sign extension is free. Using `shr` instead would turn
  every negative offset into a large positive one.
- **S-type** immediates arrive split in two pieces, `instr[31:25]` and
  `instr[11:7]`. The high piece is built with `sar 25`, shifted left five, and
  the low piece is OR'd in.
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
path that produces a segmentation fault, which the assignment requires
explicitly.

| Condition | Response |
|---|---|
| Input file missing | message, exit 3 |
| Unimplemented opcode | PC, instruction, register dump, exit 2 |
| Unmapped or misaligned address | address, PC, register dump, exit 4 |
| Write into `.text` | treated as an invalid access |
| Unimplemented syscall | the `a7` value, register dump, exit 5 |

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
| `decode_ecall` | syscall dispatch on `a7` |
| `mem_read` / `mem_write` | word access, address decode |
| `mem_read_byte` / `mem_read_half` | sub-word reads |
| `mem_write_byte` / `mem_write_half` | sub-word read-modify-write |
| `read_reg` / `write_reg` | register file access, `x0` guard |
| `render_frame` | framebuffer to ANSI |
| `poll_key` / `term_init` / `term_restore` | keyboard and terminal state |
| `disasm` | instruction to text |
| `put_hex8` / `put_dec` / `emit_dec8` / `e_dec` | number formatting |
| `read_text_file` / `read_data_file` | hex dump loading |
| `cleanup` | restore terminal, close trace file |

---

## Memory map

| Region | Range | Contents |
|---|---|---|
| `.text` | `0x00400000` – `0x00401F40` | 2000 instructions (read-only) |
| Framebuffer | `0x10008000` – `0x1000FFFF` | 2048 words, base of `gp` |
| `.data` | `0x10010000` – `0x10011000` | 1024 words |
| Stack | `0x7FFFB000` – `0x7FFFF000` | 16 KB, `sp` starts at `0x7FFFEFFC` |
| MMIO | `0xFFFF0000` – `0xFFFF000F` | `0000` key status, `0004` key data |

The `.data` base was determined empirically, by cross-checking three separate
`auipc`+`lw` pairs against RARS's disassembly listing and confirming that all
three implied the same base.

## Supported instructions

RV32I complete except `fence`, `ebreak` and the CSR instructions.

| Format | Instructions |
|---|---|
| R | `add` `sub` `sll` `slt` `sltu` `xor` `srl` `sra` `or` `and` |
| I arithmetic | `addi` `slli` `slti` `sltiu` `xori` `srli` `srai` `ori` `andi` |
| I load | `lb` `lh` `lw` `lbu` `lhu` |
| S | `sb` `sh` `sw` |
| B | `beq` `bne` `blt` `bge` `bltu` `bgeu` |
| U | `lui` `auipc` |
| J | `jal` `jalr` |
| System | `ecall` |

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

The assignment requires every executed instruction to be shown with its details
and its PC. The format is:

```
0x00400b48  0x40730333  sub   x6, x6, x7
0x00400b54  0x00030463  beq   x6, x0, 0x00400b5c
```

Branches and jumps show the **absolute target address** rather than the relative
offset RARS prints, because in a trace thousands of lines long that saves doing
the arithmetic by hand on every jump.

### Validation

The disassembler was cross-checked against RARS's own listing over a full run of
the guest program: **973 of 973 mnemonics identical**, and 832 of 834 operand
sets equivalent after normalising formatting. The two remaining differences are
presentational, not substantive — RARS sign-extends the `lui` immediate for
display, whereas this emulator shows the raw encoded field.

## Requirements

A 64-bit Linux system with NASM and GNU `ld`. The video output needs a terminal
with 24-bit colour support and at least 64 columns by 17 rows.

## Game controls

`1` one player · `2` two players · `W`/`S` left paddle ·
`O`/`L` right paddle · `Ctrl+C` quit

## Credits

The RISC-V program used as the test workload — `riscv1.asm`, together with the
`punto_text_hex.txt` and `punto_data_hex.txt` dumps and the `1` and `3` listings
derived from it — is a Pong implementation written by Professor Ernesto Rivera
Alvarado for the course EL-4314 Computer Architecture I at the Instituto
Tecnológico de Costa Rica. It is included solely as a test program for the
emulator.

The emulator itself (`emulador.asm`) is my own work, developed with AI
assistance.
