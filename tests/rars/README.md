# RARS-produced dumps

The dumps in this directory came from RARS, not from `tools/rvasm.py`. They
exist for one purpose: to check that the emulator decodes the machine code the
reference assembler actually produces, and not merely the code the bundled
assembler produces.

That distinction matters because `rvasm.py` was written alongside the emulator.
If it encoded something wrongly and the emulator decoded it wrongly the same
way, the test suites would still report success. RARS is the only independent
witness available.

## Using them

```bash
./emulador -q tests/rars/rv32i/punto_text_hex.txt tests/rars/rv32i/punto_data_hex.txt
./emulador -q tests/rars/rv32m/punto_text_hex.txt tests/rars/rv32m/punto_data_hex.txt
```

Expected: `pruebas ok: 26   fallidas: 0` and `pruebas ok: 19   fallidas: 0` —
the same results the `rvasm`-built versions give, and the same ones RARS prints
in its own console. To compare the two encodings word by word:

```bash
python3 tools/comparar_dumps.py tests/rars/rv32i/punto_text_hex.txt \
                                tests/build/punto_text_hex.txt
```

Differences here are expected and benign. `mv` expands differently in each
assembler, and `rvasm` pads `.data` strings to word boundaries where RARS packs
them tightly, which shifts every `la` that follows. Both were verified as
formatting differences, not encoding errors.

## Regenerating

Open the suite in RARS, assemble with **F3**, run with **F5** and confirm the
console shows the expected tally. Then `File → Dump Memory`: `.text` as
*Hexadecimal Text* to `punto_text_hex.txt`, and `.data` the same way to
`punto_data_hex.txt`, both inside this program's subdirectory.

No Bitmap Display or MMIO tool is needed — the suites are text only.

RARS dumps the whole segment, so `punto_data_hex.txt` runs to 1024 words mostly
filled with zeros. That is harmless.

## Contents

| Directory | Suite | Expected |
|---|---|---|
| `rv32i/` | `tests/test_rv32i.asm` | 26 passed, 0 failed |
| `rv32m/` | `tests/test_rv32m.asm` | 19 passed, 0 failed |

Both suites are cross-checked against RARS, so no part of the instruction set is
validated against the bundled assembler alone.
