#!/usr/bin/env python3
"""Compara dos volcados hexadecimales de RARS instruccion por instruccion.

Normaliza mayusculas, espaciado y finales de linea, y cuando encuentra una
diferencia la muestra desensamblada, para poder juzgar si es un error real o
solo una expansion distinta de una pseudoinstruccion.

    python3 tools/comparar_dumps.py a.txt b.txt [--base 0x400000]

Devuelve 0 si son equivalentes, 1 si difieren.
"""
import sys, re

ABI = ['zero','ra','sp','gp','tp','t0','t1','t2','s0','s1','a0','a1','a2','a3',
       'a4','a5','a6','a7','s2','s3','s4','s5','s6','s7','s8','s9','s10','s11',
       't3','t4','t5','t6']

R_M = {0:'mul',1:'mulh',2:'mulhsu',3:'mulhu',4:'div',5:'divu',6:'rem',7:'remu'}
R_B = {0:'add',1:'sll',2:'slt',3:'sltu',4:'xor',5:'srl',6:'or',7:'and'}
I_A = {0:'addi',1:'slli',2:'slti',3:'sltiu',4:'xori',5:'srli',6:'ori',7:'andi'}
LD  = {0:'lb',1:'lh',2:'lw',4:'lbu',5:'lhu'}
ST  = {0:'sb',1:'sh',2:'sw'}
BR  = {0:'beq',1:'bne',4:'blt',5:'bge',6:'bltu',7:'bgeu'}


def sx(v, bits):
    return v - (1 << bits) if v & (1 << (bits - 1)) else v


def desensamblar(w, pc):
    """Devuelve el texto de la instruccion, o None si no se reconoce."""
    op = w & 0x7F
    rd, rs1, rs2 = (w >> 7) & 0x1F, (w >> 15) & 0x1F, (w >> 20) & 0x1F
    f3, f7 = (w >> 12) & 7, (w >> 25) & 0x7F
    r = lambda i: ABI[i]

    if op == 0x37:
        return f"lui {r(rd)}, 0x{(w >> 12) & 0xFFFFF:05x}"
    if op == 0x17:
        return f"auipc {r(rd)}, 0x{(w >> 12) & 0xFFFFF:05x}"
    if op == 0x6F:
        imm = sx((((w >> 31) & 1) << 20) | (((w >> 21) & 0x3FF) << 1)
                 | (((w >> 20) & 1) << 11) | (((w >> 12) & 0xFF) << 12), 21)
        return f"jal {r(rd)}, 0x{(pc + imm) & 0xFFFFFFFF:08x}"
    if op == 0x67:
        return f"jalr {r(rd)}, {sx(w >> 20, 12)}({r(rs1)})"
    if op == 0x63:
        imm = sx((((w >> 31) & 1) << 12) | (((w >> 25) & 0x3F) << 5)
                 | (((w >> 8) & 0xF) << 1) | (((w >> 7) & 1) << 11), 13)
        return f"{BR.get(f3,'b?')} {r(rs1)}, {r(rs2)}, 0x{(pc + imm) & 0xFFFFFFFF:08x}"
    if op == 0x03:
        return f"{LD.get(f3,'l?')} {r(rd)}, {sx(w >> 20, 12)}({r(rs1)})"
    if op == 0x23:
        imm = sx(((w >> 25) << 5) | ((w >> 7) & 0x1F), 12)
        return f"{ST.get(f3,'s?')} {r(rs2)}, {imm}({r(rs1)})"
    if op == 0x13:
        if f3 in (1, 5):
            nom = 'srai' if (f3 == 5 and w & 0x40000000) else I_A[f3]
            return f"{nom} {r(rd)}, {r(rs1)}, {(w >> 20) & 0x1F}"
        return f"{I_A[f3]} {r(rd)}, {r(rs1)}, {sx(w >> 20, 12)}"
    if op == 0x33:
        if f7 == 1:
            nom = R_M[f3]
        elif f3 == 0:
            nom = 'sub' if f7 == 0x20 else 'add'
        elif f3 == 5:
            nom = 'sra' if f7 == 0x20 else 'srl'
        else:
            nom = R_B[f3]
        return f"{nom} {r(rd)}, {r(rs1)}, {r(rs2)}"
    if op == 0x73:
        if f3 == 0:
            return 'ebreak' if w & 0x00100000 else 'ecall'
        return f"csr 0x{(w >> 20) & 0xFFF:03x}, {r(rd)}"
    return None


def leer(ruta):
    """Extrae las palabras del volcado, tolerando cualquier formato."""
    txt = open(ruta, encoding='utf-8', errors='replace').read()
    return [int(t, 16) for t in re.findall(r'[0-9a-fA-F]{1,8}', txt)]


def main():
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    base = 0x400000
    for a in sys.argv[1:]:
        if a.startswith('--base'):
            base = int(a.split('=')[1], 0)
    if len(args) != 2:
        print(__doc__)
        return 2

    a, b = leer(args[0]), leer(args[1])
    na, nb = args[0], args[1]
    print(f"{na}: {len(a)} palabras")
    print(f"{nb}: {len(b)} palabras")

    if len(a) != len(b):
        print(f"\nDIFERENCIA DE TAMANO: {abs(len(a)-len(b))} palabras.")
        print("Suele indicar que una pseudoinstruccion se expandio distinto.")

    difs = [i for i in range(min(len(a), len(b))) if a[i] != b[i]]
    if not difs:
        if len(a) == len(b):
            print("\nIDENTICOS: la codificacion coincide palabra por palabra.")
            return 0
        print(f"\nEl prefijo comun de {min(len(a),len(b))} palabras coincide.")
        return 1

    print(f"\n{len(difs)} palabras difieren. Primeras {min(15,len(difs))}:\n")
    print(f"  {'direccion':<12}{'':2}{na[:26]:<40}{nb[:26]}")
    print("  " + "-" * 90)
    for i in difs[:15]:
        pc = base + 4 * i
        da = desensamblar(a[i], pc) or '?'
        db = desensamblar(b[i], pc) or '?'
        print(f"  0x{pc:08x}  {a[i]:08x} {da:<31}{b[i]:08x} {db}")
    if len(difs) > 15:
        print(f"  ... y {len(difs)-15} mas")
    return 1


sys.exit(main())
