#!/usr/bin/env python3
"""Ensamblador minimo de RV32I/M para iterar rapido sin abrir RARS.

QUE ES
    Una herramienta de conveniencia. Ensambla los programas de prueba de
    tests/ y escribe punto_text_hex.txt y punto_data_hex.txt en el
    directorio actual, con el mismo formato que vuelca RARS. Es lo que usa
    `make test`: editar, ensamblar y correr queda en un solo comando, en vez
    del ciclo de abrir RARS, ensamblar, hacer dos volcados por menu y mover
    los archivos.

QUE **NO** ES
    Una fuente de verdad independiente. Se escribio junto con el emulador,
    asi que los dos podrian compartir el mismo malentendido: si aqui se
    codificara mal el inmediato de una rama y el emulador lo decodificara mal
    de la misma forma, las pruebas pasarian igual. Solo RARS puede delatar
    eso. La regla es: **rvasm para iterar, RARS para validar.**

QUE SOPORTA
    RV32I completo, la extension M, los contadores (rdtime, rdcycle,
    rdinstret), las directivas .text .data .word .asciz .string, y las
    pseudoinstrucciones li la mv j jr ret call nop beqz bnez neg not seqz
    snez.

QUE NO SOPORTA
    Almacenamientos de tres operandos con etiqueta (`sw a3, etiqueta, t0`),
    que es por lo que el Bomberman debe ensamblarse en RARS. Tampoco .align,
    .space, .byte, .half, macros, ni la mayoria de las directivas.

DIFERENCIAS CONOCIDAS CON RARS
    - `mv rd, rs` se expande aqui como `addi rd, rs, 0` (la forma canonica de
      la especificacion) y en RARS como `add rd, zero, rs`. Las dos son
      correctas y hacen lo mismo.
    - El .data se rellena aqui hasta multiplos de 4 bytes, porque la salida
      son palabras completas. RARS coloca las cadenas una tras otra sin
      relleno, asi que las etiquetas posteriores quedan en desplazamientos
      distintos.
    Consecuencia practica: los dos volcados de un par van juntos. Cruzar el
    .text de RARS con el .data de rvasm hace que las cadenas se impriman
    desde posiciones equivocadas.

USO
    python3 rvasm.py programa.asm
"""
import re, sys

REGS = {f'x{i}': i for i in range(32)}
REGS.update({'zero':0,'ra':1,'sp':2,'gp':3,'tp':4,'t0':5,'t1':6,'t2':7,
    's0':8,'fp':8,'s1':9,'a0':10,'a1':11,'a2':12,'a3':13,'a4':14,'a5':15,
    'a6':16,'a7':17,'s2':18,'s3':19,'s4':20,'s5':21,'s6':22,'s7':23,
    's8':24,'s9':25,'s10':26,'s11':27,'t3':28,'t4':29,'t5':30,'t6':31})

R_OPS = {'add':(0,0),'sub':(0,0x20),'sll':(1,0),'slt':(2,0),'sltu':(3,0),
         'xor':(4,0),'srl':(5,0),'sra':(5,0x20),'or':(6,0),'and':(7,0),
         # extension M: funct7 = 1
         'mul':(0,1),'mulh':(1,1),'mulhsu':(2,1),'mulhu':(3,1),
         'div':(4,1),'divu':(5,1),'rem':(6,1),'remu':(7,1)}
I_OPS = {'addi':0,'slli':1,'slti':2,'sltiu':3,'xori':4,'srli':5,'srai':5,
         'ori':6,'andi':7}
L_OPS = {'lb':0,'lh':1,'lw':2,'lbu':4,'lhu':5}
S_OPS = {'sb':0,'sh':1,'sw':2}
B_OPS = {'beq':0,'bne':1,'blt':4,'bge':5,'bltu':6,'bgeu':7}

def r(t): 
    t = t.strip()
    if t not in REGS: raise ValueError(f'registro desconocido: {t}')
    return REGS[t]

class Asm:
    def __init__(self):
        self.text = []      # (pc, tokens)
        self.data = []      # palabras
        self.labels = {}
        self.dlabels = {}
        self.TEXT = 0x400000
        self.DATA = 0x10010000

    def parse(self, src):
        seccion = 'text'
        pc = self.TEXT
        dpos = self.DATA
        for linea in src.splitlines():
            linea = linea.split('#')[0].strip()
            if not linea: continue
            if linea == '.text': seccion='text'; continue
            if linea == '.data': seccion='data'; continue
            while ':' in linea.split('"')[0]:
                et, _, resto = linea.partition(':')
                et = et.strip()
                if seccion=='text': self.labels[et]=pc
                else: self.dlabels[et]=dpos
                linea = resto.strip()
                if not linea: break
            if not linea: continue
            if seccion=='data':
                d = linea.split(None,1)
                if d[0]=='.word':
                    for v in d[1].split(','):
                        self.data.append(int(v.strip(),0) & 0xffffffff); dpos+=4
                elif d[0]=='.asciz' or d[0]=='.string':
                    s = re.search(r'"(.*)"', d[1]).group(1)
                    s = s.encode().decode('unicode_escape').encode()+b'\0'
                    while len(s)%4: s+=b'\0'
                    for i in range(0,len(s),4):
                        self.data.append(int.from_bytes(s[i:i+4],'little')); dpos+=4
                continue
            ops = self.expand(linea)
            for o in ops:
                self.text.append((pc,o)); pc+=4

    def expand(self, linea):
        """Expande pseudoinstrucciones a instrucciones reales."""
        m = linea.split(None,1)
        op = m[0]; args = [a.strip() for a in m[1].split(',')] if len(m)>1 else []
        if op=='li':
            v = int(args[1],0)
            if -2048 <= v < 2048: return [f'addi {args[0]},zero,{v}']
            lo = v & 0xfff
            hi = (v - (lo-4096 if lo&0x800 else lo)) >> 12
            imm = lo-4096 if lo&0x800 else lo
            return [f'lui {args[0]},{hi&0xfffff}', f'addi {args[0]},{args[0]},{imm}']
        if op=='la':
            return [f'__la {args[0]},{args[1]}']
        if op=='mv':  return [f'addi {args[0]},{args[1]},0']
        if op=='j':   return [f'jal zero,{args[0]}']
        if op=='jr':  return [f'jalr zero,{args[0]},0']
        if op=='ret': return ['jalr zero,ra,0']
        if op=='call':return [f'jal ra,{args[0]}']
        if op=='nop': return ['addi zero,zero,0']
        if op=='rdtime':    return [f'csrrs {args[0]},0xC01,zero']
        if op=='rdcycle':   return [f'csrrs {args[0]},0xC00,zero']
        if op=='rdinstret': return [f'csrrs {args[0]},0xC02,zero']
        if op=='beqz':return [f'beq {args[0]},zero,{args[1]}']
        if op=='bnez':return [f'bne {args[0]},zero,{args[1]}']
        if op=='neg': return [f'sub {args[0]},zero,{args[1]}']
        if op=='not': return [f'xori {args[0]},{args[1]},-1']
        if op=='seqz':return [f'sltiu {args[0]},{args[1]},1']
        if op=='snez':return [f'sltu {args[0]},zero,{args[1]}']
        return [linea]

    def enc(self, pc, linea):
        m = linea.split(None,1)
        op = m[0]; a = [x.strip() for x in m[1].split(',')] if len(m)>1 else []
        def lbl(t):
            if t in self.labels: return self.labels[t]
            if t in self.dlabels: return self.dlabels[t]
            return int(t,0)
        if op=='__la':
            d = lbl(a[1]); off = d - pc
            hi = (off + 0x800) >> 12
            lo = off - (hi<<12)
            return [(hi&0xfffff)<<12 | r(a[0])<<7 | 0x17,
                    (lo&0xfff)<<20 | r(a[0])<<15 | r(a[0])<<7 | 0x13]
        if op in R_OPS:
            f3,f7 = R_OPS[op]
            return [f7<<25 | r(a[2])<<20 | r(a[1])<<15 | f3<<12 | r(a[0])<<7 | 0x33]
        if op in I_OPS:
            f3 = I_OPS[op]; v = lbl(a[2]) if not a[2].lstrip('-').isdigit() else int(a[2])
            if op in ('slli','srli','srai'):
                top = 0x20 if op=='srai' else 0
                return [top<<25 | (v&0x1f)<<20 | r(a[1])<<15 | f3<<12 | r(a[0])<<7 | 0x13]
            return [(v&0xfff)<<20 | r(a[1])<<15 | f3<<12 | r(a[0])<<7 | 0x13]
        if op=='lui':
            return [(lbl(a[1])&0xfffff)<<12 | r(a[0])<<7 | 0x37]
        if op=='auipc':
            return [(lbl(a[1])&0xfffff)<<12 | r(a[0])<<7 | 0x17]
        if op in L_OPS or op in S_OPS:
            mm = re.match(r'(-?\w+)\((\w+)\)', a[1] if op in L_OPS else a[1])
            off = int(mm.group(1),0); base = r(mm.group(2))
            if op in L_OPS:
                return [(off&0xfff)<<20 | base<<15 | L_OPS[op]<<12 | r(a[0])<<7 | 0x03]
            v = off & 0xfff
            return [(v>>5)<<25 | r(a[0])<<20 | base<<15 | S_OPS[op]<<12 | (v&0x1f)<<7 | 0x23]
        if op in B_OPS:
            off = lbl(a[2]) - pc; v = off & 0x1fff
            return [((v>>12)&1)<<31 | ((v>>5)&0x3f)<<25 | r(a[1])<<20 | r(a[0])<<15
                    | B_OPS[op]<<12 | ((v>>1)&0xf)<<8 | ((v>>11)&1)<<7 | 0x63]
        if op=='jal':
            off = lbl(a[1]) - pc; v = off & 0x1fffff
            return [((v>>20)&1)<<31 | ((v>>1)&0x3ff)<<21 | ((v>>11)&1)<<20
                    | ((v>>12)&0xff)<<12 | r(a[0])<<7 | 0x6f]
        if op=='jalr':
            return [(int(a[2],0)&0xfff)<<20 | r(a[1])<<15 | r(a[0])<<7 | 0x67]
        if op=='csrrs':
            return [(int(a[1],0)&0xfff)<<20 | r(a[2])<<15 | 2<<12 | r(a[0])<<7 | 0x73]
        if op=='ecall': return [0x73]
        raise ValueError(f'instruccion no soportada: {linea}')

    def assemble(self, src):
        self.parse(src)
        # segunda pasada: la expansion de `la` ocupa 2 palabras, recalcular
        out = []
        pc = self.TEXT
        for _, linea in self.text:
            ws = self.enc(pc, linea)
            out.extend(ws); pc += 4*len(ws)
        return out, self.data

def main():
    src = open(sys.argv[1]).read()
    a = Asm()
    # pasada previa para que `la` reserve 2 palabras
    tmp = Asm(); tmp.parse(src)
    ajuste = {}
    pc = tmp.TEXT
    for _, l in tmp.text:
        pc += 8 if l.startswith('__la') else 4
    a2 = Asm()
    # recalcular etiquetas contando 2 palabras por `la`
    a2.TEXT = tmp.TEXT
    seccion='text'; pc=a2.TEXT; dpos=a2.DATA
    for linea in src.splitlines():
        linea = linea.split('#')[0].strip()
        if not linea: continue
        if linea=='.text': seccion='text'; continue
        if linea=='.data': seccion='data'; continue
        while ':' in linea.split('"')[0]:
            et,_,resto = linea.partition(':'); et=et.strip()
            if seccion=='text': a2.labels[et]=pc
            else: a2.dlabels[et]=dpos
            linea = resto.strip()
            if not linea: break
        if not linea: continue
        if seccion=='data':
            d=linea.split(None,1)
            if d[0]=='.word': dpos += 4*len(d[1].split(','))
            elif d[0] in ('.asciz','.string'):
                s=re.search(r'"(.*)"',d[1]).group(1)
                s=s.encode().decode('unicode_escape').encode()+b'\0'
                while len(s)%4: s+=b'\0'
                dpos += len(s)
            continue
        for o in a2.expand(linea):
            pc += 8 if o.startswith('__la') else 4
    a2.text=[]; a2.data=[]
    seccion='text'
    for linea in src.splitlines():
        linea = linea.split('#')[0].strip()
        if not linea: continue
        if linea=='.text': seccion='text'; continue
        if linea=='.data': seccion='data'; continue
        while ':' in linea.split('"')[0]:
            _,_,resto = linea.partition(':'); linea=resto.strip()
            if not linea: break
        if not linea: continue
        if seccion=='data':
            d=linea.split(None,1)
            if d[0]=='.word':
                for v in d[1].split(','): a2.data.append(int(v.strip(),0)&0xffffffff)
            elif d[0] in ('.asciz','.string'):
                s=re.search(r'"(.*)"',d[1]).group(1)
                s=s.encode().decode('unicode_escape').encode()+b'\0'
                while len(s)%4: s+=b'\0'
                for i in range(0,len(s),4):
                    a2.data.append(int.from_bytes(s[i:i+4],'little'))
            continue
        for o in a2.expand(linea): a2.text.append((0,o))
    out=[]; pc=a2.TEXT
    for _,l in a2.text:
        ws=a2.enc(pc,l); out.extend(ws); pc+=4*len(ws)
    with open('punto_text_hex.txt','w') as f:
        f.write('\n'.join(f'{w:08x}' for w in out)+'\n')
    with open('punto_data_hex.txt','w') as f:
        d = a2.data if a2.data else [0]
        f.write('\n'.join(f'{w:08x}' for w in d)+'\n')
    print(f'{len(out)} instrucciones, {len(a2.data)} palabras de datos')

main()
