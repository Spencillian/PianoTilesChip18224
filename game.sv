`default_nettype none


module Game(
    input logic [2:0] row,
    input logic [9:0] col,
    input logic [6:0] btn,

    output logic [7:0] data,

    input logic dc,

    input logic clk, 
    input logic rst_n
);

    logic frame, pframe;
    assign frame = row == '1 && col == '1;
    
    logic [5:0] count;
    logic tick;
    assign tick = count == '1;
    always_ff @(posedge clk) begin
        if(~rst_n)
            count <= '0;
        else if(tick)
            count <= '0;
        else if(~pframe & frame)
            count <= count + 10'b1;
        pframe <= frame;
    end

    always_ff @(posedge clk) begin
        if(~rst_n)
            data <= '0;
        else if(col[2:0] == 3'b0)
            data <= data_out;
    end

    logic [3:0] new_tiles;
    always_ff @(posedge clk) begin
        if(~rst_n)
            new_tiles <= 4'b0001;
        else if (tick && new_tiles == 4'b1000)
            new_tiles <= 4'b0001;
        else if (tick)
            new_tiles <= new_tiles << 1;
    end

    logic [19:0] tiles;
    Tiles tilesreg(
        .new_tiles(new_tiles),
        .shift(tick),
        .tiles(tiles),
        .clk(clk),
        .rst_n(rst_n)
    );

    logic data_out;
    DisplayTiles displaytiles(
        .tiles(tiles),
        .col(col),
        .row(row),
        .data(data_out),
        .clk(clk),
        .rst_n(rst_n)
    );
    
endmodule

module DisplayTiles(
    input logic [19:0] tiles,
    input logic [9:0] col,
    input logic [2:0] row,

    output logic [7:0] data,

    input logic clk,
    input logic rst_n
);

    always_comb begin
        if(col < 10'hf6) begin
            if(row < 3'h2) begin
                data = (tiles[0]) ? 8'hFF : 9'h00;
            end else if (row < 3'h4) begin
                data = (tiles[1]) ? 8'hFF : 8'h00;
            end else if (row < 3'h6) begin
                data = (tiles[2]) ? 8'hFF : 8'h00;
            end else begin
                data = (tiles[3]) ? 8'hFF : 8'h00;
            end
        end else if (col < 10'h200) begin
            if(row < 3'h2) begin
                data = (tiles[4]) ? 8'hFF : 8'h00;
            end else if (row < 3'h4) begin
                data = (tiles[5]) ? 8'hFF : 8'h00;
            end else if (row < 3'h6) begin
                data = (tiles[6]) ? 8'hFF : 8'h00;
            end else begin
                data = (tiles[7]) ? 8'hFF : 8'h00;
            end
        end else if (col < 10'h300) begin
            if(row < 3'h2) begin
                data = (tiles[8]) ? 8'hFF : 8'h00;
            end else if (row < 3'h4) begin
                data = (tiles[9]) ? 8'hFF : 8'h00;
            end else if (row < 3'h6) begin
                data = (tiles[10]) ? 8'hFF : 8'h00;
            end else begin
                data = (tiles[11]) ? 8'hFF : 8'h00;
            end
        end else begin
            if(row < 3'h2) begin
                data = (tiles[12]) ? 8'hFF : 8'h00;
            end else if (row < 3'h4) begin
                data = (tiles[13]) ? 8'hFF : 8'h00;
            end else if (row < 3'h6) begin
                data = (tiles[14]) ? 8'hFF : 8'h00;
            end else begin
                data = (tiles[15]) ? 8'hFF : 8'h00;
            end
        end
    end

endmodule 

module Tiles(
    input logic [3:0] new_tiles,
    input logic shift,

    output logic [19:0] tiles,

    input logic clk,
    input logic rst_n
);

    always_ff @(posedge clk) begin
        if(~rst_n) begin
            tiles <= 20'h0;
        end else if (shift) begin
            tiles[3:0] <= new_tiles;
            tiles[7:4] <= tiles[3:0];
            tiles[11:8] <= tiles[7:4];
            tiles[15:12] <= tiles[11:8];
            tiles[19:16] <= tiles[15:12];
        end
    end

endmodule