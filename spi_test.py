import cocotb
from cocotb.clock import Clock
from cocotb.triggers import *

@cocotb.test()
async def test_spi(dut):
    cocotb.start_soon(Clock(dut.clk, 100, units='ns').start())

    dut.rst_n.value = 0
    await RisingEdge(dut.clk)
    dut.rst_n.value = 1
    await RisingEdge(dut.clk)

    for i in range(8):
        await RisingEdge(dut.clk)

    dut.next_btn.value = 1
    await RisingEdge(dut.clk)
    dut.next_btn.value = 0

    out = []
    for i in range(8):
        out.append(dut.mosi.value)
        await RisingEdge(dut.clk)

    print(out)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)

    dut.next_btn.value = 1
    await RisingEdge(dut.clk)

    out = []
    for i in range(8):
        out.append(dut.mosi.value)
        await RisingEdge(dut.clk)
    
    print(out)
    
    dut.next_btn.value = 0
    await RisingEdge(dut.clk)

    out = []
    for i in range(8):
        out.append(dut.mosi.value)
        await RisingEdge(dut.clk)

    print(out)
    
    for i in range(8):
        await RisingEdge(dut.clk)



