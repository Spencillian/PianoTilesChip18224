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

    logic [2:0] count;
    logic [7:0] out_byte;
    logic end_byte;
    logic en;

    // offset spi_clock in order to currectly read data on posedge
    assign spi_clk = ~clk & en;
    assign end_byte =& count;

    assign mosi = out_byte[count];

    always_ff @(posedge clk) begin
        if(~rst_n)
            count <= 3'b0;
        else
            count <= count + 3'b1;
    end

    enum logic [5:0] { 
        STARTUP,
        ENABLE_CHARGE, 
        ENABLE_CHARGE1, 
        SET_CONTRAST,
        SET_CONTRAST1,
        SET_CHARGE, 
        SET_CHARGE1,
        POWER_ON_DISPLAY, 
        ENABLE_DISPLAY,
        WAIT
    } state, next;

    always_comb begin
        en = 1'b1;
        case (state)
            STARTUP: begin
                en = 1'b0;
                out_byte = 8'h00;

                next = (end_byte) ? ENABLE_CHARGE : STARTUP;
            end
            ENABLE_CHARGE: begin
                out_byte = 8'h8D;

                next = (end_byte) ? ENABLE_CHARGE1 : ENABLE_CHARGE;
            end
            ENABLE_CHARGE1: begin
                out_byte = 8'h14;

                next = (end_byte) ? SET_CONTRAST : ENABLE_CHARGE1;
            end
            SET_CONTRAST: begin
                out_byte = 8'h81;

                next = (end_byte) ? SET_CONTRAST1 : SET_CONTRAST;
            end
            SET_CONTRAST1: begin
                out_byte = 8'hCF;

                next = (end_byte) ? SET_CHARGE : SET_CONTRAST1;
            end
            SET_CHARGE: begin
                out_byte = 8'hD9;

                next = (end_byte) ? SET_CHARGE1 : SET_CHARGE;
            end
            SET_CHARGE1: begin
                out_byte = 8'hF1;

                next = (end_byte) ? POWER_ON_DISPLAY : SET_CHARGE1;
            end
            POWER_ON_DISPLAY: begin
                out_byte = 8'hA4;

                next = (end_byte) ? ENABLE_DISPLAY : POWER_ON_DISPLAY;
            end
            ENABLE_DISPLAY: begin
                out_byte = 8'hAF;

                next = (end_byte) ? WAIT : ENABLE_DISPLAY;
            end
            WAIT: begin
                out_byte = 8'hFF;
                en = 1'b0;

                next = WAIT;
            end
            default: begin // need default state to avoid latch infer
                out_byte = 8'h00;

                next = WAIT;
            end
        endcase
    end

    always_ff @(negedge clk) begin
        if (~rst_n)
            state <= STARTUP;
        else 
            state <= next; 
    end

endmodule
