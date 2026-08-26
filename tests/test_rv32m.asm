# =====================================================================
# test_rv32m.asm - pruebas de la extension M y los contadores CSR
# Mismo patron auto-verificable: corre igual en RARS y en el emulador.
# =====================================================================
.data
msg_fail:   .asciz "FAIL prueba "
msg_got:    .asciz "  obtenido="
msg_want:   .asciz "  esperado="
msg_fin:    .asciz "\npruebas ok: "
msg_bad:    .asciz "   fallidas: "
msg_nl:     .asciz "\n"

.text
main:
    li s0, 0
    li s1, 0
    li s2, 0

# --- multiplicacion ---
    li t0, 6
    li t1, 7
    mul a0, t0, t1
    li a1, 42
    jal ra, check

    li t0, -3                   # el signo se conserva en los 32 bajos
    li t1, 5
    mul a0, t0, t1
    li a1, -15
    jal ra, check

    li t0, 0x40000000           # 2^30 * 4 = 2^32: la parte alta vale 1
    li t1, 4
    mulh a0, t0, t1
    li a1, 1
    jal ra, check

    li t0, -1                   # sin signo: 0xffffffff al cuadrado
    li t1, -1
    mulhu a0, t0, t1
    li a1, 0xfffffffe
    jal ra, check

    li t0, -1                   # rs1 con signo, rs2 sin signo: -1 * 2 = -2
    li t1, 2
    mulhsu a0, t0, t1
    li a1, -1
    jal ra, check

# --- division con signo ---
    li t0, 100
    li t1, 7
    div a0, t0, t1
    li a1, 14
    jal ra, check

    li t0, -100                 # trunca HACIA CERO, no hacia abajo
    li t1, 7
    div a0, t0, t1
    li a1, -14
    jal ra, check

    li t0, 100
    li t1, 7
    rem a0, t0, t1
    li a1, 2
    jal ra, check

    li t0, -100                 # el resto sigue el signo del dividendo
    li t1, 7
    rem a0, t0, t1
    li a1, -2
    jal ra, check

# --- division sin signo ---
    li t0, -1                   # 0xffffffff / 2
    li t1, 2
    divu a0, t0, t1
    li a1, 0x7fffffff
    jal ra, check

    li t0, -1                   # 4294967295 % 10 = 5
    li t1, 10
    remu a0, t0, t1
    li a1, 5
    jal ra, check

# --- casos limite: RISC-V los define, no lanza excepcion ---
    li t0, 5                    # division entre cero -> todos unos
    li t1, 0
    div a0, t0, t1
    li a1, -1
    jal ra, check

    li t0, 5                    # resto entre cero -> el dividendo
    li t1, 0
    rem a0, t0, t1
    li a1, 5
    jal ra, check

    li t0, 5                    # division sin signo entre cero
    li t1, 0
    divu a0, t0, t1
    li a1, 0xffffffff
    jal ra, check

    li t0, 5
    li t1, 0
    remu a0, t0, t1
    li a1, 5
    jal ra, check

    li t0, 0x80000000           # INT_MIN / -1 desborda -> INT_MIN
    li t1, -1
    div a0, t0, t1
    li a1, 0x80000000
    jal ra, check

    li t0, 0x80000000           # INT_MIN %% -1 -> 0
    li t1, -1
    rem a0, t0, t1
    li a1, 0
    jal ra, check

# --- contadores CSR ---
    rdinstret t0                # debe avanzar entre dos lecturas
    nop
    nop
    rdinstret t1
    sltu a0, t0, t1
    li a1, 1
    jal ra, check

    rdtime t0                   # debe devolver algo distinto de cero
    snez a0, t0
    li a1, 1
    jal ra, check

# --- resumen ---
    la a0, msg_fin
    li a7, 4
    ecall
    mv a0, s0
    li a7, 1
    ecall
    la a0, msg_bad
    li a7, 4
    ecall
    mv a0, s1
    li a7, 1
    ecall
    la a0, msg_nl
    li a7, 4
    ecall
    # Salir con el numero de fallos como codigo de salida. Sin esto el
    # emulador termina en 0 aunque haya pruebas fallidas, y cualquier
    # automatizacion veria verde un banco roto.
    mv a0, s1
    li a7, 93
    ecall

check:
    addi sp, sp, -4
    sw ra, 0(sp)
    addi s2, s2, 1
    beq a0, a1, check_ok
    mv t3, a0
    mv t4, a1
    la a0, msg_fail
    li a7, 4
    ecall
    mv a0, s2
    li a7, 1
    ecall
    la a0, msg_got
    li a7, 4
    ecall
    mv a0, t3
    li a7, 34
    ecall
    la a0, msg_want
    li a7, 4
    ecall
    mv a0, t4
    li a7, 34
    ecall
    la a0, msg_nl
    li a7, 4
    ecall
    addi s1, s1, 1
    j check_fin
check_ok:
    addi s0, s0, 1
check_fin:
    lw ra, 0(sp)
    addi sp, sp, 4
    ret
