# Emulador RISC-V en ensamblador x86-64

NASM      := nasm
LD        := ld
NASMFLAGS := -f elf64 -g -F dwarf

EMU       := emulador
FUENTE    := src/emulador.asm
OBJETO    := src/emulador.o

PONG      := programs/pong
BOMBERMAN := programs/bomberman
TESTS     := tests
BUILD     := tests/build
RARS      := tests/rars

.PHONY: all pong pong-traza bomberman test test-i test-m test-rars smoke doc-check ci limpiar ayuda

all: $(EMU)

$(EMU): $(OBJETO)
	$(LD) -o $@ $<

$(OBJETO): $(FUENTE)
	$(NASM) $(NASMFLAGS) -o $@ $<

# ---- Programas --------------------------------------------------------
pong: $(EMU)
	./$(EMU) -q $(PONG)/punto_text_hex.txt $(PONG)/punto_data_hex.txt

pong-traza: $(EMU)
	./$(EMU) -t traza.txt $(PONG)/punto_text_hex.txt $(PONG)/punto_data_hex.txt

bomberman: $(EMU)
	./$(EMU) -q $(BOMBERMAN)/punto_text_hex.txt $(BOMBERMAN)/punto_data_hex.txt

# ---- Bancos de pruebas ------------------------------------------------
# rvasm.py escribe los volcados en el directorio actual, por eso se entra
# a $(BUILD) antes de invocarlo.
$(BUILD):
	mkdir -p $(BUILD)

test-i: $(EMU) $(BUILD)
	@cd $(BUILD) && python3 ../../tools/rvasm.py ../../$(TESTS)/test_rv32i.asm >/dev/null
	@./$(EMU) -q $(BUILD)/punto_text_hex.txt $(BUILD)/punto_data_hex.txt

test-m: $(EMU) $(BUILD)
	@cd $(BUILD) && python3 ../../tools/rvasm.py ../../$(TESTS)/test_rv32m.asm >/dev/null
	@./$(EMU) -q $(BUILD)/punto_text_hex.txt $(BUILD)/punto_data_hex.txt

test: test-i test-m

# Los mismos bancos, pero con los volcados que produjo RARS. Valida que el
# emulador decodifique el codigo maquina de la referencia, no solo el que
# genera el ensamblador propio.
test-rars: $(EMU)
	@./$(EMU) -q $(RARS)/rv32i/punto_text_hex.txt $(RARS)/rv32i/punto_data_hex.txt
	@./$(EMU) -q $(RARS)/rv32m/punto_text_hex.txt $(RARS)/rv32m/punto_data_hex.txt

# ---- Prueba de humo de los programas reales ---------------------------
# Los juegos se quedan esperando teclas, asi que se corren unos segundos
# y se revisa que no hayan emitido ningun error. Valida que ambos cargan,
# arrancan y dibujan, que es lo que ninguna prueba unitaria cubre.
smoke: $(EMU)
	@echo "Prueba de humo de los programas..."
	@for p in $(PONG) $(BOMBERMAN); do \
	    timeout 5 ./$(EMU) -q $$p/punto_text_hex.txt $$p/punto_data_hex.txt \
	        >/dev/null 2>.smoke.err </dev/null || true; \
	    if grep -qE 'ERROR|STOP|ADVERTENCIA' .smoke.err; then \
	        echo "  FALLO en $$p:"; grep -E 'ERROR|STOP|ADVERTENCIA' .smoke.err; \
	        rm -f .smoke.err; exit 1; \
	    fi; \
	    if [ ! -s .smoke.err ]; then \
	        echo "  FALLO en $$p: no dibujo nada"; rm -f .smoke.err; exit 1; \
	    fi; \
	    echo "  $$p: arranca y dibuja, sin errores"; \
	done; rm -f .smoke.err

# ---- Documentacion ----------------------------------------------------
# Comprueba que toda ruta mencionada en los README exista de verdad. La
# documentacion que apunta a archivos inexistentes es peor que no tenerla:
# hace perder tiempo a quien confia en ella. Los marcadores <...> se
# excluyen a proposito.
doc-check:
	@echo "Verificando rutas mencionadas en la documentacion..."
	@faltan=0; \
	for p in `grep -rhoE '(tests|tools|programs|src)/[A-Za-z0-9_./-]+' --include='*.md' . | sort -u`; do \
	    if [ ! -e "$$p" ]; then echo "  NO EXISTE: $$p"; faltan=1; fi; \
	done; \
	if [ $$faltan -eq 0 ]; then echo "  todas las rutas existen"; else exit 1; fi

# Todo lo que puede comprobarse sin intervencion humana.
ci: test test-rars smoke doc-check

limpiar:
	rm -f $(OBJETO) $(EMU) traza.txt .smoke.err
	rm -rf $(BUILD)

ayuda:
	@echo "make             compilar"
	@echo "make pong        ejecutar el Pong"
	@echo "make pong-traza  ejecutar el Pong y guardar traza.txt"
	@echo "make bomberman   ejecutar el Bomberman"
	@echo "make test        bancos de pruebas (ensamblados con rvasm)"
	@echo "make test-rars   los mismos bancos con los volcados de RARS"
	@echo "make smoke       comprobar que ambos juegos arrancan y dibujan"
	@echo "make doc-check   verificar las rutas citadas en los README"
	@echo "make ci          todo lo anterior de una vez"
	@echo "make limpiar     borrar lo generado"
