# Emulador RISC-V en ensamblador x86-64
# EL-4314 Arquitectura de Computadoras I

NASM      := nasm
LD        := ld
NASMFLAGS := -f elf64 -g -F dwarf

OBJETIVO  := emulador
FUENTE    := emulador.asm
OBJETO    := $(FUENTE:.asm=.o)

TEXTO     := punto_text_hex.txt
DATOS     := punto_data_hex.txt

.PHONY: all jugar traza verificar limpiar ayuda

all: $(OBJETIVO)

$(OBJETIVO): $(OBJETO)
	$(LD) -o $@ $^

%.o: %.asm
	$(NASM) $(NASMFLAGS) -o $@ $<

# Jugar: video en pantalla, sin generar traza
jugar: $(OBJETIVO) $(TEXTO) $(DATOS)
	./$(OBJETIVO) -q

# Jugar y guardar la traza desensamblada en su propio archivo
traza: $(OBJETIVO) $(TEXTO) $(DATOS)
	./$(OBJETIVO) -t traza.txt

# Contrastar el desensamblado contra el listado de RARS
verificar: $(OBJETIVO) $(TEXTO) $(DATOS)
	@timeout 5 ./$(OBJETIVO) -t /tmp/_v.txt >/dev/null 2>&1 || true
	@echo "Instrucciones distintas ejecutadas: `cut -c1-12 /tmp/_v.txt | sort -u | wc -l`"
	@echo "Traza escrita en /tmp/_v.txt"

limpiar:
	rm -f $(OBJETO) $(OBJETIVO) traza.txt

ayuda:
	@echo "make          compilar"
	@echo "make jugar    ejecutar sin traza (-q)"
	@echo "make traza    ejecutar y guardar traza.txt (-t)"
	@echo "make limpiar  borrar los generados"
