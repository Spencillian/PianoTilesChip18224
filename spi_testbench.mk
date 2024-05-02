TOPLEVEL_LANG = verilog
VERILOG_SOURCES = $(shell pwd)/src/spi.sv
TOPLEVEL = SPI
MODULE = spi_test
SIM = verilator
EXTRA_ARGS += --trace --trace-structs -Wno-fatal
include $(shell cocotb-config --makefiles)/Makefile.sim