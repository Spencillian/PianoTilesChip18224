import cocotb
from cocotb.clock import Clock
from cocotb.triggers import *

@cocotb.test()
async def test_spi(dut):
    cocotb.start_soon(Clock(dut.clk, 100, units='ns').start())

    dut.rst_n.value = 1
    await RisingEdge(dut.clk)
    dut.rst_n.value = 0
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)

    for i in range(50):
        assert(dut.mosi.value == 0)
        await RisingEdge(dut.clk)

    dut.rst_n.value = 1
    await RisingEdge(dut.clk)

    assert dut.dc.value == 0

    # wait for startup buffer
    for i in range(8):
        assert dut.dc.value == 0
        await RisingEdge(dut.clk)
    
    assert dut.dc.value == 0
    byte = await get_byte(dut)
    assert byte == '0x8d'

    assert dut.dc.value == 0
    byte = await get_byte(dut)
    assert byte == '0x14'

    assert dut.dc.value == 0
    byte = await get_byte(dut)
    assert byte == '0x20'

    assert dut.dc.value == 0
    byte = await get_byte(dut)
    assert byte == '0x0'

    assert dut.dc.value == 0
    byte = await get_byte(dut)
    assert byte == '0x81'

    assert dut.dc.value == 0
    byte = await get_byte(dut)
    assert byte == '0xcf'

    assert dut.dc.value == 0
    byte = await get_byte(dut)
    assert byte == '0xd9'

    assert dut.dc.value == 0
    byte = await get_byte(dut)
    assert byte == '0xf1'

    assert dut.dc.value == 0
    byte = await get_byte(dut)
    assert byte == '0xa1'

    assert dut.dc.value == 0
    byte = await get_byte(dut)
    assert byte == '0xc8'

    assert dut.dc.value == 0
    byte = await get_byte(dut)
    assert byte == '0xa4'

    assert dut.dc.value == 0
    byte = await get_byte(dut)
    assert byte == '0xaf'

    # End start up sequence
    # Set start pointer

    assert dut.dc.value == 0
    byte = await get_byte(dut)
    assert byte == '0x22'

    assert dut.dc.value == 0
    byte = await get_byte(dut)
    assert byte == '0x0'

    assert dut.dc.value == 0
    byte = await get_byte(dut)
    assert byte == '0xff'

    assert dut.dc.value == 0
    byte = await get_byte(dut)
    assert byte == '0x21'

    assert dut.dc.value == 0
    byte = await get_byte(dut)
    assert byte == '0x0'

    assert dut.dc.value == 0
    byte = await get_byte(dut)
    assert byte == '0x7f'

    # clock through one frame and check that data is asserted correctly
    await RisingEdge(dut.clk)
    assert dut.dc.value == 1


async def get_byte(dut):
    out = []
    for i in range(8):
        out.append(dut.mosi.value)
        await RisingEdge(dut.clk)
    
    return hex(int(''.join([str(val) for val in out]), 2))

