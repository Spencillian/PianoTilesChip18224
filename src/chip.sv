`default_nettype none

module my_chip (
    input logic [11:0] io_in, // Inputs to your chip
    output logic [11:0] io_out, // Outputs from your chip
    input logic clock,
    input logic reset // Important: Reset is ACTIVE-HIGH
);

    ChipInterface my_chip(
        .btn({~reset, io_in[5:0]}),
        .clock(clk), //  Run at 25Mhz!!!
        .oled_clk(io_out[11]),
        .oled_mosi(io_out[10]),
        .oled_dc(io_out[9]),
        .oled_res_n(io_out[8]),
        .oled_cs_n(io_out[7])
    );    

endmodule
