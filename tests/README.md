# Test suites

Self-checking RISC-V programs. Each test computes a value, compares it against
the expected result, and prints `FAIL` with both numbers when they differ. The
last line is a tally.

```
pruebas ok: 26   fallidas: 0
```

Because they are ordinary RISC-V programs, they run in RARS too — and the two
outputs must match byte for byte. That cross-check is the point: it catches a
misunderstanding shared between the bundled assembler and the emulator, which
neither could detect on its own.

## Running

```bash
make test        # both suites
make test-i      # RV32I only
make test-m      # M extension and counters only
```

`make` assembles each suite with `tools/rvasm.py` into `tests/build/` and runs
it. That directory is generated and ignored by git.

To run the RARS-produced dumps instead:

```bash
./emulador -q tests/rars/rv32i/punto_text_hex.txt tests/rars/rv32i/punto_data_hex.txt
./emulador -q tests/rars/rv32m/punto_text_hex.txt tests/rars/rv32m/punto_data_hex.txt
```

## What is covered

**`test_rv32i.asm` — 26 tests.** Overflow wraparound; signed versus unsigned
comparison (`slt`/`sltu`, `blt`/`bltu`) with operands that cross bit 31;
arithmetic versus logical shifts; shift amounts masked to five bits; `x0`
ignoring writes; sub-word stores leaving their neighbours intact; sign extension
on `lb` and `lh` but not `lbu`/`lhu`; stack save and restore; `auipc` computing
from its own address; recursion; and `jalr` discarding bit 0 of its target.

**`test_rv32m.asm` — 19 tests.** All four multiply variants including the high
halves; signed division truncating toward zero; remainder taking the sign of the
dividend; and every edge case the ISA defines where x86 would instead raise a
hardware exception — division by zero, remainder by zero, and `INT_MIN / -1`
overflow. The last two check that the cycle and time counters advance.

## Writing a new test

Follow the existing pattern: compute into `a0`, load the expected value into
`a1`, then `jal ra, check`. The `check` routine handles the tally and the
failure message, and preserves `s0`–`s2`.

```asm
    li t0, -16
    srai a0, t0, 4
    li a1, -16
    jal ra, check
```

Include at least one case where an operand has bit 31 set. That is where
signed/unsigned mistakes hide: they work perfectly for small values and fail
only once a number looks negative.

## Mutation testing

A suite that never fails proves nothing. Break the emulator deliberately and
confirm the tests notice — change `sar` to `shr`, `setb` to `setl`, drop a sign
extension, remove `jalr`'s address mask. Each should turn into a specific
`FAIL`.

A mutation that survives is a coverage gap. That is how the missing PC alignment
check was found: dropping `jalr`'s mask changed nothing observable, because the
index arithmetic silently rounded the odd address down. Test 26 and the
alignment check both exist because of that experiment.

Some survivors are *equivalent* mutations that genuinely cannot change
behaviour — replacing a 32-bit `imul` with a 64-bit one when only the low half
is used, for instance. Recognising those is worth more than chasing them.

## Contents

| File | Purpose |
|---|---|
| `test_rv32i.asm` | base integer instruction set |
| `test_rv32m.asm` | multiply/divide extension and the CSR counters |
| `rars/` | dumps produced by RARS, for the cross-check |
| `build/` | dumps produced by `rvasm.py` (generated) |
