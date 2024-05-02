TOPLEVEL_LANG = verilog
VERILOG_SOURCES = $(shell pwd)/src/random.sv
TOPLEVEL = Random
MODULE = random_test
SIM = verilator
EXTRA_ARGS += --trace --trace-structs -Wno-fatal
include $(shell cocotb-config --makefiles)/Makefile.sim