TOPLEVEL_LANG = verilog
VERILOG_SOURCES = $(shell pwd)/main.sv $(shell pwd)/library.sv $(shell pwd)/pll25mhzto8mhz.sv
TOPLEVEL = ChipInterface
MODULE = main_test
SIM = verilator
EXTRA_ARGS += --trace --trace-structs -Wno-fatal
include $(shell cocotb-config --makefiles)/Makefile.sim