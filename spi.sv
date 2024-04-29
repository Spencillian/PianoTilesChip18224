`default_nettype none


module SPI(
    output logic mosi, 
    output logic spi_clk,
    output logic dc,

    output logic [2:0] row,
    output logic [9:0] col,

    input logic [7:0] data,

    input logic clk, 
    input logic rst_n
);

    // code tool potential upgrades: Writing in modules should tell you what 
    // output ports haven't been bound yet

    logic [4:0] count;
    logic [4:0] count_end;
    logic [31:0] out_byte;
    logic end_byte, en;

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
        REMAP_COLS,
        SCAN_REVERSE,

        POWER_ON_DISPLAY,
        ENABLE_DISPLAY,
        SET_DISP_MODE,
        SET_PAGE_ADDR,
        SET_COL_ADDR,

        CLEAR,
        FRAME,
        WAIT
    } state, next;

    always_ff @(posedge clk) begin
        if (~rst_n)
            state <= STARTUP;
        else 
            state <= next;
    end

    logic col_end, row_end, frame_end;

    assign row_end = row == '1;
    assign col_end = col == '1;
    assign frame_end = col_end && row_end;

    always_ff @(posedge clk) begin
        if(~rst_n) begin
            row <= 3'b0;
            col <= 10'b0;
        end else if (dc && frame_end) begin
            row <= 3'b0;
            col <= 10'b0;
        end else if(dc && col_end) begin
            col <= 10'b0;
            row <= row + 3'b1;
        end else if(dc) begin
            col <= col + 10'b1;
        end
    end

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

                next = (end_byte) ? REMAP_COLS : SET_CHARGE;
            end
            REMAP_COLS: begin
                en = 1'b1;
                out_byte = 32'hA1;
                dc = 1'b0;

                next = (end_byte) ? SCAN_REVERSE : REMAP_COLS;
            end
            SCAN_REVERSE: begin
                en = 1'b1;
                out_byte = 32'hC8;
                dc = 1'b0;

                next = (end_byte) ? POWER_ON_DISPLAY : SCAN_REVERSE;
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
                out_byte = {24'h00_00_00, data};
                dc = 1'b1;

                next = (frame_end) ? WAIT : FRAME;
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
