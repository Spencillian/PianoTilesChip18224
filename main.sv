`default_nettype none

module ChipInterface(
    output logic [7:0] led,
    input logic [6:0] btn,

    input logic clk25,

    output logic oled_clk,
    output logic oled_mosi,
    output logic oled_dc,
    output logic oled_res_n,
    output logic oled_cs_n
);

    logic clk, rst_n;
    // assign clk = clk25;
    pll3 p(.clkin(clk25), .clkout0(clk), .locked()); // 25Mhz -> 3.25Mhz

    logic next_btn;
    Async2Sync s0(.async(btn[1]), .sync(next_btn), .clk(clk));
    Async2Sync s1(.async(btn[0]), .sync(rst_n), .clk(clk));

    logic [2:0] row;
    logic [9:0] col;
    logic [7:0] data;

    Game game(
        .row(row),
        .col(col),
        .btn(btn),
        .data(data),
        .clk(clk),
        .rst_n(rst_n)
    );

    SPI spi(
        .mosi(oled_mosi), 
        .spi_clk(oled_clk), 
        .clk(clk), 
        .rst_n(rst_n),
        .dc(oled_dc),
        .row(row),
        .col(col),
        .data(data)
    );

    assign oled_cs_n = 1'b0;
    assign oled_res_n = rst_n;

    assign led[0] = next_btn;
    assign led[1] = rst_n;

    assign led[7:2] = '0;
    
endmodule
