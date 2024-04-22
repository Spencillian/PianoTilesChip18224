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
    assign clk = clk25;
    // pll3 p(.clkin(clk25), .clkout0(clk), .locked()); // 25Mhz -> 8.33Mhz

    logic next_btn;
    Async2Sync s0(.async(btn[1]), .sync(next_btn), .clk(clk));
    Async2Sync s1(.async(btn[0]), .sync(rst_n), .clk(clk));

    logic [14:0] halfs;
    HalfClock h0(.clk(clk), .rst_n(rst_n), .half_clk(halfs[0]));
    HalfClock h1(.clk(halfs[0]), .rst_n(rst_n), .half_clk(halfs[1]));
    HalfClock h2(.clk(halfs[1]), .rst_n(rst_n), .half_clk(halfs[2]));
    HalfClock h3(.clk(halfs[2]), .rst_n(rst_n), .half_clk(halfs[3]));
    HalfClock h4(.clk(halfs[3]), .rst_n(rst_n), .half_clk(halfs[4]));
    HalfClock h5(.clk(halfs[4]), .rst_n(rst_n), .half_clk(halfs[5]));
    HalfClock h6(.clk(halfs[5]), .rst_n(rst_n), .half_clk(halfs[6]));
    HalfClock h7(.clk(halfs[6]), .rst_n(rst_n), .half_clk(halfs[7]));
    HalfClock h8(.clk(halfs[7]), .rst_n(rst_n), .half_clk(halfs[8]));
    HalfClock h9(.clk(halfs[8]), .rst_n(rst_n), .half_clk(halfs[9]));
    HalfClock h10(.clk(halfs[9]), .rst_n(rst_n), .half_clk(halfs[10]));
    HalfClock h11(.clk(halfs[10]), .rst_n(rst_n), .half_clk(halfs[11]));
    HalfClock h12(.clk(halfs[11]), .rst_n(rst_n), .half_clk(halfs[12]));
    HalfClock h13(.clk(halfs[12]), .rst_n(rst_n), .half_clk(halfs[13]));
    HalfClock h14(.clk(halfs[13]), .rst_n(rst_n), .half_clk(halfs[14]));

    logic en, gets_to;
    SPI spi(
        .mosi(oled_mosi), 
        .spi_clk(oled_clk), 
        .clk(halfs[10]), 
        .rst_n(rst_n), 
        .en(en),
        .gets_to(gets_to)
    );

    assign oled_cs_n = 1'b0;
    assign oled_dc = 1'b0;
    assign oled_res_n = rst_n;

    assign led[0] = next_btn;
    assign led[1] = rst_n;
    assign led[2] = en;
    assign led[3] = gets_to;

    assign led[7:4] = '0;
    
endmodule
