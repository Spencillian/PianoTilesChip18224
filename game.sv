`default_nettype none


module Game(
    input logic [2:0] row,
    input logic [6:0] col,
    input logic [2:0] place,
    input logic [5:0] btn,

    output logic [7:0] data,

    input logic dc,

    input logic clk, 
    input logic rst_n
);

    logic frame, pframe;
    assign frame = row == '1 && col == '1 && place == '1;
    
    logic [11:0] count, count_end;
    logic tick;
    assign tick = count == count_end;
    always_ff @(posedge clk) begin
        if(~rst_n)
            count <= '0;
        else if(tick)
            count <= '0;
        else if(~pframe & frame)
            count <= count + 1'b1;
        pframe <= frame;
    end

    enum logic [2:0] { WAIT, WAIT1, WAIT2, PLAY, PLAY1, PLAY2, GAMEOVER } state, next;
    logic game_over, playing;
    logic [6:0] stages;
    logic [7:0] tile_data, text_data;

    always_ff @(posedge tick, negedge rst_n) begin
        if(~rst_n)
            stages <= '0;
        else if(playing)
            stages <= stages + 1'b1;
        else
            stages <= '0;
    end

    always_comb begin
        count_end = 12'b0011_1111_1111;
        playing = '0;
        case (state)
            WAIT: begin
                next = (btn[5]) ? WAIT1 : WAIT;

                data = text_data;
            end
            WAIT1: begin
                next = (~btn[5] && tick) ? WAIT2 : WAIT1;

                data = text_data;
            end
            WAIT2: begin
                next = (tick) ? PLAY : WAIT2;

                data = text_data;
            end
            PLAY: begin
                if(game_over)
                    next = GAMEOVER;
                else if(stages >= 5'ha)
                    next = PLAY1;
                else
                    next = PLAY;
                
                count_end = 12'b0111_1111_1111;
                playing = 1'b1;

                data = tile_data ^ mask;
            end
            PLAY1: begin
                if(game_over)
                    next = GAMEOVER;
                else if(stages >= 5'h28)
                    next = PLAY2;
                else
                    next = PLAY1;

                count_end = 12'b0111_1101_1111;
                playing = 1'b1;

                data = tile_data ^ mask;
            end
            PLAY2: begin
                if(game_over)
                    next = GAMEOVER;
                else
                    next = PLAY2;

                count_end = 12'b0111_0111_1111;
                playing = 1'b1;

                data = tile_data ^ mask;
            end
            GAMEOVER: begin
                next = (gameover_anim_count == '1) ? WAIT : GAMEOVER;

                data = text_data;
            end
            default: begin
                next = WAIT;

                data = 8'h00;
            end
        endcase
    end

    logic [2:0] gameover_anim_count;
    always_ff @(posedge tick, negedge rst_n) begin
        if(~rst_n)
            gameover_anim_count <= '0;
        else if(state == GAMEOVER)
            gameover_anim_count <= gameover_anim_count + 1'b1;
        else
            gameover_anim_count <= '0;
    end

    always_ff @(posedge clk) begin
        if(~rst_n)
            state <= WAIT;
        else
            state <= next;
    end

    logic [3:0] new_tiles, random_tiles;
    Random random(
        .random_source(
            (btn[0] ^ 
            btn[1] ^ 
            btn[3] ^ 
            btn[4] ^ 
            btn[5]) & tick),
        .tiles(random_tiles),
        .clk(clk),
        .rst_n(rst_n)
    );

    assign new_tiles = (state == PLAY 
                     || state == PLAY1 
                     || state == PLAY2) ? random_tiles : 4'h0;
    logic [19:0] tiles;
    Tiles tilesreg(
        .new_tiles(new_tiles),
        .shift(tick),
        .tiles(tiles),
        .clk(clk),
        .rst_n(rst_n)
    );

    DisplayTiles displaytiles(
        .tiles(tiles),
        .col(col),
        .row(row),
        .place(place),
        .data(tile_data),
        .clk(clk),
        .rst_n(rst_n)
    );

    DisplayText displaytext(
        .col(col),
        .row(row),
        .place(place),
        .tick(tick),
        .game_over(state == GAMEOVER),
        .data(text_data),
        .clk(clk),
        .rst_n(rst_n)
    );

    logic [7:0] mask;
    ButtonDetector buttondetector(
        .btn({btn[5], btn[3], btn[1], btn[0]}),
        .tiles(tiles[15:12]),
        .tick(tick),
        .col(col),
        .row(row),
        .mask(mask),
        .game_over(game_over),
        .clk(clk),
        .rst_n(rst_n)
    );
    
endmodule

module ButtonDetector(
    input logic [3:0] btn,
    input logic [3:0] tiles,
    input logic tick,
    input logic [6:0] col,
    input logic [2:0] row,

    output logic game_over,
    output logic [7:0] mask,

    input logic clk,
    input logic rst_n
);

    logic [3:0] press_reg;
    always_ff @(posedge clk) begin
        if(~rst_n) begin
            press_reg <= '0;
            game_over <= '0;
        end else if(tick) begin
            press_reg <= '0;
            game_over <= !(press_reg == tiles);
        end else begin
            press_reg <= press_reg | btn;
            game_over <= '0;
        end
    end

    always_comb begin
        mask = 8'h00;
        if(col[6:5] == 2'b11) begin
            mask = (press_reg[row[2:1]]) ? 8'h55 : 8'h00;
        end
    end

endmodule

module DisplayText(
    input logic [6:0] col,
    input logic [2:0] row,
    input logic [2:0] place,
    input logic tick,
    input logic game_over,

    output logic [7:0] data,
    
    input logic clk,
    input logic rst_n
);

    logic [63:0] p;
    assign p = {
        8'b00100000,
        8'b00100000,
        8'b00100000,
        8'b00111000,
        8'b00100100,
        8'b00100100,
        8'b00100100,
        8'b00111000
    };
    
    logic [63:0] l;
    assign l = {
        8'b00111100,
        8'b00100000,
        8'b00100000,
        8'b00100000,
        8'b00100000,
        8'b00100000,
        8'b00100000,
        8'b00100000
    };

    logic [63:0] a;
    assign a = {
        8'b00100100,
        8'b00100100,
        8'b00100100,
        8'b00111100,
        8'b00100100,
        8'b00100100,
        8'b00100100,
        8'b00011000
    };

    logic [63:0] y;
    assign y = {
        8'b00011000,
        8'b00001000,
        8'b00001000,
        8'b00011000,
        8'b00100100,
        8'b00100100,
        8'b00100100,
        8'b00100100
    };

    logic [63:0] g;
    assign g = {
        8'b00011000,
        8'b00100100,
        8'b00100100,
        8'b00101100,
        8'b00100000,
        8'b00100100,
        8'b00100100,
        8'b00011000
    };

    logic [63:0] m;
    assign m = {
        8'b01000010,
        8'b01000010,
        8'b01000010,
        8'b01011010,
        8'b01011010,
        8'b01100110,
        8'b01100110,
        8'b01000010
    };

    logic [63:0] e;
    assign e = {
        8'b00111100,
        8'b00100000,
        8'b00100000,
        8'b00111000,
        8'b00100000,
        8'b00100000,
        8'b00100000,
        8'b00111100
    };

    logic [63:0] o;
    assign o = {
        8'b00011000,
        8'b00100100,
        8'b00100100,
        8'b00100100,
        8'b00100100,
        8'b00100100,
        8'b00100100,
        8'b00011000
    };

    logic [63:0] v;
    assign v = {
        8'b00011000,
        8'b00100100,
        8'b00100100,
        8'b00100100,
        8'b01000010,
        8'b01000010,
        8'b01000010,
        8'b01000010
    };

    logic [63:0] r;
    assign r = {
        8'b00100100,
        8'b00100100,
        8'b00100100,
        8'b00111000,
        8'b00100100,
        8'b00100100,
        8'b00100100,
        8'b00111000
    };

    logic text_loc;
    always_ff @(posedge tick, negedge rst_n) begin
        if(~rst_n)
            text_loc <= 0;
        else
            text_loc <= ~text_loc;
    end

    always_comb begin
        if(~game_over) begin
            if(row == 3'h5) begin
                data = (col[3] ^ text_loc) ? p[{col[2:0], 3'b000}+:8] : 8'h00;
            end else if(row == 3'h4) begin
                data = (col[3] ^ text_loc) ? l[{col[2:0], 3'b000}+:8] : 8'h00;
            end else if(row == 3'h3) begin
                data = (col[3] ^ text_loc) ? a[{col[2:0], 3'b000}+:8] : 8'h00;
            end else if(row == 3'h2) begin
                data = (col[3] ^ text_loc) ? y[{col[2:0], 3'b000}+:8] : 8'h00;
            end else begin
                data = 8'h00;
            end
        end else begin
            if(row == 3'h7) begin
                data = (col[3] ^ text_loc) ? g[{col[2:0], 3'b000}+:8] : 8'h00;
            end else if(row == 3'h6) begin
                data = (col[3] ^ text_loc) ? a[{col[2:0], 3'b000}+:8] : 8'h00;
            end else if(row == 3'h5) begin
                data = (col[3] ^ text_loc) ? m[{col[2:0], 3'b000}+:8] : 8'h00;
            end else if(row == 3'h4) begin
                data = (col[3] ^ text_loc) ? e[{col[2:0], 3'b000}+:8] : 8'h00;
            end else if(row == 3'h3) begin
                data = (col[3] ^ text_loc) ? o[{col[2:0], 3'b000}+:8] : 8'h00;
            end else if(row == 3'h2) begin
                data = (col[3] ^ text_loc) ? v[{col[2:0], 3'b000}+:8] : 8'h00;
            end else if(row == 3'h1) begin
                data = (col[3] ^ text_loc) ? e[{col[2:0], 3'b000}+:8] : 8'h00;
            end else if(row == 3'h0) begin
                data = (col[3] ^ text_loc) ? r[{col[2:0], 3'b000}+:8] : 8'h00;
            end else begin
                data = 8'h00;
            end
        end
    end

endmodule

module DisplayTiles(
    input logic [19:0] tiles,
    input logic [6:0] col,
    input logic [2:0] place,
    input logic [2:0] row,

    output logic [7:0] data,

    input logic clk,
    input logic rst_n
);

    logic place_start;
    assign place_start = place == 3'h0;
    
    logic [4:0] tile_loc;
    assign tile_loc = {1'b0, col[6:5], row[2:1]};

    assign data = (tiles[tile_loc]) ? 8'hFF & vert_mask & horz_mask : 8'h00;

    logic [7:0] vert_mask, horz_mask;
    assign vert_mask = (col == 7'h0 
                     || col == 7'h1f
                     || col == 7'h20 
                     || col == 7'h3f
                     || col == 7'h40
                     || col == 7'h5f
                     || col == 7'h60
                     || col == 7'h7f) ? 8'h00 : 8'hFF;
    
    assign horz_mask = (row[0]) ? 8'h7F : 8'hFE;

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