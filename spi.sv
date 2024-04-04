`default_nettype none


typedef struct packed {
    logic test_btn;
} spi_data_t;


module SPI(
    output logic mosi, 
    output logic cs,
    input logic miso,

    input spi_data_t inputs,

    output logic clk, 
    input logic rst_n
);

    logic mosi_enable;

    always_ff @(posedge clk) begin
        if(~mosi_enable)
            mosi <= 1'b0;
        else
            mosi <= ~mosi;
    end


    enum logic [1:0] { CLOCK, SEND_DATA } state, next; 

    always_comb begin
        case (state)
            CLOCK: begin
                mosi_enable = 1'b0;

                next = inputs.test_btn ? SEND_DATA : CLOCK;
            end

            SEND_DATA: begin 
                mosi_enable = 1'b0;

                next = inputs.test_btn ? CLOCK : SEND_DATA;
            end

            default: begin
                mosi_enable = 1'b0;

                next = SEND_DATA;
            end
        endcase
    end


    always_ff @(posedge clk) begin
        if (~rst_n)
            state <= CLOCK;
        else 
            state <= next; 
    end

endmodule


module Chip2SPI(
    output logic gp27,
    output logic gp26,
    input logic gp25,
    output logic gp24,

    input logic [6:0] btn,

    output logic [7:0] led
);

    logic clk, mosi, miso, cs;

    assign gp27 = clk;
    assign gp26 = mosi;
    assign gp25 = miso;
    assign gp24 = cs;

    logic rst_n;

    Async2Sync sync0(.async(btn[0]), .sync(rst_n), .clk);

    SPI spi(.clk, .mosi, .miso, .cs, .rst_n);

    assign led[7:1] = '0;
    assign led[0] = (spi.state != spi.CLOCK);

endmodule
