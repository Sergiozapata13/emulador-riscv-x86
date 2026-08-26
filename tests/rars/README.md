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
./emulador -q tests/rars/punto_text_hex.txt tests/rars/punto_data_hex.txt
```

Expected: `pruebas ok: 26   fallidas: 0` — the same result as the `rvasm`-built
version. To compare the two encodings word by word:

```bash
python3 tools/comparar_dumps.py tests/rars/punto_text_hex.txt \
                                tests/build/punto_text_hex.txt
```

Differences here are expected and benign. `mv` expands differently in each
assembler, and `rvasm` pads `.data` strings to word boundaries where RARS packs
them tightly, which shifts every `la` that follows. Both were verified as
formatting differences, not encoding errors.

## Regenerating

Open `tests/test_rv32i.asm` in RARS, assemble with **F3**, run with **F5** and
confirm the console shows the same tally. Then `File → Dump Memory`: `.text` as
*Hexadecimal Text* to `punto_text_hex.txt`, and `.data` the same way to
`punto_data_hex.txt`.

No Bitmap Display or MMIO tool is needed — the suites are text only.

RARS dumps the whole segment, so `punto_data_hex.txt` runs to 1024 words mostly
filled with zeros. That is harmless.

## Current contents

Only `test_rv32i.asm` has been dumped so far. **`test_rv32m.asm` still lacks its
RARS cross-check**, so the M extension and the CSR counters are validated
against `rvasm` alone. Producing those two files is the outstanding gap here.
