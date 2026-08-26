# Guest programs

Each subdirectory holds one RISC-V program that the emulator runs, with its
source and the two hexadecimal dumps produced by RARS.

| Program | Players | Start | Notes |
|---|---|---|---|
| [`pong/`](pong/) | 1 or 2 | `1` or `2` | the original test workload |
| [`bomberman/`](bomberman/) | 1 | `Space` | needs the M extension and `rdtime` |

Both run identically here and in RARS. Every program needs the same Bitmap
Display geometry — 8×8 units, 512×256 pixels, base address `gp` — and the
Keyboard MMIO simulator; each subdirectory repeats the exact settings.

To run one:

```bash
./emulador -q programs/<name>/punto_text_hex.txt programs/<name>/punto_data_hex.txt
```

`Ctrl+C` quits and restores the terminal.

## Adding another program

Assemble it in RARS, dump `.text` and `.data` as *Hexadecimal Text* into a new
subdirectory, and run it with the command above. Nothing in the emulator needs
to change: the dump paths are arguments, and the loader accepts upper or lower
case, LF or CRLF, and arbitrary whitespace.

If a dump is larger than the arrays that hold it, the emulator says so on stderr
rather than truncating in silence. The current limits are 16384 instructions and
8192 data words.
