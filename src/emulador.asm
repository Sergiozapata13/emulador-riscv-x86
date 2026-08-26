DEFAULT ABS

section .data
    ; Archivos para leer el código y datos de RISC-V
    filename_text db 'punto_text_hex.txt', 0    ; Nombre del archivo para .text
    filename_data db 'punto_data_hex.txt', 0    ; Nombre del archivo para .data
    
    ; --- Soporte de traza y errores ---
    hex_digits   db '0123456789abcdef'
    trace_buf    db 'PC=0x00000000  INSTR=0x00000000', 10
    trace_len    equ $ - trace_buf
    msg_open     db 'ERROR: no se pudo abrir el archivo (revise el directorio)', 10
    msg_open_len equ $ - msg_open
    msg_unimpl   db 'STOP: opcode no implementado en PC=0x00000000 INSTR=0x00000000', 10
    msg_unimpl_len equ $ - msg_unimpl
    trace_on     db 1        ; ponga 0 para desactivar la traza

    ; Mensaje de error de memoria. Los campos llevan etiqueta propia para
    ; no tener que contar desplazamientos a mano.
    msg_mem      db 'ERROR: acceso a memoria invalido en 0x'
    mem_addr_f   db '00000000'
                 db '  (PC=0x'
    mem_pc_f     db '00000000'
                 db ')', 10
    msg_mem_len  equ $ - msg_mem

    ; Linea del volcado de registros
    ; Mnemonicos en campos fijos de 6 bytes
    mn_add       db 'add   '
    mn_sub       db 'sub   '
    mn_sll       db 'sll   '
    mn_slt       db 'slt   '
    mn_sltu      db 'sltu  '
    mn_xor       db 'xor   '
    mn_srl       db 'srl   '
    mn_sra       db 'sra   '
    mn_or        db 'or    '
    mn_and       db 'and   '
    mn_addi      db 'addi  '
    mn_slli      db 'slli  '
    mn_slti      db 'slti  '
    mn_sltiu     db 'sltiu '
    mn_xori      db 'xori  '
    mn_srli      db 'srli  '
    mn_srai      db 'srai  '
    mn_ori       db 'ori   '
    mn_andi      db 'andi  '
    mn_lb        db 'lb    '
    mn_lh        db 'lh    '
    mn_lw        db 'lw    '
    mn_lbu       db 'lbu   '
    mn_lhu       db 'lhu   '
    mn_sb        db 'sb    '
    mn_sh        db 'sh    '
    mn_sw        db 'sw    '
    mn_beq       db 'beq   '
    mn_bne       db 'bne   '
    mn_blt       db 'blt   '
    mn_bge       db 'bge   '
    mn_bltu      db 'bltu  '
    mn_bgeu      db 'bgeu  '
    mn_jal       db 'jal   '
    mn_jalr      db 'jalr  '
    mn_lui       db 'lui   '
    mn_auipc     db 'auipc '
    mn_ecall     db 'ecall '
    mn_unk       db '?     '
    mn_relleno   db '        '   ; holgura: los nombres se copian de 8 en 8

    ; Advertencia de truncamiento
    msg_adv1     db 'ADVERTENCIA: volcado '
    msg_adv1_len equ $ - msg_adv1
    msg_adv2     db ' truncado: se cargaron '
    msg_adv2_len equ $ - msg_adv2
    msg_adv3     db ' de '
    msg_adv3_len equ $ - msg_adv3
    msg_adv4     db ' palabras. Aumente la constante correspondiente.', 10
    msg_adv4_len equ $ - msg_adv4
    nom_text     db '.text'
    nom_data     db '.data'

    ; --- Video: secuencias ANSI ---
    ; Los prefijos miden 7 bytes pero se copian de 8 en 8 con un solo
    ; `mov rax`; el byte sobrante lo pisa lo que se escriba despues.
    esc_fg       db 0x1B,'[','3','8',';','2',';'
    esc_bg       db 0x1B,'[','4','8',';','2',';'
    esc_eol      db 0x1B,'[','0','m',10
    esc_init     db 0x1B,'[','2','J',0x1B,'[','H',0x1B,'[','?','2','5','l'
    esc_init_len equ $ - esc_init
    esc_fin      db 0x1B,'[','0','m',0x1B,'[','?','2','5','h',10
    esc_fin_len  equ $ - esc_fin

    ; Buffers de los syscalls
    hexout       db '0x'
    hexout_f     db '00000000'
    hexout_len   equ $ - hexout
    msg_ecall    db 'STOP: ecall no implementado a7=0x'
    ecall_num_f  db '00000000'
                 db 10
    msg_ecall_len equ $ - msg_ecall

    reg_line     db 'x'
    reg_idx_f    db '00'
                 db ' = 0x'
    reg_val_f    db '00000000', 10
    reg_line_len equ $ - reg_line

    ; Constantes y tamaños
    hex_length equ 8                            ; Longitud de cada cadena hexadecimal
    buffer_size equ 9                           ; Tamaño del buffer para leer del archivo
    num_instructions equ 16384                   ; holgura para volcados grandes
    file_buf_size  equ 262144                   ; holgura para cualquier volcado
    max_data_lines equ 8192                     ; holgura para volcados grandes

    ; ===========================================================
    ;  MAPA DE MEMORIA emulado (direcciones RISC-V, no del host)
    ; ===========================================================
    TEXT_BASE   equ 0x00400000
    TEXT_END    equ TEXT_BASE + 4*num_instructions
    FB_BASE     equ 0x10008000              ; framebuffer, base de gp
    FB_VISIBLE  equ 2048                    ; 64x32 unidades: lo que se dibuja
    ; En RARS el segmento de datos cubre toda la region desde 0x10000000,
    ; asi que escribir mas alla del area visible aterriza en memoria valida
    ; y simplemente no se muestra. La region se extiende hasta DATA_BASE
    ; para reproducir ese comportamiento: si el emulador abortara donde
    ; RARS no lo hace, no estaria emulando RARS.
    FB_WORDS    equ 8192                    ; hasta 0x10010000
    FB_END      equ FB_BASE + 4*FB_WORDS
    DATA_BASE   equ 0x10010000              ; verificado con 3 accesos del listado de RARS
    DATA_END    equ DATA_BASE + 4*max_data_lines
    STACK_WORDS equ 4096                    ; 16 KB de pila
    STACK_END   equ 0x7FFFF000              ; sp arranca en 0x7FFFEFFC, crece hacia abajo
    STACK_BASE  equ STACK_END - 4*STACK_WORDS
    MMIO_BASE   equ 0xFFFF0000              ; 0xFFFF0000 estado, 0xFFFF0004 tecla
    MMIO_END    equ 0xFFFF0010

    ; Banco de registros RISC-V (no inicializa valores, solo define índices)
    zero    equ 0   ; x0: The constant value 0
    ra      equ 1   ; x1: Return address
    spp     equ 2   ; x2: Stack pointer
    gp      equ 3   ; x3: Global pointer
    tp      equ 4   ; x4: Thread pointer
    t0      equ 5   ; x5: Temporaries
    t1      equ 6   ; x6: Temporaries
    t2      equ 7   ; x7: Temporaries
    s0_fp   equ 8   ; x8: Saved register/Frame pointer
    s1      equ 9   ; x9: Saved register
    a0      equ 10  ; x10: Function arguments/Return values
    a1      equ 11  ; x11: Function arguments/Return values
    a2      equ 12  ; x12: Function arguments
    a3      equ 13  ; x13: Function arguments
    a4      equ 14  ; x14: Function arguments
    a5      equ 15  ; x15: Function arguments
    a6      equ 16  ; x16: Function arguments
    a7      equ 17  ; x17: Function arguments
    s2      equ 18  ; x18: Saved registers
    s3      equ 19  ; x19: Saved registers
    s4      equ 20  ; x20: Saved registers
    s5      equ 21  ; x21: Saved registers
    s6      equ 22  ; x22: Saved registers
    s7      equ 23  ; x23: Saved registers
    s8      equ 24  ; x24: Saved registers
    s9      equ 25  ; x25: Saved registers
    s10     equ 26  ; x26: Saved registers
    s11     equ 27  ; x27: Saved registers
    t3      equ 28  ; x28: Temporaries
    t4      equ 29  ; x29: Temporaries
    t5      equ 30  ; x30: Temporaries
    t6      equ 31  ; x31: Temporaries

section .bss
    ; Buffer y variables para la lectura de archivos
    buffer resb buffer_size                   ; Buffer para leer el contenido del archivo
    bytes_read resq 1                         ; Variable para almacenar el número de bytes leídos
    
    ; Memoria para almacenar instrucciones y datos convertidos de RISC-V
    text_memory resd num_instructions         ; Arreglo para almacenar .text convertido (no inicializa)
    data_memory resd max_data_lines           ; Arreglo para almacenar .data convertido (no inicializa)
    
    ; Posiciones y contadores para procesamiento de archivos
    text_memory_pos resq 1                    ; Posición actual en text_memory
    data_memory_pos resq 1                    ; Posición actual en data_memory
    data_line_count resq 1                    ; Contador de líneas procesadas

    ; Regiones de memoria emulada
    framebuffer resd FB_WORDS                 ; 0x10008000
    stack_mem   resd STACK_WORDS              ; 0x7FFFB000
    hex_total   resq 1                        ; palabras halladas en el volcado
    hex_cargadas resq 1                       ; palabras que cupieron
    file_buf    resb file_buf_size            ; el volcado completo se lee aqui
    text_path   resq 1                        ; ruta del volcado .text (argumento o por omision)
    data_path   resq 1                        ; ruta del volcado .data
    instr_count resq 1                        ; instrucciones ejecutadas (contadores CSR)
    t2_sec      resq 1                        ; timespec para clock_gettime
    t2_nsec     resq 1                        ; debe ir inmediatamente despues
    trace_fd    resq 1                        ; descriptor de la traza (1 = stdout)
    trace_line  resb 128                      ; la linea desensamblada se arma aqui
    d_rd        resd 1                        ; campos para el desensamblador,
    d_rs1       resd 1                        ; separados de los de la ejecucion
    d_rs2       resd 1
    d_f3        resd 1
    d_f7        resd 1
    termios_orig resb 60                      ; struct termios de Linux
    termios_raw  resb 60
    stdin_flags resq 1                        ; banderas originales de stdin
    term_ready  resd 1                        ; 1 si la terminal esta en modo crudo
    video_buf   resb 65536                    ; un cuadro completo se arma aqui
    fb_dirty    resd 1                        ; 1 si algun sw toco el framebuffer
    video_init  resd 1                        ; 1 si ya se preparo la terminal
    char_buf    resb 1                        ; un byte para print/read char
    int_buf     resb 32                       ; formateo y lectura de enteros
    ts_sec      resq 1                        ; struct timespec para nanosleep
    ts_nsec     resq 1                        ; debe ir inmediatamente despues
    key_status  resd 1                        ; 0xFFFF0000
    key_data    resd 1                        ; 0xFFFF0004

    ; Banco de registros de RISC-V
    registers resd 33                         ; Banco de 32 registros, cada uno de 4 bytes (32 bits) + el campo para PC

    ; Variables para guardar campos decodificados
    opcode resd 1
    rd resd 1
    rs1 resd 1
    rs2 resd 1
    funct3 resd 1
    funct7 resd 1
    imm resd 1

section .text
    global _start

_start:
    ; Al entrar, rsp apunta a argc y justo detras viene el arreglo argv.
    ; Se capturan AHORA, antes de cualquier `call`: despues la pila se
    ; mueve, pero r14/r15 guardan direcciones absolutas y siguen validas.
    ;
    ;   -q            no generar la traza
    ;   -t <archivo>  mandar la traza a su propio archivo
    ;
    ; La opcion -t existe porque hay tres flujos (salida del programa
    ; emulado, traza y video) y solo dos descriptores estandar. Con un
    ; descriptor propio para la traza, los tres quedan separados.
    mov qword [trace_fd], 1                   ; por omision, stdout
    lea rax, [filename_text]                  ; rutas por omision, para que
    mov [text_path], rax                      ; el emulador siga funcionando
    lea rax, [filename_data]                  ; sin argumentos
    mov [data_path], rax

    mov r14, [rsp]                            ; argc
    lea r15, [rsp + 8]                        ; &argv[0]
    mov rbx, 1                                ; argv[0] es el nombre: se salta
    xor r12d, r12d                            ; cuantos posicionales van
.arg_loop:
    cmp rbx, r14
    jae .arg_fin
    mov rsi, [r15 + rbx*8]

    cmp byte [rsi], '-'                       ; no empieza con guion: es una ruta
    jne .arg_posicional

    cmp word [rsi], '-q'                      ; NASM ya lo ordena little-endian
    jne .arg_t
    mov byte [trace_on], 0
    inc rbx
    jmp .arg_loop

.arg_t:
    cmp word [rsi], '-t'
    jne .arg_sig
    inc rbx                                   ; el nombre del archivo es el
    cmp rbx, r14                              ; argumento siguiente
    jae .arg_fin
    mov rdi, [r15 + rbx*8]
    mov rax, 2                                ; syscall: open
    mov rsi, 577                              ; O_WRONLY | O_CREAT | O_TRUNC
    mov rdx, 420                              ; permisos 0644 en decimal
    syscall
    cmp rax, 0
    jl .arg_sig                               ; si falla, la traza sigue en stdout
    mov [trace_fd], rax
    jmp .arg_sig

.arg_posicional:
    ; El primer posicional es el .text y el segundo el .data.
    test r12d, r12d
    jnz .arg_pos2
    mov [text_path], rsi
    inc r12d
    jmp .arg_sig
.arg_pos2:
    mov [data_path], rsi
    inc r12d

.arg_sig:
    inc rbx
    jmp .arg_loop
.arg_fin:

    ; Leer y procesar punto_text_hex.txt
    call read_text_file

    ; Leer y procesar punto_data_hex.txt
    call read_data_file

    ; Inicializar registros especiales
    mov rbx, registers

    ; Inicializar el stack pointer (spp) en 0x7fffeffc
    mov dword [rbx + spp*4], 0x7fffeffc

    ; Inicializar el global pointer (gp) en 0x10008000
    mov dword [rbx + gp*4], 0x10008000

    ; Inicializar el program counter (pc) en 0x400000
    pc equ 32    ; Índice adicional para pc
    mov dword [rbx + pc*4], 0x400000

    ; Inicialización de `zero` en 0
    mov dword [rbx + zero*4], 0

    ; Preparar la terminal para capturar teclas
    call term_init

    ; Llamada al bucle principal
    call main_loop

    call cleanup                              ; restaurar terminal y cerrar traza

    ; Salir del programa exitosamente
    mov rax, 60                               ; syscall: exit
    xor rdi, rdi                              ; estado de salida: 0
    syscall

main_loop:
; Bucle principal para recorrer `text_memory` usando el `pc`
.loop_start:
    ; Obtener el valor de `pc`
    mov rbx, registers
    mov eax, [rbx + pc*4]                     ; Cargar `pc` en eax
    mov r12d, eax                             ; Guardar el PC de ESTA instrucción

    ; El PC debe estar alineado a 4. Sin este chequeo un salto con
    ; destino impar se "arregla" solo al calcular el indice, y el error
    ; queda escondido. Las pruebas de mutacion destaparon este hueco.
    test eax, 3
    jz .pc_alineado
    mov r10d, eax
    jmp mem_error
.pc_alineado:

    ; Calcular el índice en `text_memory`
    sub eax, 0x400000                         ; Convertir `pc` a índice (base 0) en `text_memory`
    shr eax, 2                                ; Dividir por 4 para obtener índice de instrucción de 4 bytes

    ; Verificar si estamos fuera del rango de `text_memory`
    cmp eax, num_instructions
    jge .end_loop                             ; Si estamos fuera de rango, finalizar bucle

    ; Convertir `eax` a 64 bits para evitar conflictos
    movsxd rax, eax                           ; Extender `eax` a `rax` (sign-extend)

    ; Cargar la instrucción actual (4 bytes) desde `text_memory`
    mov rcx, text_memory                      ; Dirección base de `text_memory`
    mov edx, [rcx + rax*4]                    ; Cargar la instrucción de 4 bytes en edx
    mov r13d, edx                             ; Guardar la instrucción (r13 sobrevive a las llamadas)
    inc qword [instr_count]                   ; alimenta los contadores rdcycle/rdinstret

    call print_trace                          ; Imprimir PC e instrucción

    ; Avanzar el PC por defecto ANTES de ejecutar.
    ; Los saltos lo sobrescriben usando r12d (el PC viejo).
    mov rbx, registers
    add dword [rbx + pc*4], 4

    mov edx, r13d                             ; Restaurar la instrucción
    call decode_instruction

    jmp .loop_start                           ; Continuar el bucle

.end_loop:
    ret

; Función para decodificar una instrucción
; ===============================================================
;  Despachador por opcode
; ===============================================================
; Cadena de comparaciones ORDENADA POR FRECUENCIA DE EJECUCION real,
; medida contando opcodes en una corrida del Pong:
;
;   0x33 tipo R  37.5%   0x23 sw     15.4%   0x6F jal    14.3%
;   0x63 ramas   13.6%   0x13 addi   12.9%   0x67 jalr    3.5%
;   0x03 lw       2.2%   0x17 auipc   0.7%   0x37 lui, 0x73 ecall  <0.1%
;
; Se probo tambien una tabla de saltos indexada por opcode. Resulto un
; 4-8% MAS LENTA: en un bucle apretado los mismos opcodes se repiten, el
; predictor de saltos acierta estas comparaciones casi siempre y salen
; casi gratis, mientras que un salto indirecto cambia de destino en cada
; instruccion y cada fallo de prediccion cuesta unos quince ciclos.
; ---------------------------------------------------------------
decode_instruction:
    mov ecx, edx                   ; la instruccion completa
    and ecx, 0x7F                  ; opcode = bits 0-6
    mov dword [opcode], ecx        ; decode_u todavia lo consulta

    cmp ecx, 0x33                  ; tipo R y extension M
    je decode_r
    cmp ecx, 0x23                  ; almacenamientos
    je decode_s
    cmp ecx, 0x6F                  ; jal
    je decode_uj
    cmp ecx, 0x63                  ; ramas
    je decode_b
    cmp ecx, 0x13                  ; tipo I aritmetico
    je decode_i_alu
    cmp ecx, 0x67                  ; jalr
    je decode_jalr
    cmp ecx, 0x03                  ; cargas
    je decode_i_load
    cmp ecx, 0x17                  ; auipc
    je decode_u
    cmp ecx, 0x37                  ; lui
    je decode_u
    cmp ecx, 0x73                  ; ecall y CSR
    je decode_ecall

    jmp stop_unimplemented         ; opcode desconocido

; Decodificación del tipo `U`
decode_u:
    ; Extraer el opcode de `edx` (ya hecho en la función anterior)
    ; Aquí ya sabemos que el opcode es 0x17 (auipc) o 0x37 (lui)

    ; Extraer `rd` (bits 7-11)
    mov ecx, edx
    and ecx, 0xF80                 ; Aplicar la máscara para `rd`
    shr ecx, 7                     ; Desplazar a la derecha para obtener `rd`
    mov dword [rd], ecx            ; Guardar el valor de `rd`

    ; Extraer `imm[31:12]` (bits 12-31)
    mov ecx, edx
    and ecx, 0xFFFFF000            ; Aplicar la máscara para los bits del inmediato
    shr ecx, 12
    mov dword [imm], ecx           ; Guardar el inmediato 

    ; Comprobar si es auipc o lui
    cmp dword [opcode], 0x17        ; Comparar si es `auipc`
    je handle_auipc                ; Si es auipc, saltar a manejarlo

    cmp dword [opcode], 0x37        ; Comparar si es `lui`
    je handle_lui                  ; Si es lui, saltar a manejarlo

    ret                            ; Si no es ninguno, salir

handle_auipc:
    ; auipc: R[rd] = PC_de_esta_instruccion + (imm << 12)
    mov eax, r12d                  ; PC VIEJO, no el ya incrementado
    mov ecx, [imm]
    shl ecx, 12
    add eax, ecx
    mov ecx, [rd]
    call write_reg                 ; ecx = rd, eax = valor
    ret

handle_lui:
    ; lui: R[rd] = imm << 12
    mov eax, [imm]
    shl eax, 12
    mov ecx, [rd]
    call write_reg
    ret

; ---------------------------------------------------------------
; write_reg: escribe eax en R[ecx]. Ignora la escritura si ecx = 0
; (x0 esta cableado a cero en RISC-V). Usa direccionamiento de 64
; bits para evitar el prefijo addr32 que generaba `[ebx*4]`.
; ---------------------------------------------------------------
write_reg:
    test ecx, ecx
    jz .done
    mov r10d, ecx                  ; mov a 32 bits extiende con ceros a r10
    mov dword [registers + r10*4], eax
.done:
    ret


; Decodificación del tipo `R` (ej. `add`, `sub`)
decode_r:
    ; Extraer `rd` (bits 7-11)
    mov ecx, edx
    and ecx, 0xF80                 ; Aplicar la máscara para `rd`
    shr ecx, 7                     ; Desplazar para obtener el valor final
    mov dword [rd], ecx            ; Guardar en `rd`

    ; Extraer `funct3` (bits 12-14)
    mov ecx, edx
    and ecx, 0x7000                ; Aplicar la máscara para `funct3`
    shr ecx, 12                    ; Desplazar para obtener el valor final
    mov dword [funct3], ecx        ; Guardar en `funct3`

    ; Extraer `rs1` (bits 15-19)
    mov ecx, edx
    and ecx, 0xF8000               ; Aplicar la máscara para `rs1`
    shr ecx, 15                    ; Desplazar para obtener el valor final
    mov dword [rs1], ecx           ; Guardar en `rs1`

    ; Extraer `rs2` (bits 20-24)
    mov ecx, edx
    and ecx, 0x1F00000             ; Aplicar la máscara para `rs2`
    shr ecx, 20                    ; Desplazar para obtener el valor final
    mov dword [rs2], ecx           ; Guardar en `rs2`

    ; Extraer `funct7` (bits 25-31)
    mov ecx, edx
    and ecx, 0xFE000000            ; Aplicar la máscara para `funct7`
    shr ecx, 25                    ; Desplazar para obtener el valor final
    mov dword [funct7], ecx        ; Guardar en `funct7`

    ; ---- Ejecucion del tipo R ----
    ; Se cargan los dos operandos: r11d = R[rs1], eax = R[rs2]
    mov ecx, [rs1]
    call read_reg
    mov r11d, eax
    mov ecx, [rs2]
    call read_reg

    ; funct7 = 0x01 marca la extension M (multiplicacion y division)
    cmp dword [funct7], 1
    je .m_ext

    mov ecx, [funct3]
    cmp ecx, 0
    je .r_addsub
    cmp ecx, 1
    je .r_sll
    cmp ecx, 2
    je .r_slt
    cmp ecx, 3
    je .r_sltu
    cmp ecx, 4
    je .r_xor
    cmp ecx, 5
    je .r_shr
    cmp ecx, 6
    je .r_or
    cmp ecx, 7
    je .r_and
    jmp stop_unimplemented

.r_addsub:
    ; funct7 = 0x20 distingue sub de add. Es el unico bit que los separa.
    cmp dword [funct7], 0x20
    je .r_sub
    add r11d, eax
    jmp .r_store
.r_sub:
    sub r11d, eax
    jmp .r_store
.r_sll:
    ; los desplazamientos solo miran los 5 bits bajos del operando
    mov ecx, eax
    and ecx, 0x1F
    shl r11d, cl
    jmp .r_store
.r_slt:
    ; comparacion CON signo -> setl
    cmp r11d, eax
    setl r11b
    movzx r11d, r11b
    jmp .r_store
.r_sltu:
    ; comparacion SIN signo -> setb
    cmp r11d, eax
    setb r11b
    movzx r11d, r11b
    jmp .r_store
.r_xor:
    xor r11d, eax
    jmp .r_store
.r_shr:
    mov ecx, eax
    and ecx, 0x1F
    cmp dword [funct7], 0x20
    je .r_sra
    shr r11d, cl                   ; logico: mete ceros
    jmp .r_store
.r_sra:
    sar r11d, cl                   ; aritmetico: replica el bit de signo
    jmp .r_store
.r_or:
    or r11d, eax
    jmp .r_store
.r_and:
    and r11d, eax
.r_store:
    mov eax, r11d
    mov ecx, [rd]
    call write_reg
    ret

; ---------------------------------------------------------------
;  Extension RV32M. r11d = R[rs1], eax = R[rs2]
;
;  Las divisiones NO pueden delegarse a `idiv` sin mas: en x86 una
;  division entre cero o el desbordamiento de INT_MIN/-1 lanzan una
;  excepcion que tumbaria el proceso. RISC-V, en cambio, define
;  resultados concretos para esos casos y no lanza nada. Hay que
;  interceptarlos antes de llegar a la instruccion de division.
; ---------------------------------------------------------------
.m_ext:
    mov ecx, [funct3]
    cmp ecx, 0
    je .m_mul
    cmp ecx, 1
    je .m_mulh
    cmp ecx, 2
    je .m_mulhsu
    cmp ecx, 3
    je .m_mulhu
    cmp ecx, 4
    je .m_div
    cmp ecx, 5
    je .m_divu
    cmp ecx, 6
    je .m_rem
    cmp ecx, 7
    je .m_remu
    jmp stop_unimplemented

.m_mul:                            ; 32 bits bajos: el signo da igual
    imul r11d, eax
    jmp .r_store

.m_mulh:                           ; 32 altos, ambos CON signo
    movsxd r11, r11d
    movsxd rax, eax
    imul r11, rax
    shr r11, 32
    jmp .r_store

.m_mulhsu:                         ; 32 altos, rs1 con signo y rs2 sin signo
    movsxd r11, r11d
    imul r11, rax                  ; rax ya viene extendido con ceros
    shr r11, 32
    jmp .r_store

.m_mulhu:                          ; 32 altos, ambos SIN signo
    imul r11, rax                  ; los dos caben en 32 bits: el producto
    shr r11, 32                    ; entra completo en 64
    jmp .r_store

.m_div:                            ; division con signo
    test eax, eax
    jnz .m_div_ok
    mov r11d, -1                   ; division entre cero: todos unos
    jmp .r_store
.m_div_ok:
    cmp eax, -1
    jne .m_div_go
    cmp r11d, 0x80000000
    jne .m_div_go
    jmp .r_store                   ; INT_MIN / -1 desborda: devuelve INT_MIN
.m_div_go:
    mov ecx, eax
    mov eax, r11d
    cdq                            ; extiende el signo de eax en edx
    idiv ecx
    mov r11d, eax
    jmp .r_store

.m_rem:                            ; resto con signo, sigue al dividendo
    test eax, eax
    jz .r_store                    ; resto entre cero: el dividendo intacto
    cmp eax, -1
    jne .m_rem_go
    cmp r11d, 0x80000000
    jne .m_rem_go
    xor r11d, r11d                 ; INT_MIN %% -1 = 0
    jmp .r_store
.m_rem_go:
    mov ecx, eax
    mov eax, r11d
    cdq
    idiv ecx
    mov r11d, edx
    jmp .r_store

.m_divu:                           ; division sin signo
    test eax, eax
    jnz .m_divu_go
    mov r11d, -1
    jmp .r_store
.m_divu_go:
    mov ecx, eax
    mov eax, r11d
    xor edx, edx
    div ecx
    mov r11d, eax
    jmp .r_store

.m_remu:                           ; resto sin signo
    test eax, eax
    jz .r_store
    mov ecx, eax
    mov eax, r11d
    xor edx, edx
    div ecx
    mov r11d, edx
    jmp .r_store

; Decodificación del tipo `UJ` (ej. `jal`)
decode_uj:
    ; Extraer `rd` (bits 7-11)
    mov ecx, edx
    and ecx, 0xF80                 ; Aplicar la máscara para `rd`
    shr ecx, 7                     ; Desplazar para obtener el valor final
    mov dword [rd], ecx            ; Guardar en `rd`

    ; Extraer `imm[20]` (bit 31)
    mov ecx, edx
    and ecx, 0x80000000            ; Aplicar la máscara para `imm[20]`
    shr ecx, 31                    ; Desplazar para obtener `imm[20]`
    shl ecx, 20                    ; Recolocar `imm[20]` en su lugar
    mov dword [imm], ecx           ; Guardar `imm[20]` parcial

    ; Extraer `imm[10:1]` (bits 21-30)
    mov ecx, edx
    and ecx, 0x7FE00000            ; Aplicar la máscara para `imm[10:1]`
    shr ecx, 21                    ; Desplazar para obtener `imm[10:1]`
    shl ecx, 1                     ; Recolocar `imm[10:1]`
    or dword [imm], ecx            ; Combinar con `imm`

    ; Extraer `imm[11]` (bit 20)
    mov ecx, edx
    and ecx, 0x100000              ; Aplicar la máscara para `imm[11]`
    shr ecx, 20                    ; Desplazar para obtener `imm[11]`
    shl ecx, 11                    ; Recolocar `imm[11]`
    or dword [imm], ecx            ; Combinar con `imm`

    ; Extraer `imm[19:12]` (bits 12-19)
    mov ecx, edx
    and ecx, 0xFF000               ; Aplicar la máscara para `imm[19:12]`
    shr ecx, 12                    ; Desplazar para obtener `imm[19:12]`
    shl ecx, 12                    ; Recolocar `imm[19:12]`
    or dword [imm], ecx            ; Combinar con `imm`

    ; Extension de signo del inmediato de 21 bits (bit 20 es el signo).
    ; Sin esto, todo salto hacia atras se vuelve un offset positivo enorme.
    mov ecx, [imm]
    shl ecx, 11
    sar ecx, 11                          ; sar = desplazamiento ARITMETICO
    mov dword [imm], ecx

    ; Direccion de retorno = PC_de_esta_instruccion + 4
    mov eax, r12d                        ; PC VIEJO
    add eax, 4
    mov ecx, [rd]
    call write_reg                       ; write_reg ya ignora rd = x0

skip_save_ra:
    ; Destino = PC_de_esta_instruccion + imm  (el imm ya viene escalado)
    mov eax, r12d                        ; PC VIEJO, no el incrementado
    mov ecx, [imm]
    add eax, ecx
    mov rbx, registers
    mov dword [rbx + pc*4], eax          ; Sobrescribe el PC += 4 del bucle

    ret

; ===============================================================
;  Carga de los volcados hexadecimales
; ===============================================================
; El lector original tomaba el archivo en trozos de 9 bytes, justo el
; tamano de "8 digitos + salto de linea". Funcionaba de milagro: con
; CRLF, con espacios o con una lectura parcial se desincronizaba y
; perdia los digitos a medio acumular.
;
; Aqui se lee el archivo COMPLETO a un buffer y despues se parsea. Eso
; elimina de raiz toda esa clase de fallo, y de paso permite aceptar
; mayusculas, minusculas, CRLF y cualquier espaciado.
; ---------------------------------------------------------------

; cargar_archivo: rdi = ruta, rsi = buffer, rdx = capacidad
;                 devuelve rax = bytes leidos
cargar_archivo:
    push rbx
    push r12
    push r13
    push r14
    mov r12, rsi                              ; buffer
    mov r13, rdx                              ; capacidad
    mov rax, 2                                ; syscall: open
    xor rsi, rsi                              ; O_RDONLY
    xor rdx, rdx
    syscall
    cmp rax, 0
    jl open_error
    mov r14, rax                              ; descriptor
    xor rbx, rbx                              ; total acumulado
.leer:
    mov rdx, r13
    sub rdx, rbx                              ; espacio restante
    jz .cerrar
    xor rax, rax                              ; syscall: read
    mov rdi, r14
    lea rsi, [r12 + rbx]
    syscall
    cmp rax, 0
    jle .cerrar                               ; 0 = fin de archivo
    add rbx, rax
    jmp .leer
.cerrar:
    mov rax, 3                                ; syscall: close
    mov rdi, r14
    syscall
    mov rax, rbx
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

; parsear_hex: rsi = buffer, rcx = longitud, rdi = destino, r9 = maximo
; Acumula digitos hexadecimales; cualquier caracter que no lo sea cierra
; la palabra en curso. Asi no importa como esten separadas las lineas.
parsear_hex:
    xor r8, r8                                ; palabras escritas
    xor r10, r10                              ; acumulador
    xor r11, r11                              ; digitos acumulados
    mov qword [hex_total], 0                  ; palabras HALLADAS, quepan o no
.ph:
    test rcx, rcx
    jz .final
    movzx rax, byte [rsi]
    inc rsi
    dec rcx
    cmp al, '0'
    jb .sep
    cmp al, '9'
    jbe .d09
    cmp al, 'A'
    jb .sep
    cmp al, 'F'
    jbe .dAF
    cmp al, 'a'
    jb .sep
    cmp al, 'f'
    ja .sep
    sub al, 'a' - 10                          ; minusculas
    jmp .acum
.dAF:
    sub al, 'A' - 10                          ; MAYUSCULAS (asi vuelca RARS)
    jmp .acum
.d09:
    sub al, '0'
.acum:
    shl r10, 4
    or r10, rax
    inc r11
    cmp r11, 8
    jb .ph
    call .emitir                              ; palabra completa
    jmp .ph
.sep:
    test r11, r11                             ; separador: cerrar lo acumulado
    jz .ph
    call .emitir
    jmp .ph
.final:
    test r11, r11
    jz .listo
    call .emitir                              ; ultima linea sin salto final
.listo:
    mov [hex_cargadas], r8
    ret
.emitir:
    inc qword [hex_total]                     ; se cuenta siempre, quepa o no
    cmp r8, r9
    jae .descartar                            ; no desbordar el arreglo
    mov [rdi + r8*4], r10d
    inc r8
.descartar:
    xor r10, r10
    xor r11, r11
    ret

; e_str: copia rcx bytes de [rsi] a [rdi], avanzando rdi
e_str:
    test rcx, rcx
    jz .es_fin
.es_loop:
    mov al, [rsi]
    mov [rdi], al
    inc rsi
    inc rdi
    dec rcx
    jnz .es_loop
.es_fin:
    ret

; advertir_trunc: rsi = nombre del segmento (5 bytes).
; Avisa por stderr que el volcado no cupo entero. Sin esto el emulador
; descartaba instrucciones en silencio y el programa terminaba solo, sin
; error visible: el peor tipo de fallo.
advertir_trunc:
    push r14
    mov r14, rsi
    lea rdi, [trace_line]
    lea rsi, [msg_adv1]
    mov rcx, msg_adv1_len
    call e_str
    mov rsi, r14
    mov rcx, 5
    call e_str
    lea rsi, [msg_adv2]
    mov rcx, msg_adv2_len
    call e_str
    mov eax, dword [hex_cargadas]
    call e_dec
    lea rsi, [msg_adv3]
    mov rcx, msg_adv3_len
    call e_str
    mov eax, dword [hex_total]
    call e_dec
    lea rsi, [msg_adv4]
    mov rcx, msg_adv4_len
    call e_str

    lea rsi, [trace_line]
    mov rdx, rdi
    sub rdx, rsi
    mov rax, 1
    mov rdi, 2                                ; stderr
    syscall
    pop r14
    ret

read_text_file:
    mov rdi, [text_path]
    lea rsi, [file_buf]
    mov rdx, file_buf_size
    call cargar_archivo
    mov rcx, rax
    lea rsi, [file_buf]
    lea rdi, [text_memory]
    mov r9, num_instructions
    call parsear_hex
    mov rax, [hex_total]
    cmp rax, [hex_cargadas]
    jbe .t_ok
    lea rsi, [nom_text]
    call advertir_trunc
.t_ok:
    ret

read_data_file:
    mov rdi, [data_path]
    lea rsi, [file_buf]
    mov rdx, file_buf_size
    call cargar_archivo
    mov rcx, rax
    lea rsi, [file_buf]
    lea rdi, [data_memory]
    mov r9, max_data_lines
    call parsear_hex
    mov rax, [hex_total]
    cmp rax, [hex_cargadas]
    jbe .d_ok
    lea rsi, [nom_data]
    call advertir_trunc
.d_ok:
    ret

; ===============================================================
;  Rutinas de soporte: traza, errores e impresion hexadecimal
; ===============================================================

; put_hex8: escribe eax como 8 digitos hex ASCII en [rdi].
; Clobbers: rax, rcx, r9, r10, rdi
put_hex8:
    mov rcx, 8
.ph_loop:
    rol eax, 4                     ; trae el nibble mas alto abajo
    mov r10d, eax
    and r10d, 0xF
    mov r9b, [hex_digits + r10]
    mov [rdi], r9b
    inc rdi
    dec rcx
    jnz .ph_loop
    ret                            ; 8 rol de 4 bits dejan eax como estaba

; print_trace: desensambla la instruccion y la imprime.
; El enunciado pide que cada instruccion ejecutada salga en consola con
; todos sus detalles y su PC. Se desensambla aqui, ANTES de ejecutar, y
; usando campos propios (d_*) para no interferir con los que usa la
; ejecucion.
print_trace:
    cmp byte [trace_on], 0
    je .pt_done
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    push r8
    push r9
    push r10
    push r11

    call disasm                    ; deja la linea en trace_line, rdi al final

    lea rsi, [trace_line]
    mov rdx, rdi
    sub rdx, rsi                   ; longitud real de la linea
    mov rax, 1
    mov rdi, [trace_fd]            ; stdout, o el archivo indicado con -t
    syscall

    pop r11
    pop r10
    pop r9
    pop r8
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
.pt_done:
    ret

; stop_unimplemented: opcode desconocido -> avisa y sale con codigo 2
stop_unimplemented:
    call cleanup
    mov eax, r12d
    lea rdi, [msg_unimpl + 37]
    call put_hex8
    mov eax, r13d
    lea rdi, [msg_unimpl + 54]
    call put_hex8

    mov rax, 1
    mov rdi, 1
    mov rsi, msg_unimpl
    mov rdx, msg_unimpl_len
    syscall

    call dump_registers

    mov rax, 60
    mov rdi, 2
    syscall

; open_error: el archivo no existe o no se puede leer
open_error:
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_open
    mov rdx, msg_open_len
    syscall
    mov rax, 60
    mov rdi, 3
    syscall

; ===============================================================
;  ETAPA 1: subsistema de memoria
; ===============================================================
; La memoria emulada NO es un solo arreglo. Las direcciones RISC-V
; van de 0x00400000 a 0xFFFF0004, un espacio de 4 GB del que solo
; unas pocas ventanas existen de verdad. mem_read y mem_write son
; el decodificador: traducen una direccion RISC-V al arreglo del
; host que le corresponde, o abortan con un error legible.
;
; Es la misma resta y division entre 4 que ya hace el fetch, pero
; generalizada a cinco regiones en vez de una sola.
; ---------------------------------------------------------------

; read_reg: eax = R[ecx].  x0 siempre vale 0 porque .bss arranca en
; cero y write_reg nunca lo escribe.
read_reg:
    mov r10d, ecx
    mov eax, [registers + r10*4]
    ret

; ---------------------------------------------------------------
; mem_read:  entrada eax = direccion,  salida eax = palabra leida
; mem_write: entrada eax = direccion,  ecx = valor a escribir
; Ambas usan r10 y r11 como temporales.
; Las comparaciones son SIN signo (jb/jae) porque 0xFFFF0000 como
; entero con signo seria negativo y el rango no cuadraria.
; ---------------------------------------------------------------
mem_read:
    mov r10d, eax
    test r10d, 3                   ; toda lectura de palabra debe estar alineada
    jnz mem_error

    cmp r10d, TEXT_BASE
    jb .rd_fb
    cmp r10d, TEXT_END
    jae .rd_fb
    sub r10d, TEXT_BASE
    shr r10d, 2
    mov eax, [text_memory + r10*4]
    ret
.rd_fb:
    cmp r10d, FB_BASE
    jb .rd_data
    cmp r10d, FB_END
    jae .rd_data
    sub r10d, FB_BASE
    shr r10d, 2
    mov eax, [framebuffer + r10*4]
    ret
.rd_data:
    cmp r10d, DATA_BASE
    jb .rd_stack
    cmp r10d, DATA_END
    jae .rd_stack
    sub r10d, DATA_BASE
    shr r10d, 2
    mov eax, [data_memory + r10*4]
    ret
.rd_stack:
    cmp r10d, STACK_BASE
    jb .rd_mmio
    cmp r10d, STACK_END
    jae .rd_mmio
    sub r10d, STACK_BASE
    shr r10d, 2
    mov eax, [stack_mem + r10*4]
    ret
.rd_mmio:
    call poll_key                  ; el juego consulta el MMIO: es el momento
    cmp r10d, MMIO_BASE            ; natural para mirar si hay tecla pendiente
    jb mem_error
    cmp r10d, MMIO_END
    jae mem_error
    cmp r10d, MMIO_BASE
    jne .rd_key
    mov eax, [key_status]          ; 1 si hay tecla pendiente
    ret
.rd_key:
    cmp r10d, MMIO_BASE + 4
    jne .rd_zero
    mov eax, [key_data]
    mov dword [key_status], 0      ; leer la tecla la consume
    ret
.rd_zero:
    xor eax, eax
    ret

mem_write:
    mov r10d, eax
    test r10d, 3
    jnz mem_error

    cmp r10d, TEXT_BASE            ; escribir sobre .text = codigo automodificable.
    jb .wr_fb                      ; No se admite: casi siempre es un puntero
    cmp r10d, TEXT_END             ; descarriado, y es mejor verlo que corromper
    jb mem_error                   ; la memoria de programa en silencio.
.wr_fb:
    cmp r10d, FB_BASE
    jb .wr_data
    cmp r10d, FB_END
    jae .wr_data
    sub r10d, FB_BASE
    shr r10d, 2
    mov dword [framebuffer + r10*4], ecx
    mov dword [fb_dirty], 1        ; hay que repintar en el proximo ecall
    ret
.wr_data:
    cmp r10d, DATA_BASE
    jb .wr_stack
    cmp r10d, DATA_END
    jae .wr_stack
    sub r10d, DATA_BASE
    shr r10d, 2
    mov dword [data_memory + r10*4], ecx
    ret
.wr_stack:
    cmp r10d, STACK_BASE
    jb .wr_mmio
    cmp r10d, STACK_END
    jae .wr_mmio
    sub r10d, STACK_BASE
    shr r10d, 2
    mov dword [stack_mem + r10*4], ecx
    ret
.wr_mmio:
    cmp r10d, MMIO_BASE
    jb mem_error
    cmp r10d, MMIO_END
    jae mem_error
    ret                            ; escrituras a MMIO: se ignoran por ahora

; ===============================================================
;  Cargas (tipo I) y almacenamientos (tipo S)
; ===============================================================
; Tipo I:  imm[11:0] = instr[31:20]
; El truco esta en `sar ecx, 20`: un desplazamiento ARITMETICO de 20
; bits deja el inmediato en la parte baja Y replica el bit 31 hacia
; arriba, o sea que hace la extension de signo gratis, en un solo
; paso. Con `shr` los desplazamientos negativos saldrian mal.
; ---------------------------------------------------------------
decode_i_load:
    mov ecx, edx
    shr ecx, 7
    and ecx, 0x1F
    mov dword [rd], ecx

    mov ecx, edx
    shr ecx, 12
    and ecx, 7
    mov dword [funct3], ecx

    mov ecx, edx
    shr ecx, 15
    and ecx, 0x1F
    mov dword [rs1], ecx

    mov ecx, edx
    sar ecx, 20                    ; inmediato con extension de signo
    mov dword [imm], ecx

    mov ecx, [rs1]
    call read_reg                  ; eax = R[rs1]
    add eax, [imm]                 ; direccion efectiva = R[rs1] + imm

    mov ecx, [funct3]
    cmp ecx, 2
    je .l_w
    cmp ecx, 0
    je .l_b
    cmp ecx, 1
    je .l_h
    cmp ecx, 4
    je .l_bu
    cmp ecx, 5
    je .l_hu
    jmp stop_unimplemented

.l_w:                              ; lw: palabra completa
    call mem_read
    jmp .l_guardar
.l_bu:                             ; lbu: byte SIN signo
    call mem_read_byte
    jmp .l_guardar
.l_b:                              ; lb: byte CON signo
    call mem_read_byte
    movsx eax, al                  ; replica el bit 7 hacia arriba
    jmp .l_guardar
.l_hu:                             ; lhu: media palabra SIN signo
    call mem_read_half
    jmp .l_guardar
.l_h:                              ; lh: media palabra CON signo
    call mem_read_half
    movsx eax, ax                  ; replica el bit 15 hacia arriba
.l_guardar:
    mov ecx, [rd]
    call write_reg
    ret

; Tipo S: el inmediato viene partido en dos trozos.
;   imm[11:5] = instr[31:25]   imm[4:0] = instr[11:7]
; Se arma el trozo alto con `sar 25` (que ya extiende el signo),
; se corre 5 bits a la izquierda y se le pega el trozo bajo.
decode_s:
    mov ecx, edx
    shr ecx, 12
    and ecx, 7
    mov dword [funct3], ecx

    mov ecx, edx
    shr ecx, 15
    and ecx, 0x1F
    mov dword [rs1], ecx

    mov ecx, edx
    shr ecx, 20
    and ecx, 0x1F
    mov dword [rs2], ecx

    mov ecx, edx
    sar ecx, 25                    ; imm[11:5] con signo
    shl ecx, 5
    mov r11d, edx
    shr r11d, 7
    and r11d, 0x1F                 ; imm[4:0]
    or ecx, r11d
    mov dword [imm], ecx

    mov ecx, [rs1]
    call read_reg
    add eax, [imm]                 ; direccion efectiva
    mov r11d, eax                  ; guardarla: read_reg pisa eax
    mov ecx, [rs2]
    call read_reg                  ; eax = valor a escribir
    mov ecx, eax
    mov eax, r11d

    mov r11d, [funct3]
    cmp r11d, 2
    je .s_w
    cmp r11d, 0
    je .s_b
    cmp r11d, 1
    je .s_h
    jmp stop_unimplemented
.s_w:
    call mem_write
    ret
.s_b:
    call mem_write_byte
    ret
.s_h:
    call mem_write_half
    ret

; ===============================================================
;  Impresion y diagnostico
; ===============================================================
; put_hex2: escribe el byte bajo de eax como 2 digitos hex en [rdi]
put_hex2:
    mov r10d, eax
    shr r10d, 4
    and r10d, 0xF
    mov r9b, [hex_digits + r10]
    mov [rdi], r9b
    mov r10d, eax
    and r10d, 0xF
    mov r9b, [hex_digits + r10]
    mov [rdi + 1], r9b
    ret

; dump_registers: vuelca los 32 registros. Se llama al abortar, para
; ver en que estado quedo la maquina emulada.
dump_registers:
    xor r14d, r14d
.dr_loop:
    mov eax, r14d
    lea rdi, [reg_idx_f]
    call put_hex2
    mov r10d, r14d
    mov eax, [registers + r10*4]
    lea rdi, [reg_val_f]
    call put_hex8

    mov rax, 1
    mov rdi, 1
    mov rsi, reg_line
    mov rdx, reg_line_len
    syscall

    inc r14d
    cmp r14d, 32
    jb .dr_loop
    ret

; mem_error: direccion no mapeada, desalineada o de solo lectura
mem_error:
    push r10
    call cleanup
    pop r10
    mov eax, r10d
    lea rdi, [mem_addr_f]
    call put_hex8
    mov eax, r12d
    lea rdi, [mem_pc_f]
    call put_hex8

    mov rax, 1
    mov rdi, 1
    mov rsi, msg_mem
    mov rdx, msg_mem_len
    syscall

    call dump_registers

    mov rax, 60
    mov rdi, 4
    syscall

; ===============================================================
;  ETAPA 2: tipo I aritmetico, ramas y jalr
; ===============================================================

; ---------------------------------------------------------------
; Tipo I aritmetico (opcode 0x13). Mismo formato que las cargas:
; el inmediato son los 12 bits altos, extendidos con signo por sar.
; Los desplazamientos son el caso raro: ahi el campo no es un
; inmediato sino un shamt de 5 bits, y el bit 30 distingue srli
; de srai igual que funct7 lo hace en el tipo R.
; ---------------------------------------------------------------
decode_i_alu:
    mov ecx, edx
    shr ecx, 7
    and ecx, 0x1F
    mov dword [rd], ecx

    mov ecx, edx
    shr ecx, 12
    and ecx, 7
    mov dword [funct3], ecx

    mov ecx, edx
    shr ecx, 15
    and ecx, 0x1F
    mov dword [rs1], ecx

    mov ecx, edx
    sar ecx, 20
    mov dword [imm], ecx

    mov ecx, [rs1]
    call read_reg
    mov r11d, eax                  ; r11d = R[rs1]
    mov eax, [imm]                 ; eax  = inmediato

    mov ecx, [funct3]
    cmp ecx, 0
    je .i_add
    cmp ecx, 1
    je .i_sll
    cmp ecx, 2
    je .i_slt
    cmp ecx, 3
    je .i_sltu
    cmp ecx, 4
    je .i_xor
    cmp ecx, 5
    je .i_shr
    cmp ecx, 6
    je .i_or
    cmp ecx, 7
    je .i_and
    jmp stop_unimplemented

.i_add:
    add r11d, eax
    jmp .i_store
.i_sll:
    mov ecx, eax
    and ecx, 0x1F                  ; shamt, no inmediato
    shl r11d, cl
    jmp .i_store
.i_slt:
    cmp r11d, eax
    setl r11b
    movzx r11d, r11b
    jmp .i_store
.i_sltu:
    ; sltiu compara SIN signo, pero contra el inmediato ya extendido
    ; CON signo. Es asi por definicion del ISA, no es una errata.
    cmp r11d, eax
    setb r11b
    movzx r11d, r11b
    jmp .i_store
.i_xor:
    xor r11d, eax
    jmp .i_store
.i_shr:
    mov ecx, eax
    and ecx, 0x1F
    test edx, 0x40000000           ; bit 30: 0 = srli, 1 = srai
    jnz .i_sra
    shr r11d, cl
    jmp .i_store
.i_sra:
    sar r11d, cl
    jmp .i_store
.i_or:
    or r11d, eax
    jmp .i_store
.i_and:
    and r11d, eax
.i_store:
    mov eax, r11d
    mov ecx, [rd]
    call write_reg
    ret

; ---------------------------------------------------------------
; Ramas (opcode 0x63). El inmediato es el mas fragmentado del ISA:
;   imm[12] = instr[31]     imm[10:5] = instr[30:25]
;   imm[4:1] = instr[11:8]  imm[11]   = instr[7]
; El bit 0 siempre vale 0 (los saltos son a direcciones pares), por
; eso el campo cubre 13 bits usando solo 12 del encoding.
; Al final se extiende el signo desde el bit 12 con shl/sar 19.
; ---------------------------------------------------------------
decode_b:
    mov ecx, edx
    shr ecx, 12
    and ecx, 7
    mov dword [funct3], ecx

    mov ecx, edx
    shr ecx, 15
    and ecx, 0x1F
    mov dword [rs1], ecx

    mov ecx, edx
    shr ecx, 20
    and ecx, 0x1F
    mov dword [rs2], ecx

    xor ecx, ecx
    mov r11d, edx
    shr r11d, 31
    shl r11d, 12
    or ecx, r11d                   ; imm[12]
    mov r11d, edx
    shr r11d, 25
    and r11d, 0x3F
    shl r11d, 5
    or ecx, r11d                   ; imm[10:5]
    mov r11d, edx
    shr r11d, 8
    and r11d, 0x0F
    shl r11d, 1
    or ecx, r11d                   ; imm[4:1]
    mov r11d, edx
    shr r11d, 7
    and r11d, 1
    shl r11d, 11
    or ecx, r11d                   ; imm[11]
    shl ecx, 19
    sar ecx, 19                    ; extension de signo desde el bit 12
    mov dword [imm], ecx

    mov ecx, [rs1]
    call read_reg
    mov r11d, eax                  ; r11d = R[rs1]
    mov ecx, [rs2]
    call read_reg                  ; eax  = R[rs2]

    mov ecx, [funct3]
    cmp ecx, 0
    je .b_eq
    cmp ecx, 1
    je .b_ne
    cmp ecx, 4
    je .b_lt
    cmp ecx, 5
    je .b_ge
    cmp ecx, 6
    je .b_ltu
    cmp ecx, 7
    je .b_geu
    jmp stop_unimplemented

.b_eq:
    cmp r11d, eax
    je .b_take
    ret
.b_ne:
    cmp r11d, eax
    jne .b_take
    ret
.b_lt:
    cmp r11d, eax
    jl .b_take                     ; con signo
    ret
.b_ge:
    cmp r11d, eax
    jge .b_take                    ; con signo
    ret
.b_ltu:
    cmp r11d, eax
    jb .b_take                     ; sin signo
    ret
.b_geu:
    cmp r11d, eax
    jae .b_take                    ; sin signo
    ret
.b_take:
    ; Destino relativo al PC de ESTA instruccion, no al ya incrementado.
    mov eax, r12d
    add eax, [imm]
    mov rbx, registers
    mov dword [rbx + pc*4], eax
    ret

; ---------------------------------------------------------------
; jalr (opcode 0x67). Salto indirecto: destino = (R[rs1] + imm) con
; el bit 0 forzado a cero. Hay que calcular el destino ANTES de
; escribir rd, porque `jalr ra, ra, 0` usa el mismo registro para
; las dos cosas y escribirlo primero destruiria el destino.
; ---------------------------------------------------------------
decode_jalr:
    mov ecx, edx
    shr ecx, 7
    and ecx, 0x1F
    mov dword [rd], ecx

    mov ecx, edx
    shr ecx, 15
    and ecx, 0x1F
    mov dword [rs1], ecx

    mov ecx, edx
    sar ecx, 20
    mov dword [imm], ecx

    mov ecx, [rs1]
    call read_reg
    add eax, [imm]
    and eax, 0xFFFFFFFE            ; el bit 0 siempre se descarta
    mov r11d, eax                  ; destino, a salvo antes de tocar rd

    mov eax, r12d
    add eax, 4                     ; direccion de retorno
    mov ecx, [rd]
    call write_reg

    mov rbx, registers
    mov dword [rbx + pc*4], r11d
    ret

; ===============================================================
;  ETAPA 4: syscalls (ecall)
; ===============================================================
; RARS pasa el numero de servicio en a7 y los argumentos en a0..a3.
; Aqui se traduce cada uno al syscall equivalente de Linux.
; ---------------------------------------------------------------

; mem_read_byte: eax = direccion -> eax = byte (sin signo).
; La memoria emulada esta organizada en palabras, asi que se lee la
; palabra que contiene el byte y se extrae con un desplazamiento.
mem_read_byte:
    mov r11d, eax
    and eax, 0xFFFFFFFC            ; bajar a la palabra alineada
    call mem_read
    and r11d, 3                    ; que byte dentro de la palabra
    shl r11d, 3                    ; a numero de bits
    mov ecx, r11d
    shr eax, cl
    and eax, 0xFF
    ret

; put_dec: imprime eax como entero decimal CON signo.
; Se construye hacia atras desde el final del buffer, que es la forma
; natural: dividir entre 10 entrega los digitos del menos al mas
; significativo.
put_dec:
    push rbx
    movsxd rax, eax
    xor r8d, r8d
    test rax, rax
    jns .pd_pos
    neg rax
    mov r8d, 1
.pd_pos:
    lea rdi, [int_buf + 24]
    mov rbx, 10
    xor r9d, r9d
.pd_loop:
    xor rdx, rdx
    div rbx                        ; rax = rax/10, rdx = resto
    add dl, '0'
    dec rdi
    mov [rdi], dl
    inc r9d
    test rax, rax
    jnz .pd_loop
    test r8d, r8d
    jz .pd_out
    dec rdi
    mov byte [rdi], '-'
    inc r9d
.pd_out:
    mov rsi, rdi                   ; guardar el puntero ANTES de pisar rdi
    mov rdx, r9
    mov rax, 1
    mov rdi, 1
    syscall
    pop rbx
    ret

; read_dec: lee un entero decimal de stdin -> eax
read_dec:
    xor rax, rax                   ; syscall: read
    xor rdi, rdi                   ; stdin
    mov rsi, int_buf
    mov rdx, 32
    syscall
    test rax, rax
    jle .rd_cero
    mov r9, rax                    ; bytes leidos
    xor r10d, r10d                 ; indice
    xor r11d, r11d                 ; acumulador
    xor r8d, r8d                   ; bandera de negativo
.rd_skip:
    cmp r10, r9
    jae .rd_fin
    mov al, [int_buf + r10]
    cmp al, ' '
    je .rd_adv
    cmp al, 9
    je .rd_adv
    jmp .rd_signo
.rd_adv:
    inc r10
    jmp .rd_skip
.rd_signo:
    cmp al, '-'
    jne .rd_dig
    mov r8d, 1
    inc r10
.rd_dig:
    cmp r10, r9
    jae .rd_fin
    mov al, [int_buf + r10]
    cmp al, '0'
    jb .rd_fin
    cmp al, '9'
    ja .rd_fin
    sub al, '0'
    movzx eax, al
    imul r11d, r11d, 10
    add r11d, eax
    inc r10
    jmp .rd_dig
.rd_fin:
    mov eax, r11d
    test r8d, r8d
    jz .rd_ok
    neg eax
.rd_ok:
    ret
.rd_cero:
    xor eax, eax
    ret

; ---------------------------------------------------------------
decode_ecall:
    ; El opcode 0x73 cubre ecall, ebreak y las instrucciones CSR.
    ; funct3 = 0 son ecall/ebreak; cualquier otro valor es un CSR.
    mov ecx, edx
    shr ecx, 12
    and ecx, 7
    test ecx, ecx
    jnz decode_csr

    test edx, 0x00100000           ; bit 20 distingue ebreak de ecall
    jnz stop_unimplemented

    ; Los ecall son la frontera natural entre cuadros: el juego dibuja
    ; y luego duerme. Repintar aqui, y solo si algo cambio, evita
    ; redibujar 2920 veces por cuadro y no molesta a los programas de
    ; puro texto, que nunca tocan el framebuffer.
    cmp dword [fb_dirty], 0
    je .sin_repintar
    call render_frame
    mov dword [fb_dirty], 0
.sin_repintar:

    mov ecx, a7
    call read_reg
    mov r11d, eax                  ; numero de servicio RARS

    cmp r11d, 1
    je .print_int
    cmp r11d, 4
    je .print_str
    cmp r11d, 5
    je .read_int
    cmp r11d, 10
    je .exit_cero
    cmp r11d, 11
    je .print_chr
    cmp r11d, 12
    je .read_chr
    cmp r11d, 31
    je .midi
    cmp r11d, 32
    je .dormir
    cmp r11d, 34
    je .print_hex
    cmp r11d, 93
    je .exit_a0
    jmp ecall_error

.print_int:                        ; 1: imprimir entero
    mov ecx, a0
    call read_reg
    call put_dec
    ret

.print_hex:                        ; 34: imprimir entero en hexadecimal
    mov ecx, a0
    call read_reg
    lea rdi, [hexout_f]
    call put_hex8
    mov rax, 1
    mov rdi, 1
    mov rsi, hexout
    mov rdx, hexout_len
    syscall
    ret

.print_str:                        ; 4: imprimir cadena terminada en cero
    mov ecx, a0
    call read_reg
    mov r14d, eax
.ps_loop:
    mov eax, r14d
    call mem_read_byte
    test eax, eax
    jz .ps_fin
    mov [char_buf], al
    mov rax, 1
    mov rdi, 1
    mov rsi, char_buf
    mov rdx, 1
    syscall
    inc r14d
    jmp .ps_loop
.ps_fin:
    ret

.print_chr:                        ; 11: imprimir caracter
    mov ecx, a0
    call read_reg
    mov [char_buf], al
    mov rax, 1
    mov rdi, 1
    mov rsi, char_buf
    mov rdx, 1
    syscall
    ret

.read_int:                         ; 5: leer entero
    call read_dec
    mov ecx, a0
    call write_reg
    ret

.read_chr:                         ; 12: leer caracter
    xor rax, rax
    xor rdi, rdi
    mov rsi, char_buf
    mov rdx, 1
    syscall
    test rax, rax
    jle .rc_eof
    movzx eax, byte [char_buf]
    jmp .rc_ok
.rc_eof:
    mov eax, -1
.rc_ok:
    mov ecx, a0
    call write_reg
    ret

.midi:                             ; 31: nota MIDI. Es asincrono en RARS,
    ret                            ; asi que ignorarlo no altera el juego.

.dormir:                           ; 32: dormir a0 milisegundos
    mov ecx, a0
    call read_reg
    test eax, eax
    jle .sl_fin
    xor edx, edx
    mov ecx, 1000
    div ecx                        ; eax = segundos, edx = ms sobrantes
    mov r8d, eax
    mov r9d, edx
    mov [ts_sec], r8
    imul r9d, r9d, 1000000         ; ms -> ns
    mov [ts_nsec], r9
    mov rax, 35                    ; syscall: nanosleep
    lea rdi, [ts_sec]              ; ts_nsec va justo despues: es el struct
    xor rsi, rsi
    syscall
.sl_fin:
    ret

.exit_cero:                        ; 10: terminar
    call cleanup
    mov rax, 60
    xor rdi, rdi
    syscall

.exit_a0:                          ; 93: terminar con codigo en a0
    call cleanup
    mov ecx, a0
    call read_reg
    movzx edi, al
    mov rax, 60
    syscall

ecall_error:
    mov eax, r11d
    lea rdi, [ecall_num_f]
    call put_hex8
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_ecall
    mov rdx, msg_ecall_len
    syscall
    call dump_registers
    mov rax, 60
    mov rdi, 5
    syscall

; ===============================================================
;  ETAPA 5: video en terminal
; ===============================================================
; La pantalla de RARS son 64x32 unidades. Con el caracter de medio
; bloque superior (U+2580) se pintan DOS filas por linea de terminal:
; el color de primer plano es el pixel de arriba y el de fondo es el
; de abajo. Asi la rejilla entra en 64x16 caracteres y queda con la
; proporcion correcta.
;
; El cuadro entero se arma en memoria y se manda con un solo write.
; Ademas, los codigos de color solo se emiten cuando el color cambia
; respecto a la celda anterior: en un tablero casi todo negro eso
; reduce el tamano del cuadro en mas de un orden de magnitud.
; ---------------------------------------------------------------

; emit_dec8: escribe eax (0..255) como decimal sin ceros a la
; izquierda en [rdi], y deja rdi apuntando despues del ultimo digito.
emit_dec8:
    cmp eax, 10
    jb .un_digito
    cmp eax, 100
    jb .dos_digitos
    xor edx, edx
    mov r8d, 100
    div r8d
    add al, '0'
    mov [rdi], al
    inc rdi
    mov eax, edx
    xor edx, edx
    mov r8d, 10
    div r8d
    add al, '0'
    mov [rdi], al
    inc rdi
    mov eax, edx
    add al, '0'
    mov [rdi], al
    inc rdi
    ret
.dos_digitos:
    xor edx, edx
    mov r8d, 10
    div r8d
    add al, '0'
    mov [rdi], al
    inc rdi
    mov eax, edx
    add al, '0'
    mov [rdi], al
    inc rdi
    ret
.un_digito:
    add al, '0'
    mov [rdi], al
    inc rdi
    ret

; emit_rgb: eax = color 0x00RRGGBB -> escribe "R;G;B" en [rdi]
emit_rgb:
    mov r9d, eax
    shr eax, 16
    and eax, 0xFF
    call emit_dec8
    mov byte [rdi], ';'
    inc rdi
    mov eax, r9d
    shr eax, 8
    and eax, 0xFF
    call emit_dec8
    mov byte [rdi], ';'
    inc rdi
    mov eax, r9d
    and eax, 0xFF
    call emit_dec8
    ret

; video_restore: devuelve la terminal a su estado normal
video_restore:
    cmp dword [video_init], 0
    je .vr_fin
    mov rax, 1
    mov rdi, 2
    mov rsi, esc_fin
    mov rdx, esc_fin_len
    syscall
    mov dword [video_init], 0
.vr_fin:
    ret

; render_frame: dibuja el framebuffer completo en stderr
render_frame:
    push rbx
    push r12
    push r13
    push r14
    push r15

    cmp dword [video_init], 0
    jne .ya_init
    mov dword [video_init], 1
    mov rax, 1                     ; limpiar pantalla y ocultar el cursor,
    mov rdi, 2                     ; una sola vez
    mov rsi, esc_init
    mov rdx, esc_init_len
    syscall
.ya_init:

    lea rdi, [video_buf]
    mov byte [rdi], 0x1B           ; ESC [ H -> cursor al inicio, sin borrar:
    mov byte [rdi+1], '['          ; repintar encima evita el parpadeo que
    mov byte [rdi+2], 'H'          ; produce limpiar la pantalla cada cuadro
    add rdi, 3

    xor r14d, r14d                 ; fila de caracteres, 0..15
.fila:
    mov r12d, -1                   ; ultimo color de primer plano emitido
    mov r13d, -1                   ; ultimo color de fondo emitido
    xor r15d, r15d                 ; columna, 0..63
.columna:
    mov eax, r14d
    shl eax, 7                     ; fila*2*64 = fila*128
    add eax, r15d
    mov r10d, eax
    mov ebx, [framebuffer + r10*4] ; pixel de arriba
    add r10d, 64
    mov r11d, [framebuffer + r10*4]; pixel de abajo

    cmp ebx, r12d
    je .sin_fg
    mov r12d, ebx
    mov rax, [esc_fg]
    mov [rdi], rax
    add rdi, 7
    mov eax, ebx
    call emit_rgb
    mov byte [rdi], 'm'
    inc rdi
.sin_fg:
    cmp r11d, r13d
    je .sin_bg
    mov r13d, r11d
    mov rax, [esc_bg]
    mov [rdi], rax
    add rdi, 7
    mov eax, r11d
    call emit_rgb
    mov byte [rdi], 'm'
    inc rdi
.sin_bg:
    mov byte [rdi], 0xE2           ; U+2580, medio bloque superior
    mov byte [rdi+1], 0x96
    mov byte [rdi+2], 0x80
    add rdi, 3

    inc r15d
    cmp r15d, 64
    jb .columna

    mov eax, [esc_eol]             ; ESC[0m + salto de linea
    mov [rdi], eax
    mov byte [rdi+4], 10
    add rdi, 5

    inc r14d
    cmp r14d, 16
    jb .fila

    lea rsi, [video_buf]
    mov rdx, rdi
    sub rdx, rsi                   ; longitud = cuanto avanzo el puntero
    mov rax, 1
    mov rdi, 2                     ; stderr: separado de la traza
    syscall

    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

; ===============================================================
;  ETAPA 6: teclado MMIO
; ===============================================================
; RARS entrega las teclas por dos direcciones: 0xFFFF0000 dice si hay
; una pendiente y 0xFFFF0004 la entrega. Para reproducir eso hay que
; leer del teclado SIN bloquear, porque la emulacion no puede
; detenerse a esperar, y SIN eco, porque si no las teclas se dibujan
; encima del tablero.
;
; Se cambian tres banderas de c_lflag:
;   ICANON  la terminal deja de esperar el Enter y entrega byte a byte
;   ECHO    deja de imprimir lo que se teclea
;   ISIG    Ctrl+C deja de ser una senal y llega como el byte 0x03
; Apagar ISIG es deliberado: asi el emulador atiende el Ctrl+C el
; mismo, y puede devolver la terminal a su estado normal antes de
; salir. Con ISIG encendido el proceso moriria de golpe y la terminal
; quedaria sin eco, obligando a ejecutar `reset` a ciegas.
; ---------------------------------------------------------------
term_init:
    mov rax, 16                    ; syscall: ioctl
    xor rdi, rdi                   ; stdin
    mov rsi, 0x5401                ; TCGETS: leer la configuracion actual
    lea rdx, [termios_orig]
    syscall
    cmp rax, 0
    jl .solo_nonblock              ; no es una terminal: seguir sin modo crudo

    ; copiar la configuracion original a la copia que vamos a modificar
    xor rcx, rcx
.copiar:
    mov al, [termios_orig + rcx]
    mov [termios_raw + rcx], al
    inc rcx
    cmp rcx, 60
    jb .copiar

    ; c_lflag esta en el desplazamiento 12
    mov eax, [termios_raw + 12]
    and eax, ~(0x0001 | 0x0002 | 0x0008)   ; ISIG, ICANON, ECHO
    mov [termios_raw + 12], eax

    ; c_cc empieza en 17: VTIME es el indice 5 y VMIN el 6.
    ; Ambos en cero significa "devolve ya mismo lo que haya, o nada".
    mov byte [termios_raw + 17 + 5], 0
    mov byte [termios_raw + 17 + 6], 0

    mov rax, 16
    xor rdi, rdi
    mov rsi, 0x5402                ; TCSETS: aplicar
    lea rdx, [termios_raw]
    syscall
    mov dword [term_ready], 1

.solo_nonblock:
    ; Marcar stdin como no bloqueante. Con una terminal en modo crudo
    ; ya bastaria, pero si la entrada viene de una tuberia el read se
    ; quedaria colgado, y el emulador se congelaria.
    mov rax, 72                    ; syscall: fcntl
    xor rdi, rdi
    mov rsi, 3                     ; F_GETFL
    xor rdx, rdx
    syscall
    mov [stdin_flags], rax
    mov rdx, rax
    or rdx, 0x800                  ; O_NONBLOCK
    mov rax, 72
    xor rdi, rdi
    mov rsi, 4                     ; F_SETFL
    syscall
    ret

term_restore:
    ; devolver las banderas de stdin
    mov rax, 72
    xor rdi, rdi
    mov rsi, 4                     ; F_SETFL
    mov rdx, [stdin_flags]
    syscall

    cmp dword [term_ready], 0
    je .tr_fin
    mov rax, 16
    xor rdi, rdi
    mov rsi, 0x5402                ; TCSETS con la configuracion guardada
    lea rdx, [termios_orig]
    syscall
    mov dword [term_ready], 0
.tr_fin:
    ret

cleanup:
    call video_restore
    call term_restore
    ; cerrar el archivo de traza, si se abrio uno
    mov rdi, [trace_fd]
    cmp rdi, 1
    jle .cl_fin
    mov rax, 3                     ; syscall: close
    syscall
    mov qword [trace_fd], 1
.cl_fin:
    ret

; poll_key: mira si hay una tecla y la deja lista para el MMIO.
; Preserva todo lo que usa mem_read, porque se llama desde su interior.
poll_key:
    push rax
    push rcx
    push rdx
    push rsi
    push rdi
    push r10
    push r11

    cmp dword [key_status], 0
    jne .pk_fin                    ; ya hay una sin consumir: no pisarla

    xor rax, rax                   ; syscall: read
    xor rdi, rdi                   ; stdin
    mov rsi, char_buf
    mov rdx, 1
    syscall
    cmp rax, 1
    jne .pk_fin                    ; 0 = no habia nada, negativo = EAGAIN

    movzx eax, byte [char_buf]
    cmp eax, 3                     ; Ctrl+C, que ya no es una senal
    je .pk_salir
    mov dword [key_data], eax
    mov dword [key_status], 1

.pk_fin:
    pop r11
    pop r10
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rax
    ret

.pk_salir:
    call cleanup
    mov rax, 60
    xor rdi, rdi
    syscall

; ===============================================================
;  ETAPA 3: desensamblador para la traza
; ===============================================================
; Todos los emisores de abajo escriben en [rdi] y DEJAN rdi apuntando
; despues de lo escrito. Encadenarlos construye la linea sin llevar
; ninguna cuenta de longitudes.
; ---------------------------------------------------------------

; e_mn: copia el mnemonico de 6 bytes al que apunta rsi
e_mn:
    mov rax, [rsi]                 ; se copian 8 y se avanzan 6: los 2 de mas
    mov [rdi], rax                 ; los pisa lo siguiente que se escriba
    add rdi, 6
    ret

; e_reg: escribe 'x' seguido del numero de registro en eax
e_reg:
    mov byte [rdi], 'x'
    inc rdi
    call emit_dec8
    ret

; e_coma: escribe ", "
e_coma:
    mov byte [rdi], ','
    mov byte [rdi+1], ' '
    add rdi, 2
    ret

; e_0x: escribe "0x"
e_0x:
    mov byte [rdi], '0'
    mov byte [rdi+1], 'x'
    add rdi, 2
    ret

; e_dec: escribe eax como decimal CON signo
e_dec:
    push rbx
    movsxd rax, eax
    test rax, rax
    jns .ed_pos
    mov byte [rdi], '-'
    inc rdi
    neg rax
.ed_pos:
    lea rsi, [int_buf + 24]
    mov rbx, 10
    xor r8d, r8d
.ed_loop:
    xor rdx, rdx
    div rbx
    add dl, '0'
    dec rsi
    mov [rsi], dl
    inc r8d
    test rax, rax
    jnz .ed_loop
.ed_copy:
    mov al, [rsi]
    mov [rdi], al
    inc rsi
    inc rdi
    dec r8d
    jnz .ed_copy
    pop rbx
    ret

; ---------------------------------------------------------------
; disasm: arma en trace_line la linea
;   0xPC  0xINSTR  mnemonico operandos\n
; Entrada: r12d = PC, r13d = instruccion. Salida: rdi al final.
; ---------------------------------------------------------------
disasm:
    lea rdi, [trace_line]
    call e_0x
    mov eax, r12d
    call put_hex8
    mov byte [rdi], ' '
    mov byte [rdi+1], ' '
    add rdi, 2
    call e_0x
    mov eax, r13d
    call put_hex8
    mov byte [rdi], ' '
    mov byte [rdi+1], ' '
    add rdi, 2

    mov eax, r13d
    shr eax, 7
    and eax, 0x1F
    mov dword [d_rd], eax
    mov eax, r13d
    shr eax, 12
    and eax, 7
    mov dword [d_f3], eax
    mov eax, r13d
    shr eax, 15
    and eax, 0x1F
    mov dword [d_rs1], eax
    mov eax, r13d
    shr eax, 20
    and eax, 0x1F
    mov dword [d_rs2], eax
    mov eax, r13d
    shr eax, 25
    and eax, 0x7F
    mov dword [d_f7], eax

    mov eax, r13d
    and eax, 0x7F
    cmp eax, 0x37
    je .lui
    cmp eax, 0x17
    je .auipc
    cmp eax, 0x6F
    je .jal
    cmp eax, 0x67
    je .jalr
    cmp eax, 0x63
    je .rama
    cmp eax, 0x03
    je .carga
    cmp eax, 0x23
    je .guarda
    cmp eax, 0x13
    je .ialu
    cmp eax, 0x33
    je .rtipo
    cmp eax, 0x73
    je .ecall
    lea rsi, [mn_unk]
    call e_mn
    jmp .fin

; ---- lui / auipc: rd, inmediato de 20 bits ya en su lugar ----
.lui:
    lea rsi, [mn_lui]
    jmp .u_comun
.auipc:
    lea rsi, [mn_auipc]
.u_comun:
    call e_mn
    mov eax, [d_rd]
    call e_reg
    call e_coma
    call e_0x
    mov eax, r13d
    shr eax, 12                    ; los 20 bits altos, sin signo
    call put_hex8
    jmp .fin

; ---- jal: rd y direccion absoluta de destino ----
.jal:
    lea rsi, [mn_jal]
    call e_mn
    mov eax, [d_rd]
    call e_reg
    call e_coma
    call e_0x
    call imm_uj                    ; eax = inmediato con signo
    add eax, r12d                  ; destino absoluto
    call put_hex8
    jmp .fin

; ---- jalr: rd, desplazamiento(rs1) ----
.jalr:
    lea rsi, [mn_jalr]
    call e_mn
    mov eax, [d_rd]
    call e_reg
    call e_coma
    mov eax, r13d
    sar eax, 20
    call e_dec
    mov byte [rdi], '('
    inc rdi
    mov eax, [d_rs1]
    call e_reg
    mov byte [rdi], ')'
    inc rdi
    jmp .fin

; ---- ramas: rs1, rs2 y direccion absoluta de destino ----
.rama:
    mov eax, [d_f3]
    lea rsi, [mn_beq]
    cmp eax, 0
    je .rama_ok
    lea rsi, [mn_bne]
    cmp eax, 1
    je .rama_ok
    lea rsi, [mn_blt]
    cmp eax, 4
    je .rama_ok
    lea rsi, [mn_bge]
    cmp eax, 5
    je .rama_ok
    lea rsi, [mn_bltu]
    cmp eax, 6
    je .rama_ok
    lea rsi, [mn_bgeu]
    cmp eax, 7
    je .rama_ok
    lea rsi, [mn_unk]
.rama_ok:
    call e_mn
    mov eax, [d_rs1]
    call e_reg
    call e_coma
    mov eax, [d_rs2]
    call e_reg
    call e_coma
    call e_0x
    call imm_b
    add eax, r12d
    call put_hex8
    jmp .fin

; ---- cargas: rd, desplazamiento(rs1) ----
.carga:
    mov eax, [d_f3]
    lea rsi, [mn_lb]
    cmp eax, 0
    je .carga_ok
    lea rsi, [mn_lh]
    cmp eax, 1
    je .carga_ok
    lea rsi, [mn_lw]
    cmp eax, 2
    je .carga_ok
    lea rsi, [mn_lbu]
    cmp eax, 4
    je .carga_ok
    lea rsi, [mn_lhu]
    cmp eax, 5
    je .carga_ok
    lea rsi, [mn_unk]
.carga_ok:
    call e_mn
    mov eax, [d_rd]
    call e_reg
    call e_coma
    mov eax, r13d
    sar eax, 20
    call e_dec
    mov byte [rdi], '('
    inc rdi
    mov eax, [d_rs1]
    call e_reg
    mov byte [rdi], ')'
    inc rdi
    jmp .fin

; ---- almacenamientos: rs2, desplazamiento(rs1) ----
.guarda:
    mov eax, [d_f3]
    lea rsi, [mn_sb]
    cmp eax, 0
    je .guarda_ok
    lea rsi, [mn_sh]
    cmp eax, 1
    je .guarda_ok
    lea rsi, [mn_sw]
    cmp eax, 2
    je .guarda_ok
    lea rsi, [mn_unk]
.guarda_ok:
    call e_mn
    mov eax, [d_rs2]
    call e_reg
    call e_coma
    call imm_s
    call e_dec
    mov byte [rdi], '('
    inc rdi
    mov eax, [d_rs1]
    call e_reg
    mov byte [rdi], ')'
    inc rdi
    jmp .fin

; ---- tipo I aritmetico ----
.ialu:
    mov eax, [d_f3]
    lea rsi, [mn_addi]
    cmp eax, 0
    je .ialu_ok
    lea rsi, [mn_slli]
    cmp eax, 1
    je .ialu_sh
    lea rsi, [mn_slti]
    cmp eax, 2
    je .ialu_ok
    lea rsi, [mn_sltiu]
    cmp eax, 3
    je .ialu_ok
    lea rsi, [mn_xori]
    cmp eax, 4
    je .ialu_ok
    cmp eax, 5
    jne .ialu_or
    lea rsi, [mn_srli]
    test r13d, 0x40000000          ; bit 30 distingue srai de srli
    jz .ialu_sh
    lea rsi, [mn_srai]
    jmp .ialu_sh
.ialu_or:
    lea rsi, [mn_ori]
    cmp eax, 6
    je .ialu_ok
    lea rsi, [mn_andi]
    cmp eax, 7
    je .ialu_ok
    lea rsi, [mn_unk]
.ialu_ok:
    call e_mn
    mov eax, [d_rd]
    call e_reg
    call e_coma
    mov eax, [d_rs1]
    call e_reg
    call e_coma
    mov eax, r13d
    sar eax, 20
    call e_dec
    jmp .fin
.ialu_sh:
    ; en los desplazamientos el campo no es un inmediato sino un shamt
    call e_mn
    mov eax, [d_rd]
    call e_reg
    call e_coma
    mov eax, [d_rs1]
    call e_reg
    call e_coma
    mov eax, r13d
    shr eax, 20
    and eax, 0x1F
    call e_dec
    jmp .fin

; ---- tipo R ----
.rtipo:
    mov eax, [d_f3]
    cmp eax, 0
    jne .r1
    lea rsi, [mn_add]
    cmp dword [d_f7], 0x20
    jne .rtipo_ok
    lea rsi, [mn_sub]
    jmp .rtipo_ok
.r1:
    lea rsi, [mn_sll]
    cmp eax, 1
    je .rtipo_ok
    lea rsi, [mn_slt]
    cmp eax, 2
    je .rtipo_ok
    lea rsi, [mn_sltu]
    cmp eax, 3
    je .rtipo_ok
    lea rsi, [mn_xor]
    cmp eax, 4
    je .rtipo_ok
    cmp eax, 5
    jne .r6
    lea rsi, [mn_srl]
    cmp dword [d_f7], 0x20
    jne .rtipo_ok
    lea rsi, [mn_sra]
    jmp .rtipo_ok
.r6:
    lea rsi, [mn_or]
    cmp eax, 6
    je .rtipo_ok
    lea rsi, [mn_and]
    cmp eax, 7
    je .rtipo_ok
    lea rsi, [mn_unk]
.rtipo_ok:
    call e_mn
    mov eax, [d_rd]
    call e_reg
    call e_coma
    mov eax, [d_rs1]
    call e_reg
    call e_coma
    mov eax, [d_rs2]
    call e_reg
    jmp .fin

.ecall:
    lea rsi, [mn_ecall]
    call e_mn

.fin:
    mov byte [rdi], 10
    inc rdi
    ret

; ---------------------------------------------------------------
; Extractores de inmediato para el desensamblador. Duplican la logica
; de los decodificadores a proposito: el desensamblador debe poder
; leer una instruccion sin ejecutarla ni tocar el estado.
; ---------------------------------------------------------------
imm_uj:                            ; jal: imm[20|10:1|11|19:12]
    xor eax, eax
    mov r10d, r13d
    shr r10d, 31
    shl r10d, 20
    or eax, r10d
    mov r10d, r13d
    shr r10d, 21
    and r10d, 0x3FF
    shl r10d, 1
    or eax, r10d
    mov r10d, r13d
    shr r10d, 20
    and r10d, 1
    shl r10d, 11
    or eax, r10d
    mov r10d, r13d
    shr r10d, 12
    and r10d, 0xFF
    shl r10d, 12
    or eax, r10d
    shl eax, 11
    sar eax, 11
    ret

imm_b:                             ; ramas: imm[12|10:5|4:1|11]
    xor eax, eax
    mov r10d, r13d
    shr r10d, 31
    shl r10d, 12
    or eax, r10d
    mov r10d, r13d
    shr r10d, 25
    and r10d, 0x3F
    shl r10d, 5
    or eax, r10d
    mov r10d, r13d
    shr r10d, 8
    and r10d, 0x0F
    shl r10d, 1
    or eax, r10d
    mov r10d, r13d
    shr r10d, 7
    and r10d, 1
    shl r10d, 11
    or eax, r10d
    shl eax, 19
    sar eax, 19
    ret

imm_s:                             ; almacenamientos: imm[11:5] y imm[4:0]
    mov eax, r13d
    sar eax, 25
    shl eax, 5
    mov r10d, r13d
    shr r10d, 7
    and r10d, 0x1F
    or eax, r10d
    ret

; ===============================================================
;  ETAPA 7: accesos de byte y media palabra
; ===============================================================
; La memoria emulada esta organizada en palabras de 32 bits, asi que
; leer o escribir un byte exige bajar a la palabra que lo contiene y
; desplazar. Escribir ademas obliga a leer-modificar-escribir: hay que
; conservar los otros tres bytes de la palabra.
;
; El desplazamiento en bits sale de los 2 bits bajos de la direccion
; por 8. Esto asume que el anfitrion es little-endian igual que RISC-V,
; lo cual se cumple en x86.
; ---------------------------------------------------------------

; mem_read_half: eax = direccion -> eax = media palabra SIN signo
mem_read_half:
    test eax, 1                    ; media palabra debe ir en direccion par
    jz .rh_ok
    mov r10d, eax
    jmp mem_error
.rh_ok:
    push rbx
    mov ebx, eax
    and eax, 0xFFFFFFFC
    call mem_read
    mov ecx, ebx
    and ecx, 2
    shl ecx, 3                     ; 0 o 16 bits
    shr eax, cl
    and eax, 0xFFFF
    pop rbx
    ret

; mem_write_byte: eax = direccion, ecx = valor (byte en los 8 bits bajos)
mem_write_byte:
    push rbx
    push r14
    push r15
    mov ebx, eax                   ; direccion original
    mov r14d, ecx                  ; valor
    and eax, 0xFFFFFFFC
    mov r15d, eax                  ; direccion alineada
    call mem_read                  ; leer la palabra que lo contiene
    mov ecx, ebx
    and ecx, 3
    shl ecx, 3                     ; a que desplazamiento va el byte
    mov r11d, 0xFF
    shl r11d, cl
    not r11d
    and eax, r11d                  ; abrir el hueco, conservando el resto
    mov r11d, r14d
    and r11d, 0xFF
    shl r11d, cl
    or eax, r11d                   ; meter el byte nuevo
    mov ecx, eax
    mov eax, r15d
    call mem_write
    pop r15
    pop r14
    pop rbx
    ret

; mem_write_half: eax = direccion, ecx = valor (16 bits bajos)
mem_write_half:
    test eax, 1
    jz .wh_ok
    mov r10d, eax
    jmp mem_error
.wh_ok:
    push rbx
    push r14
    push r15
    mov ebx, eax
    mov r14d, ecx
    and eax, 0xFFFFFFFC
    mov r15d, eax
    call mem_read
    mov ecx, ebx
    and ecx, 2
    shl ecx, 3                     ; 0 o 16
    mov r11d, 0xFFFF
    shl r11d, cl
    not r11d
    and eax, r11d
    mov r11d, r14d
    and r11d, 0xFFFF
    shl r11d, cl
    or eax, r11d
    mov ecx, eax
    mov eax, r15d
    call mem_write
    pop r15
    pop r14
    pop rbx
    ret

; ===============================================================
;  Contadores CSR: rdcycle, rdtime, rdinstret
; ===============================================================
; `rdtime a1` es en realidad `csrrs a1, time, x0`. El Bomberman lo usa
; como semilla de aleatoriedad, combinandolo con xor. Solo se admiten
; los tres contadores de solo lectura y sus mitades altas; cualquier
; otro CSR para el emulador con un mensaje.
; ---------------------------------------------------------------
decode_csr:
    ; El registro destino se extrae AHORA y se guarda en la pila.
    ; leer_ms hace una division, y `div` escribe el resto en rdx, que es
    ; justo donde vive la instruccion actual. Ademas `syscall` destruye
    ; rcx y r11. Si se extrajera rd despues, saldria de un valor
    ; corrupto y rdtime escribiria en un registro al azar: un error
    ; intermitente que depende de los nanosegundos del reloj.
    mov ecx, edx
    shr ecx, 7
    and ecx, 0x1F                  ; rd
    push rcx

    mov r10d, edx
    shr r10d, 20
    and r10d, 0xFFF                ; numero de CSR

    cmp r10d, 0xC00                ; cycle
    je .csr_cont_lo
    cmp r10d, 0xC02                ; instret
    je .csr_cont_lo
    cmp r10d, 0xC80                ; cycleh
    je .csr_cont_hi
    cmp r10d, 0xC82                ; instreth
    je .csr_cont_hi
    cmp r10d, 0xC01                ; time
    je .csr_time_lo
    cmp r10d, 0xC81                ; timeh
    je .csr_time_hi
    pop rcx
    jmp stop_unimplemented

.csr_cont_lo:
    mov eax, dword [instr_count]
    jmp .csr_guardar
.csr_cont_hi:
    mov rax, [instr_count]
    shr rax, 32
    jmp .csr_guardar

.csr_time_lo:
    call leer_ms
    jmp .csr_guardar
.csr_time_hi:
    call leer_ms
    shr rax, 32

.csr_guardar:
    pop rcx                        ; rd, a salvo de los syscalls
    call write_reg
    ret

; leer_ms: rax = milisegundos del reloj monotonico
leer_ms:
    mov rax, 228                   ; syscall: clock_gettime
    mov rdi, 1                     ; CLOCK_MONOTONIC
    lea rsi, [t2_sec]              ; t2_nsec va justo detras: es el struct
    syscall
    mov rax, [t2_sec]
    imul rax, rax, 1000
    mov r9, rax
    mov rax, [t2_nsec]
    xor rdx, rdx
    mov rcx, 1000000
    div rcx                        ; nanosegundos -> milisegundos
    add rax, r9
    ret
