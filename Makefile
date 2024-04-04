.PHONY: main

main:
	@echo "Error: Not implemented use `make spi`"

spi:
	yosys -p 'read_verilog -sv library.sv spi.sv; synth_ecp5 -json builds/synth_out.json -top Chip2SPI'

fpga:
	nextpnr-ecp5 --12k --json builds/synth_out.json --lpf constraints.lpf --textcfg builds/pnr_out.config
	ecppack --compress builds/pnr_out.config builds/bitstream.bit
	fujprog builds/bitstream.bit