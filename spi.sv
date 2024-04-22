`default_nettype none


typedef struct packed {
    logic test_btn;
} spi_data_t;


module SPI(
    output logic mosi, 
    output logic spi_clk,

    input logic clk, 
    input logic rst_n,

    output logic en,
    output logic gets_to,
    output logic end_byte
);

    // code tool potential upgrades: Writing in modules should tell you what 
    // output ports haven't been bound yet

    logic [2:0] count;
    logic [7:0] out_byte;
    logic end_byte;

    // offset spi_clock in order to currectly read data on posedge
    assign spi_clk = ~clk & en;
    assign end_byte =& count;

    assign mosi = out_byte[3'b111 - count];

    always_ff @(posedge clk) begin
        if(~rst_n)
            count <= 3'b0;
        else
            count <= count + 3'b1;
    end

    enum logic [4:0] { 
        STARTUP,

        ENABLE_CHARGE, 
        ENABLE_CHARGE1, 

        SET_CONTRAST,
        SET_CONTRAST1,

        SET_CHARGE, 
        SET_CHARGE1,

        POWER_ON_DISPLAY, 
        ENABLE_DISPLAY,

        SET_PAGE_ADDR,
        SET_PAGE_ADDR1,
        SET_PAGE_ADDR2,

        SET_COL_ADDR,
        SET_COL_ADDR1,
        SET_COL_ADDR2,

        WAIT
    } state, next;

    always_ff @(posedge clk) begin
        if (~rst_n)
            state <= STARTUP;
        else 
            state <= next; 
    end

    always_ff @(posedge clk) begin
        if(~rst_n)
            gets_to <= 0;
        if(state == ENABLE_DISPLAY)
            gets_to <= 1;
    end

    always_comb begin
        case (state)
            STARTUP: begin
                en = 1'b0;
                out_byte = 8'h00;

                next = (end_byte) ? ENABLE_CHARGE : STARTUP;
            end
            ENABLE_CHARGE: begin
                en = 1'b1;
                out_byte = 8'h8D;

                next = (end_byte) ? ENABLE_CHARGE1 : ENABLE_CHARGE;
            end
            ENABLE_CHARGE1: begin
                en = 1'b1;
                out_byte = 8'h14;

                next = (end_byte) ? SET_CONTRAST : ENABLE_CHARGE1;
            end
            SET_CONTRAST: begin
                en = 1'b1;
                out_byte = 8'h81;

                next = (end_byte) ? SET_CONTRAST1 : SET_CONTRAST;
            end
            SET_CONTRAST1: begin
                en = 1'b1;
                out_byte = 8'hCF;

                next = (end_byte) ? SET_CHARGE : SET_CONTRAST1;
            end
            SET_CHARGE: begin
                en = 1'b1;
                out_byte = 8'hD9;

                next = (end_byte) ? SET_CHARGE1 : SET_CHARGE;
            end
            SET_CHARGE1: begin
                en = 1'b1;
                out_byte = 8'hF1;

                next = (end_byte) ? POWER_ON_DISPLAY : SET_CHARGE1;
            end
            POWER_ON_DISPLAY: begin
                en = 1'b1;
                out_byte = 8'hA4;

                next = (end_byte) ? ENABLE_DISPLAY : POWER_ON_DISPLAY;
            end
            ENABLE_DISPLAY: begin
                en = 1'b1;
                out_byte = 8'hAF;

                next = (end_byte) ? SET_PAGE_ADDR : ENABLE_DISPLAY;
            end
            SET_PAGE_ADDR: begin
                en = 1'b1;
                out_byte = 8'h22;

                next = (end_byte) ? SET_PAGE_ADDR1 : SET_PAGE_ADDR;
            end
            SET_PAGE_ADDR1: begin
                en = 1'b1;
                out_byte = 8'h00;

                next = (end_byte) ? SET_PAGE_ADDR2 : SET_PAGE_ADDR1;
            end
            SET_PAGE_ADDR2: begin
                en = 1'b1;
                out_byte = 8'hFF;

                next = (end_byte) ? SET_COL_ADDR : SET_PAGE_ADDR2;
            end
            SET_COL_ADDR: begin
                en = 1'b1;
                out_byte = 8'h21;

                next = (end_byte) ? SET_COL_ADDR1 : SET_COL_ADDR;
            end
            SET_COL_ADDR1: begin
                en = 1'b1;
                out_byte = 8'h00;

                next = (end_byte) ? SET_COL_ADDR2 : SET_COL_ADDR1;
            end
            SET_COL_ADDR2: begin
                en = 1'b1;
                out_byte = 8'h7F;

                next = (end_byte) ? WAIT : SET_COL_ADDR2;
            end
            WAIT: begin
                out_byte = 8'hFF;
                en = 1'b0;

                next = WAIT;
            end
            default: begin // need default state to avoid latch infer
                en = 1'b0;
                out_byte = 8'h53;

                next = STARTUP;
            end
        endcase
    end


endmodule
