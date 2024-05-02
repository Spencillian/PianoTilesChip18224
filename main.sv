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

    logic [5:0] sbtn;
    Async2Sync async2sync0(.async(btn[0]), .sync(rst_n), .clk(clk));
    Async2Sync async2sync1(.async(btn[1]), .sync(sbtn[0]), .clk(clk));
    Async2Sync async2sync2(.async(btn[2]), .sync(sbtn[1]), .clk(clk));
    Async2Sync async2sync3(.async(btn[3]), .sync(sbtn[2]), .clk(clk));
    Async2Sync async2sync4(.async(btn[4]), .sync(sbtn[3]), .clk(clk));
    Async2Sync async2sync5(.async(btn[5]), .sync(sbtn[4]), .clk(clk));
    Async2Sync async2sync6(.async(btn[6]), .sync(sbtn[5]), .clk(clk));

    logic [2:0] row;
    logic [6:0] col;
    logic [2:0] place;
    logic [7:0] data;

    Game game(
        .row(row),
        .col(col),
        .place(place),
        .btn(sbtn),
        .data(data),
        .dc(oled_dc),
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
        .place(place),
        .data(data)
    );

    assign oled_cs_n = 1'b0;
    assign oled_res_n = rst_n;

    assign led[0] = rst_n;

    assign led[7:1] = '0;
    
endmodule
