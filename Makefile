# Emulador RISC-V en ensamblador x86-64

NASM      := nasm
LD        := ld
NASMFLAGS := -f elf64 -g -F dwarf

EMU       := emulador
FUENTE    := src/emulador.asm
OBJETO    := src/emulador.o

PONG      := programs/pong
TESTS     := tests
BUILD     := tests/build

.PHONY: all pong pong-traza test test-i test-m limpiar ayuda

all: $(EMU)

$(EMU): $(OBJETO)
	$(LD) -o $@ $<

$(OBJETO): $(FUENTE)
	$(NASM) $(NASMFLAGS) -o $@ $<

pong: $(EMU)
	./$(EMU) -q $(PONG)/punto_text_hex.txt $(PONG)/punto_data_hex.txt

pong-traza: $(EMU)
	./$(EMU) -t traza.txt $(PONG)/punto_text_hex.txt $(PONG)/punto_data_hex.txt

$(BUILD):
	mkdir -p $(BUILD)

test-i: $(EMU) $(BUILD)
	@cd $(BUILD) && python3 ../../tools/rvasm.py ../../$(TESTS)/test_rv32i.asm >/dev/null
	@./$(EMU) -q $(BUILD)/punto_text_hex.txt $(BUILD)/punto_data_hex.txt

test-m: $(EMU) $(BUILD)
	@cd $(BUILD) && python3 ../../tools/rvasm.py ../../$(TESTS)/test_rv32m.asm >/dev/null
	@./$(EMU) -q $(BUILD)/punto_text_hex.txt $(BUILD)/punto_data_hex.txt

test: test-i test-m

limpiar:
	rm -f $(OBJETO) $(EMU) traza.txt
	rm -rf $(BUILD)

ayuda:
	@echo "make             compilar"
	@echo "make pong        ejecutar el Pong"
	@echo "make pong-traza  ejecutar el Pong y guardar traza.txt"
	@echo "make test        correr los dos bancos de pruebas"
	@echo "make limpiar     borrar lo generado"
