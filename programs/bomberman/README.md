# Bomberman

A second, independent workload: a maze of destructible blocks, wandering
enemies, and bombs with timed explosions. Written without this emulator in mind,
which is what makes it a real generality test rather than a program the emulator
was tuned around.

## Running

```bash
./emulador -q programs/bomberman/punto_text_hex.txt \
              programs/bomberman/punto_data_hex.txt
```

With a trace:

```bash
./emulador -t traza.txt programs/bomberman/punto_text_hex.txt \
                        programs/bomberman/punto_data_hex.txt
```

## Controls

| Key | Action |
|---|---|
| `Space` | start the game from the title screen |
| `W` / `A` / `S` / `D` | move |
| `Space` | drop a bomb (one at a time) |
| `Ctrl+C` | quit |

Single player only. The source declares `ASCII_1`, `ASCII_2`, `ASCII_O` and
`ASCII_L` but never uses them — leftovers from the Pong it was derived from,
which is also why both programs share the same drawing scaffolding.

## What it required

Running this program is what exposed five gaps the Pong never touched:

| Gap | Fix |
|---|---|
| `remu` for bounded randomness | the whole M extension |
| `rdtime` as a random seed | the read-only CSR counters |
| 3407 instructions vs a 2000 limit | larger arrays |
| dumps truncated in silence | a warning on stderr |
| draws one row below the screen | framebuffer region extended to match RARS |

That last one is worth reading twice. The write was legal — RARS maps that whole
range, so it lands in valid memory and simply is not displayed. The emulator was
rejecting something the system it emulates accepts, which is its own kind of
bug: an emulator must reproduce the reference's tolerance, not impose its own
idea of correctness.

## Regenerating the dumps from RARS

Same geometry as the Pong: `Tools → Bitmap Display` with 8×8 units, 512×256
pixels, base address `0x10008000 (gp)`, then **Connect to Program**. Add
`Tools → Keyboard and Display MMIO Simulator` and connect it as well.

Assemble with **F3**, then `File → Dump Memory` for `.text` and `.data`
separately, both as *Hexadecimal Text*.

Note that `tools/rvasm.py` cannot assemble this program: it uses three-operand
labelled stores (`sw a3, label, t0`) that the bundled assembler does not
support. RARS is required here.
