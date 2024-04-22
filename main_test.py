import cocotb
from cocotb.clock import Clock
from cocotb.triggers import *


@cocotb.test()
async def test_main(dut):
    cocotb.start_soon(Clock(dut.clk, 100, units='ns').start())

    dut.value.rst_n = 0
    await FallingEdge()
    dut.value.rst_n = 1

    for i in range(5):
        await FallingEdge()

    dut.value.next_btn = 1

    out = []
    for i in range(10):
        out.append(dut.value.mosi)
        await FallingEdge()
    
    print(out)












