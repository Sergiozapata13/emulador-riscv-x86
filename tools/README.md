# Tools

Two helper scripts. Neither is required to build or run the emulator.

| Script | Purpose |
|---|---|
| `rvasm.py` | assemble a test program without opening RARS |
| `comparar_dumps.py` | compare two hex dumps instruction by instruction |

## `rvasm.py`

A minimal RV32I/M assembler. It writes `punto_text_hex.txt` and
`punto_data_hex.txt` into the current directory, in the same format RARS dumps.

```bash
cd tests/build && python3 ../../tools/rvasm.py ../test_rv32i.asm
```

Its purpose is speed of iteration: edit, assemble and run in one chained
command, instead of opening RARS, assembling, producing two dumps through a
menu dialog, and moving the files. That is why `make test` uses it.

**It is not an independent source of truth.** It was written alongside the
emulator, so both could share the same misunderstanding — if it encoded a branch
immediate wrongly and the emulator decoded it wrongly the same way, the tests
would still pass. Only RARS can expose that. The rule is: **rvasm to iterate,
RARS to validate.**

Supports RV32I, the M extension, the read-only counters, the directives `.text`
`.data` `.word` `.asciz` `.string`, and the pseudo-instructions `li` `la` `mv`
`j` `jr` `ret` `call` `nop` `beqz` `bnez` `neg` `not` `seqz` `snez`.

Does **not** support three-operand labelled stores (`sw a3, label, t0`), which
is why the Bomberman must be assembled in RARS, nor `.align`, `.space`,
`.byte`, `.half` or macros.

### Known differences from RARS

`mv rd, rs` expands here to `addi rd, rs, 0`, the canonical form in the
specification; RARS emits `add rd, zero, rs`. Both are correct.

The `.data` section is padded here to four-byte multiples, because the output is
whole words. RARS packs strings back to back, so labels after the first string
land at different offsets.

The practical consequence: **the two dumps of a pair belong together.** Pairing
a RARS `.text` with an `rvasm` `.data` makes strings print from the wrong
offsets.

## `comparar_dumps.py`

Compares two dumps and, where they differ, shows both words disassembled — so
you can judge whether a difference is a real bug or just a different
pseudo-instruction expansion.

```bash
python3 tools/comparar_dumps.py tests/rars/punto_text_hex.txt \
                                tests/build/punto_text_hex.txt
```

It normalises case, whitespace and line endings, and exits 0 when the two are
equivalent.

```
  direccion     a.txt                          b.txt
  0x004000cc  00000533 add a0, zero, zero     00000513 addi a0, zero, 0
```

Its own disassembler was checked against the RARS listing in
`programs/pong/listado_hex.txt`: 1641 of 1641 mnemonics matched. So when it
names an instruction, the name is right.

A size difference reported at the top usually means a pseudo-instruction
expanded to a different number of words, which shifts everything after it and
turns one real discrepancy into hundreds of apparent ones.
