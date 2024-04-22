`default_nettype none


typedef struct packed {
    logic test_btn;
} spi_data_t;


module SPI(
    output logic mosi, 
    output logic spi_clk,

    input logic clk, 
    input logic rst_n,
    
    input logic next_btn
);

    // code tool potential upgrades: Writing in modules should tell you what 
    // output ports haven't been bound yet

    logic [3:0] count;
    logic [7:0] out_byte;
    logic end_byte;
    logic en_oled_clk;

    parameter [3:0] max_count = 4'b1000;

    // offset spi_clock in order to currectly read data on posedge
    assign spi_clk = ~clk & en_oled_clk & ~next_btn; 
    assign en_oled_clk = count < max_count;
    assign end_byte = count == max_count;

    assign mosi = out_byte[count[2:0]];

    always_ff @(posedge clk) begin
        if(~rst_n) begin
            count <= 4'b1111;
        end else if (next_btn) begin
            count <= 4'b0;
        end else if (count < max_count) begin
            count <= count + 4'b1;
        end
    end

    enum logic [5:0] { 
        ENABLE_CHARGE, 
        ENABLE_CHARGE_, 
        ENABLE_CHARGE1, 
        ENABLE_CHARGE1_,
        SET_CONTRAST,
        SET_CONTRAST_,
        SET_CONTRAST1,
        SET_CONTRAST1_,
        SET_CHARGE, 
        SET_CHARGE_, 
        SET_CHARGE1,
        SET_CHARGE1_,
        POWER_ON_DISPLAY, 
        POWER_ON_DISPLAY_, 
        ENABLE_DISPLAY,
        ENABLE_DISPLAY_,
        WAIT
    } state, next;

    always_comb begin
        case (state)
            ENABLE_CHARGE: begin
                out_byte = 8'h8D;

                next = (end_byte & next_btn) ? ENABLE_CHARGE_ : ENABLE_CHARGE;
            end
            ENABLE_CHARGE_: begin
                out_byte = 8'h00;

                next = (~next_btn) ? ENABLE_CHARGE1 : ENABLE_CHARGE_;
            end
            ENABLE_CHARGE1: begin
                out_byte = 8'h14;

                next = (end_byte & next_btn) ? ENABLE_CHARGE1_ : ENABLE_CHARGE1;
            end
            ENABLE_CHARGE1_: begin
                out_byte = 8'h00;

                next = (~next_btn) ? SET_CONTRAST : ENABLE_CHARGE1_;
            end
            SET_CONTRAST: begin
                out_byte = 8'h81;

                next = (end_byte & next_btn) ? SET_CONTRAST_ : SET_CONTRAST;
            end
            SET_CONTRAST_: begin
                out_byte = 8'h00;

                next = (~next_btn) ? SET_CONTRAST1 : SET_CONTRAST;
            end
            SET_CONTRAST1: begin
                out_byte = 8'hCF;

                next = (end_byte & next_btn) ? SET_CHARGE : SET_CONTRAST1;
            end
            SET_CONTRAST1_: begin
                out_byte = 8'h00;

                next = (~next_btn) ? SET_CHARGE : SET_CONTRAST1;
            end
            SET_CHARGE: begin
                out_byte = 8'hD9;

                next = (end_byte & next_btn) ? SET_CHARGE1 : SET_CHARGE;
            end
            SET_CHARGE_: begin
                out_byte = 8'h00;

                next = (~next_btn) ? SET_CHARGE1 : SET_CHARGE;
            end
            SET_CHARGE1: begin
                out_byte = 8'hF1;

                next = (end_byte & next_btn) ? POWER_ON_DISPLAY : SET_CHARGE1;
            end
            SET_CHARGE1_: begin
                out_byte = 8'h00;

                next = (~next_btn) ? POWER_ON_DISPLAY : SET_CHARGE1;
            end
            POWER_ON_DISPLAY: begin
                out_byte = 8'hA4;

                next = (end_byte & next_btn) ? ENABLE_DISPLAY : POWER_ON_DISPLAY;
            end
            POWER_ON_DISPLAY_: begin
                out_byte = 8'h00;

                next = (~next_btn) ? ENABLE_DISPLAY : POWER_ON_DISPLAY;
            end
            ENABLE_DISPLAY: begin
                out_byte = 8'hAF;

                next = (end_byte & ~next_btn) ? WAIT : ENABLE_DISPLAY;
            end
            ENABLE_DISPLAY_: begin
                out_byte = 8'h00;

                next = (~next_btn) ? WAIT : ENABLE_DISPLAY;
            end
            WAIT: begin
                out_byte = 8'hF0;

                next = WAIT;
            end
            default: begin // need default state to avoid latch infer
                out_byte = 8'h00;

                next = WAIT;
            end
        endcase
    end

    // update next bit on every other cycle to allow for posedge sampling
    always_ff @(negedge clk) begin
        if (~rst_n)
            state <= ENABLE_CHARGE;
        else 
            state <= next; 
    end

endmodule
