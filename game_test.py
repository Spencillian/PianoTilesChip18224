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

    for x in range(1000):
        await RisingEdge(dut.clk)