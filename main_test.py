import cocotb
from cocotb.clock import Clock
from cocotb.triggers import *
from cocotb.binary import *


@cocotb.test()
async def test_main(dut):
    cocotb.start_soon(Clock(dut.clk, 100, units='ns').start())

    dut.btn.value = 0
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    dut.btn.value = 1

    # read and print frame
    await RisingEdge(dut.oled_dc)

    screen = []
    for row in range(8):
        for col in range(128):
            internal = []
            for place in range(8):
                internal.append(str(dut.game.data.value)[7-place])
                await RisingEdge(dut.clk)
            screen.append(internal)
    
    rows = []
    for k in range(8):
        for i in range(8):
            row = []
            for j in range(128):
                row.append(screen[j + k*128][i])
            rows.append(row)
    
    for arr in rows:
        for val in arr:
            print(val, end="")
        print(" | ")