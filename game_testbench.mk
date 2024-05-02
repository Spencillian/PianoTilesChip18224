TOPLEVEL_LANG = verilog
VERILOG_SOURCES = $(shell pwd)/src/game.sv $(shell pwd)/src/library.sv $(shell pwd)/src/random.sv
TOPLEVEL = Game
MODULE = game_test
SIM = verilator
EXTRA_ARGS += --trace --trace-structs -Wno-fatal
include $(shell cocotb-config --makefiles)/Makefile.sim