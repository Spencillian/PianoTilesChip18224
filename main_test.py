import cocotb
from cocotb.clock import Clock
from cocotb.triggers import *
from cocotb.binary import *


@cocotb.test()
async def test_main(dut):
    cocotb.start_soon(Clock(dut.clk25, 100, units='ns').start())

    dut.btn.value = 0
    await RisingEdge(dut.clk25)
    await RisingEdge(dut.clk25)
    dut.btn.value = 1

    # for i in range(8*128*8):
    #     await RisingEdge(dut.clk25)
    await RisingEdge(dut.oled_dc)

    screen = []
    for row in range(8):
        for col in range(128):
            internal = []
            for place in range(8):
                internal.append(dut.game.data.value)
                await RisingEdge(dut.clk25)
            # simplified = [1 if val != 0 else 0 for val in internal]
            # assert not (1 in simplified and 0 in simplified), f"simplified: {simplified} row: {row} col: {col}"
            screen.append(internal)
    
    rows = []
    for k in range(8):
        for i in range(8):
            row = []
            for j in range(128):
                row.append(1 if screen[j + k*128][i] != 0 else 0)
            rows.append(row)
    
    for arr in rows:
        for val in arr:
            print(val, end="")
        print(" | ")