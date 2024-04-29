TOPLEVEL_LANG = verilog
VERILOG_SOURCES = $(shell pwd)/game.sv $(shell pwd)/library.sv
TOPLEVEL = Game
MODULE = game_test
SIM = verilator
EXTRA_ARGS += --trace --trace-structs -Wno-fatal
include $(shell cocotb-config --makefiles)/Makefile.sim