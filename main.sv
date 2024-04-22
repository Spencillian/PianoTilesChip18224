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
    pll3 p(.clkin(clk25), .clkout0(clk), .locked()); // 25Mhz -> 8.33Mhz

    logic next_btn;
    Async2Sync s0(.async(btn[1]), .sync(next_btn), .clk);
    Async2Sync s1(.async(btn[0]), .sync(rst_n), .clk);

    logic [3:0] pclk;
    always_ff @(posedge clk) begin
        if(~rst_n)
            pclk <= 4'b0;
        else
            pclk <= pclk + 4'b1;
    end

    SPI spi(.mosi(oled_mosi), .spi_clk(oled_clk), .clk(pclk[3]), .rst_n, .next_btn);

    assign oled_cs_n = 1'b0;
    assign oled_dc = 1'b0;
    assign oled_res_n = rst_n;

    assign led[0] = next_btn;
    assign led[1] = rst_n;
    assign led[7:2] = '0;
    
endmodule
