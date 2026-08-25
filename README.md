# Emulador RISC-V en ensamblador x86-64

Emulador de la arquitectura RISC-V (RV32I) escrito íntegramente en ensamblador
x86-64 con NASM, sin bibliotecas: usa syscalls de Linux directamente y arranca
en `_start`, no en `main`.

Ejecuta código máquina generado por RARS a partir de volcados hexadecimales,
con salida de video en la consola de texto y captura de teclado.

## Compilar y ejecutar

```bash
make            # compila
make jugar      # ejecuta sin traza
make traza      # ejecuta y guarda traza.txt
make limpiar    # borra los archivos generados
```

El ejecutable debe correrse **desde el directorio del proyecto**, porque los
nombres de los archivos de entrada son rutas relativas.

### Opciones

| Invocación | Traza | Video | Salida del programa |
|---|---|---|---|
| `./emulador` | stdout | stderr | stdout |
| `./emulador -q` | no se genera | stderr | stdout |
| `./emulador -t archivo` | archivo | stderr | stdout |

Hay tres flujos y solo dos descriptores estándar, por eso existe `-t`: le da a
la traza su propio descriptor y deja los tres separados. Si el `open` falla, la
traza cae de vuelta a stdout en vez de abortar.

## Archivos de entrada

- `punto_text_hex.txt` — segmento `.text`, una instrucción de 8 dígitos hex por línea
- `punto_data_hex.txt` — segmento `.data`, una palabra por línea

Se generan desde RARS con `File → Dump Memory`, formato *Hexadecimal Text*,
volcando cada segmento por separado. Solo se aceptan minúsculas y líneas de
exactamente 8 caracteres.

## Mapa de memoria

La memoria emulada no es un arreglo único: el espacio de direcciones RISC-V
abarca 4 GB de los que solo existen unas pocas ventanas. `mem_read` y
`mem_write` son el decodificador que traduce cada dirección al arreglo del
anfitrión correspondiente.

| Región | Rango | Contenido |
|---|---|---|
| `.text` | `0x00400000` – `0x00401F40` | 2000 instrucciones (solo lectura) |
| Framebuffer | `0x10008000` – `0x1000FFFF` | 2048 palabras, base de `gp` |
| `.data` | `0x10010000` – `0x10011000` | 1024 palabras |
| Pila | `0x7FFFB000` – `0x7FFFF000` | 16 KB, `sp` inicia en `0x7FFFEFFC` |
| MMIO | `0xFFFF0000` – `0xFFFF000F` | `0000` estado de tecla, `0004` tecla |

La base de `.data` se determinó empíricamente contrastando tres accesos
`auipc`+`lw` distintos contra el listado desensamblado de RARS.

Cualquier acceso fuera de estas regiones, desalineado, o una escritura sobre
`.text`, aborta con un mensaje que incluye la dirección, el PC y un volcado de
los 32 registros. **El emulador nunca produce un fallo de segmentación.**

Escribir sobre `.text` se trata como error deliberadamente: casi siempre indica
un puntero descarriado, y es preferible verlo a corromper la memoria de programa
en silencio.

## Instrucciones soportadas

RV32I completo salvo `fence`, `ebreak` y los CSR.

| Tipo | Instrucciones |
|---|---|
| R | `add` `sub` `sll` `slt` `sltu` `xor` `srl` `sra` `or` `and` |
| I aritmético | `addi` `slli` `slti` `sltiu` `xori` `srli` `srai` `ori` `andi` |
| I carga | `lb` `lh` `lw` `lbu` `lhu` |
| S | `sb` `sh` `sw` |
| B | `beq` `bne` `blt` `bge` `bltu` `bgeu` |
| U | `lui` `auipc` |
| J | `jal` `jalr` |
| Sistema | `ecall` |

Las operaciones de byte y media palabra hacen leer-modificar-escribir sobre la
palabra que las contiene, asumiendo que el anfitrión es little-endian igual que
RISC-V.

## Syscalls (servicios de RARS)

| `a7` | Servicio | Implementación |
|---|---|---|
| 1 | imprimir entero | decimal con signo |
| 4 | imprimir cadena | lee byte a byte hasta el terminador |
| 5 | leer entero | acepta signo y espacios previos |
| 10 | terminar | código 0 |
| 11 | imprimir carácter | |
| 12 | leer carácter | −1 al llegar al fin de entrada |
| 31 | nota MIDI | no-op (es asíncrono en RARS) |
| 32 | dormir | `nanosleep`, milisegundos en `a0` |
| 34 | imprimir hexadecimal | 8 dígitos |
| 93 | terminar con código | código en `a0` |

## Video

La pantalla de RARS son 64×32 unidades. Se dibuja con el carácter de medio
bloque superior `▀`: el color de primer plano es el píxel de arriba y el de
fondo el de abajo, con lo que la rejilla entra en 64×16 caracteres de terminal
y conserva la proporción. Requiere una terminal con color de 24 bits y al menos
64 columnas por 17 filas.

Dos optimizaciones importantes:

- Los códigos de color solo se emiten cuando el color cambia respecto a la celda
  anterior. Un cuadro pesa unos 9.700 bytes en vez de los ~42.000 que costaría
  emitirlos siempre.
- El repintado ocurre en el `ecall` —la frontera natural entre cuadros— y solo
  si la bandera `fb_dirty` indica que algún `sw` tocó el framebuffer. Sin eso
  serían casi 3.000 repintados por cuadro. Como consecuencia, los programas de
  puro texto nunca activan el renderizador.

## Teclado

La terminal se pone en modo crudo apagando tres banderas de `c_lflag`:

- `ICANON` — entrega byte a byte en vez de esperar Enter
- `ECHO` — evita que las teclas se dibujen sobre el tablero
- `ISIG` — Ctrl+C deja de ser señal y llega como el byte `0x03`

Apagar `ISIG` es deliberado: así el emulador atiende el Ctrl+C y restaura la
terminal antes de salir. Con `ISIG` activo el proceso moriría de golpe y la
terminal quedaría sin eco y en modo crudo.

Además `VMIN` y `VTIME` van en cero y `stdin` se marca `O_NONBLOCK`, para que
`read` devuelva de inmediato y la emulación nunca se congele esperando entrada.
La configuración original se restaura en toda salida.

## Traza

El enunciado exige que cada instrucción ejecutada se muestre con sus detalles y
su PC. El formato es:

```
0x00400b48  0x40730333  sub   x6, x6, x7
0x00400b54  0x00030463  beq   x6, x0, 0x00400b5c
```

En los saltos se muestra la **dirección absoluta de destino**, no el
desplazamiento relativo como hace RARS, porque en una traza de miles de líneas
eso evita tener que hacer aritmética mental.

El desensamblador es independiente de la ejecución: tiene sus propios
extractores de inmediato (`imm_uj`, `imm_b`, `imm_s`) y sus propias variables de
campos (`d_rd`, `d_rs1`, …). Esa duplicación es intencional — leer una
instrucción no debe alterar ningún estado.

### Validación

El desensamblado se contrastó contra el listado de RARS: **973 de 973
mnemónicos idénticos** y 832 de 834 juegos de operandos equivalentes. Las dos
diferencias restantes son de formato, no de contenido: RARS extiende el signo
del inmediato de `lui` para mostrarlo, aquí se muestra el campo crudo.

## Controles del juego

`1` un jugador · `2` dos jugadores · `W`/`S` paleta izquierda ·
`O`/`L` paleta derecha · `Ctrl+C` salir

## Estructura del ciclo de ejecución

```
_start
  ├── procesar argumentos (-q, -t)
  ├── read_text_file  →  text_memory
  ├── read_data_file  →  data_memory
  ├── inicializar sp, gp, pc
  ├── term_init       →  modo crudo
  └── main_loop
        ├── fetch: (pc − 0x400000) / 4  →  índice en text_memory
        ├── print_trace  →  disasm
        ├── pc += 4                     (los saltos lo sobrescriben)
        └── decode_instruction  →  handler  →  write_reg / mem_write
```

El PC se incrementa **antes** de ejecutar, y los saltos lo sobrescriben usando
`r12d`, que guarda el PC de la instrucción actual. Por eso `auipc`, `jal`,
`jalr` y las ramas leen `r12d` y no el PC ya incrementado: calcular desde el
valor incrementado desplazaría todos los resultados 4 bytes.
