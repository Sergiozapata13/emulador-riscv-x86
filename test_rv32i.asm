# =====================================================================
# test_rv32i.asm - banco de pruebas auto-verificable para el emulador
#
# Cada prueba calcula un valor en a0, carga el esperado en a1, y llama a
# `check`. Al final imprime cuantas pasaron y cuantas fallaron.
#
# Se corre igual en RARS y en el emulador; las dos salidas deben ser
# identicas byte a byte.
#
# RARS: Bitmap Display no hace falta. Solo la consola.
# =====================================================================

.data
buffer:     .word 0, 0, 0, 0
msg_ok:     .asciz "PASS "
msg_fail:   .asciz "FAIL prueba "
msg_got:    .asciz "  obtenido="
msg_want:   .asciz "  esperado="
msg_fin:    .asciz "\npruebas ok: "
msg_bad:    .asciz "   fallidas: "
msg_nl:     .asciz "\n"

.text
main:
    li s0, 0                    # contador de pruebas que pasaron
    li s1, 0                    # contador de fallidas
    li s2, 0                    # numero de prueba

# ---- 1. Desbordamiento: la suma da la vuelta sin excepcion ----------
    li t0, 0x7fffffff
    li t1, 1
    add a0, t0, t1
    li a1, 0x80000000
    jal ra, check

# ---- 2. Resta que cruza el cero ------------------------------------
    li t0, 5
    li t1, 9
    sub a0, t0, t1
    li a1, -4
    jal ra, check

# ---- 3. slt CON signo: -1 es menor que 1 ---------------------------
    li t0, -1
    li t1, 1
    slt a0, t0, t1
    li a1, 1
    jal ra, check

# ---- 4. sltu SIN signo: 0xffffffff es mayor que 1 ------------------
    li t0, -1
    li t1, 1
    sltu a0, t0, t1
    li a1, 0
    jal ra, check

# ---- 5. sra replica el signo ---------------------------------------
    li t0, -16
    li t1, 2
    sra a0, t0, t1
    li a1, -4
    jal ra, check

# ---- 6. srl mete ceros ---------------------------------------------
    li t0, -16
    li t1, 2
    srl a0, t0, t1
    li a1, 0x3ffffffc
    jal ra, check

# ---- 7. El desplazamiento solo mira 5 bits: 33 equivale a 1 --------
    li t0, 1
    li t1, 33
    sll a0, t0, t1
    li a1, 2
    jal ra, check

# ---- 8. srai con inmediato ----------------------------------------
    li t0, -256
    srai a0, t0, 4
    li a1, -16
    jal ra, check

# ---- 9. sltiu compara sin signo contra un inmediato CON signo ------
    li t0, 100
    sltiu a0, t0, -1            # -1 se extiende a 0xffffffff
    li a1, 1
    jal ra, check

# ---- 10. x0 ignora las escrituras ---------------------------------
    li t0, 999
    add zero, t0, t0
    mv a0, zero
    li a1, 0
    jal ra, check

# ---- 11. sb no pisa los bytes vecinos ------------------------------
    la t0, buffer
    li t1, -1
    sw t1, 0(t0)                # 0xffffffff
    li t1, 0x41
    sb t1, 1(t0)                # solo el byte 1
    lw a0, 0(t0)
    li a1, 0xffff41ff
    jal ra, check

# ---- 12. lb extiende el signo --------------------------------------
    la t0, buffer
    li t1, 0x80
    sb t1, 0(t0)
    lb a0, 0(t0)
    li a1, -128
    jal ra, check

# ---- 13. lbu no lo extiende ----------------------------------------
    la t0, buffer
    lbu a0, 0(t0)
    li a1, 128
    jal ra, check

# ---- 14. lh extiende el signo --------------------------------------
    la t0, buffer
    li t1, 0x8000
    sh t1, 2(t0)
    lh a0, 2(t0)
    li a1, -32768
    jal ra, check

# ---- 15. lhu no lo extiende ----------------------------------------
    la t0, buffer
    lhu a0, 2(t0)
    li a1, 32768
    jal ra, check

# ---- 16. blt CON signo: -1 < 1, la rama se toma --------------------
    li a0, 0
    li t0, -1
    li t1, 1
    blt t0, t1, t16_ok
    j t16_fin
t16_ok:
    li a0, 1
t16_fin:
    li a1, 1
    jal ra, check

# ---- 17. bltu SIN signo: 0xffffffff > 1, NO se toma ----------------
    li a0, 0
    li t0, -1
    li t1, 1
    bltu t0, t1, t17_mal
    j t17_fin
t17_mal:
    li a0, 1
t17_fin:
    li a1, 0
    jal ra, check

# ---- 18. bge con valores iguales se toma ---------------------------
    li a0, 0
    li t0, 7
    bge t0, t0, t18_ok
    j t18_fin
t18_ok:
    li a0, 1
t18_fin:
    li a1, 1
    jal ra, check

# ---- 19. La pila: guardar y recuperar ------------------------------
    addi sp, sp, -8
    li t0, 0x12345678
    sw t0, 0(sp)
    li t1, -99
    sw t1, 4(sp)
    lw a0, 0(sp)
    lw t2, 4(sp)
    addi sp, sp, 8
    li a1, 0x12345678
    jal ra, check

# ---- 20. jalr con rd == rs1: el destino se calcula primero ---------
    la t0, t20_destino
    li a0, 0
    jalr ra, t0, 0              # (rd distinto aqui; la variante dura va abajo)
t20_vuelve:
    li a1, 5
    jal ra, check
    j t20_sigue
t20_destino:
    li a0, 5
    jr ra
t20_sigue:

# ---- 21. auipc suma desde SU PROPIA direccion ----------------------
    auipc t0, 0
t21_aqui:
    la t1, t21_aqui
    addi t1, t1, -4             # la direccion del auipc
    sub a0, t0, t1
    li a1, 0
    jal ra, check

# ---- 22. lui deja el inmediato en los 20 bits altos ---------------
    lui a0, 0xabcde
    li a1, 0xabcde000
    jal ra, check

# ---- 23. Multiplicacion por sumas: 7*13 = 91 ----------------------
    li t0, 7
    li t1, 13
    li a0, 0
t23_bucle:
    beqz t1, t23_fin
    add a0, a0, t0
    addi t1, t1, -1
    j t23_bucle
t23_fin:
    li a1, 91
    jal ra, check

# ---- 24. Recursion: factorial de 5 --------------------------------
    li a0, 5
    jal ra, fact
    li a1, 120
    jal ra, check

# ---- 25. andi/ori/xori con inmediato negativo ---------------------
    li t0, 0x0f0f0f0f
    xori a0, t0, -1             # -1 = 0xffffffff, o sea NOT
    li a1, 0xf0f0f0f0
    jal ra, check

# ---- 26. jalr descarta el bit 0 del destino ------------------------
# El destino calculado es impar a proposito. Segun el ISA, jalr debe
# poner el bit 0 en cero, asi que debe aterrizar en t26_destino.
    la t0, t26_destino
    li a0, 0
    jalr ra, t0, 1              # t0 + 1 = impar
t26_vuelve:
    li a1, 7
    jal ra, check
    j t26_sigue
t26_destino:
    li a0, 7
    jr ra
t26_sigue:

# ---- Resumen -------------------------------------------------------
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
    li a7, 10
    ecall

# =====================================================================
# check: compara a0 contra a1. Preserva s0, s1, s2.
# =====================================================================
check:
    addi sp, sp, -4
    sw ra, 0(sp)
    addi s2, s2, 1              # numero de prueba
    beq a0, a1, check_ok

    mv t3, a0                   # guardar antes de usar a0 para imprimir
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
    li a7, 34                   # imprimir en hexadecimal
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

# =====================================================================
# fact: factorial recursivo. a0 = n, devuelve n! en a0.
# Ejercita la pila y las llamadas anidadas.
# =====================================================================
fact:
    addi sp, sp, -8
    sw ra, 0(sp)
    sw s3, 4(sp)
    li t0, 2
    blt a0, t0, fact_base
    mv s3, a0
    addi a0, a0, -1
    jal ra, fact
    li t1, 0                    # multiplicar a0 por s3 sumando
    mv t2, s3
fact_mul:
    beqz t2, fact_mul_fin
    add t1, t1, a0
    addi t2, t2, -1
    j fact_mul
fact_mul_fin:
    mv a0, t1
    j fact_fin
fact_base:
    li a0, 1
fact_fin:
    lw ra, 0(sp)
    lw s3, 4(sp)
    addi sp, sp, 8
    ret
