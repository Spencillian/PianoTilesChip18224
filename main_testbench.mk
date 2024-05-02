TOPLEVEL_LANG = verilog
VERILOG_SOURCES = $(shell pwd)/src/main.sv $(shell pwd)/src/library.sv $(shell pwd)/src/game.sv $(shell pwd)/src/spi.sv $(shell pwd)/src/random.sv
TOPLEVEL = ChipInterface
MODULE = main_test
SIM = verilator
EXTRA_ARGS += --trace --trace-structs -Wno-fatal
include $(shell cocotb-config --makefiles)/Makefile.sim