import cocotb
from cocotb.clock import Clock
from cocotb.triggers import *

@cocotb.test()
async def test_game(dut):
    cocotb.start_soon(Clock(dut.clk, 100, units='ns').start())

    dut.rst_n.value = 0
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    dut.rst_n.value = 1

    for row in range(8):
        for col in range(128):
            for place in range(8):
                dut.place.value = place
                dut.row.value = row
                dut.col.value = col
                await RisingEdge(dut.clk)
    
    for frame in range(10):
        # clock through pointer reset every frame
        for i in range(48):
            await RisingEdge(dut.clk)

        for row in range(8):
            for col in range(128):
                for place in range(8):
                    dut.place.value = place
                    dut.row.value = row
                    dut.col.value = col
                    await RisingEdge(dut.clk)