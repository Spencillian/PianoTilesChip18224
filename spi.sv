`default_nettype none


typedef struct packed {
    logic test_btn;
} spi_data_t;


module SPI(
    output logic mosi, 
    output logic spi_clk,
    output logic dc,

    input logic clk, 
    input logic rst_n,

    output logic en
);

    // code tool potential upgrades: Writing in modules should tell you what 
    // output ports haven't been bound yet

    logic [4:0] count;
    logic [4:0] count_end;
    logic [31:0] out_byte;
    logic end_byte;

    // offset spi_clock in order to currectly read data on posedge
    assign spi_clk = ~clk & en;
    assign end_byte = count == count_end;

    assign mosi = out_byte[count_end - count] & en;

    always_ff @(posedge clk) begin
        if(~rst_n)
            count <= 5'b0;
        else if (count == count_end)
            count <= 5'b0;
        else
            count <= count + 5'b1;
    end

    enum logic [3:0] { 
        STARTUP,
        ENABLE_CHARGE,
        SET_CONTRAST,
        SET_CHARGE, 

        POWER_ON_DISPLAY,
        ENABLE_DISPLAY,
        SET_DISP_MODE,
        SET_PAGE_ADDR,
        SET_COL_ADDR,

        FRAME,
        FRAME2,
        WAIT
    } state, next;

    always_ff @(posedge clk) begin
        if (~rst_n)
            state <= STARTUP;
        else 
            state <= next;
    end

    logic [15:0] frame_count;
    always_ff @(posedge clk) begin
        if(~rst_n)
            frame_count <= 16'b0;
        else if(frame_end)
            frame_count <= 16'b0;
        else if(state == FRAME || state == FRAME2)
            frame_count <= frame_count + 16'b1;
    end

    logic frame_end;
    assign frame_end = frame_count == 16'h1FFF;

    always_comb begin
        count_end = 5'b00_111;
        case (state)
            STARTUP: begin
                en = 1'b0;
                out_byte = 32'h00_00_00_00;
                dc = 1'b0;

                next = (end_byte) ? ENABLE_CHARGE : STARTUP;
            end
            ENABLE_CHARGE: begin
                en = 1'b1;
                out_byte = 32'h8D_14;
                dc = 1'b0;

                count_end = 5'b01_111;

                next = (end_byte) ? SET_DISP_MODE : ENABLE_CHARGE;
            end
            SET_DISP_MODE: begin
                en = 1'b1;
                out_byte = 32'h20_00;
                dc = 1'b0;

                count_end = 5'b01_111;

                next = (end_byte) ? SET_CONTRAST : SET_DISP_MODE;
            end
            SET_CONTRAST: begin
                en = 1'b1;
                out_byte = 32'h81_CF;
                dc = 1'b0;

                count_end = 5'b01_111;

                next = (end_byte) ? SET_CHARGE : SET_CONTRAST;
            end
            SET_CHARGE: begin
                en = 1'b1;
                out_byte = 32'hD9_F1;
                dc = 1'b0;

                count_end = 5'b01_111;

                next = (end_byte) ? POWER_ON_DISPLAY : SET_CHARGE;
            end
            POWER_ON_DISPLAY: begin
                en = 1'b1;
                out_byte = 32'hA4;
                dc = 1'b0;

                next = (end_byte) ? ENABLE_DISPLAY : POWER_ON_DISPLAY;
            end
            ENABLE_DISPLAY: begin
                en = 1'b1;
                out_byte = 32'hAF;
                dc = 1'b0;

                next = (end_byte) ? SET_PAGE_ADDR : ENABLE_DISPLAY;
            end
            SET_PAGE_ADDR: begin
                en = 1'b1;
                out_byte = 32'h22_00_FF;
                dc = 1'b0;

                count_end = 5'b10_111;

                next = (end_byte) ? SET_COL_ADDR : SET_PAGE_ADDR;
            end
            SET_COL_ADDR: begin
                en = 1'b1;
                out_byte = 32'h21_00_7F;
                dc = 1'b0;

                count_end = 5'b10_111;

                next = (end_byte) ? FRAME : SET_COL_ADDR;
            end
            FRAME: begin
                en = 1'b1;
                out_byte = 32'h01_00_00_00;
                dc = 1'b1;

                count_end = 5'b11_111;

                next = (frame_end) ? FRAME2 : FRAME;
            end
            FRAME2: begin
                en = 1'b1;
                out_byte = 32'h02_00_00_00;
                dc = 1'b1;

                count_end = 5'b11_111;

                next = (frame_end) ? FRAME : FRAME2;
            end
            WAIT: begin
                en = 1'b0;
                out_byte = 32'hFF;
                dc = 1'b0;

                next = WAIT;
            end
            default: begin // need default state to avoid latch infer
                en = 1'b0;
                out_byte = 32'h53;
                dc = 1'b0;

                next = STARTUP;
            end
        endcase
    end
endmodule
