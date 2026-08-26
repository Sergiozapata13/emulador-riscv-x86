# Pong

The original workload this emulator was built against. Two paddles, a ball, a
title screen and win/lose screens, all drawn into the 64×32 bitmap display.

## Running

```bash
make pong                       # from the repository root
```

or directly:

```bash
./emulador -q programs/pong/punto_text_hex.txt programs/pong/punto_data_hex.txt
```

To capture the disassembled trace at the same time:

```bash
./emulador -t traza.txt programs/pong/punto_text_hex.txt programs/pong/punto_data_hex.txt
```

## Controls

| Key | Action |
|---|---|
| `1` | one player (right paddle is the computer) |
| `2` | two players |
| `W` / `S` | left paddle up / down |
| `O` / `L` | right paddle up / down |
| `Ctrl+C` | quit |

## Files

| File | Contents |
|---|---|
| `riscv1.asm` | the RISC-V source |
| `punto_text_hex.txt` | `.text` dump, 1641 instructions |
| `punto_data_hex.txt` | `.data` dump |
| `listado_hex.txt` | RARS disassembly, immediates in hex |
| `listado_dec.txt` | the same listing, immediates in decimal |

The two listings are not executed. They are the independent reference the
emulator's own disassembler was validated against — 973 of 973 mnemonics
matched — and they remain useful for checking what should be at any given
address when a trace looks wrong.

## Regenerating the dumps from RARS

Open `riscv1.asm`, then configure `Tools → Bitmap Display`:

| Setting | Value |
|---|---|
| Unit Width in Pixels | 8 |
| Unit Height in Pixels | 8 |
| Display Width in Pixels | 512 |
| Display Height in Pixels | 256 |
| Base address for display | `0x10008000 (gp)` |

Press **Connect to Program**. Open `Tools → Keyboard and Display MMIO
Simulator` and connect it too; keystrokes go in its lower pane.

The base address is the setting most often missed — it defaults to
`0x10010000`, and the code adds `gp` to form each pixel address.

Assemble with **F3**, then `File → Dump Memory`: dump `.text` as *Hexadecimal
Text* to `punto_text_hex.txt`, and `.data` the same way to
`punto_data_hex.txt`.

## Credit

Written by Professor Ernesto Rivera Alvarado for EL-4314 Computer Architecture I
at the Instituto Tecnológico de Costa Rica. Its licence header permits free use
in other projects as long as credit is given.
