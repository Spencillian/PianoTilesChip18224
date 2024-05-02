`default_nettype none

module Random(
    input logic random_source,

    output logic [3:0] tiles,

    input logic clk,
    input logic rst_n
);

    logic [23:0] random_reg;
    logic next_bit;
    assign next_bit = random_reg[23] 
                    ^ random_reg[22] 
                    ^ random_reg[21]
                    ^ random_reg[16]
                    ^ random_reg[0];

    always_ff @(posedge clk) begin
        if(~rst_n)
            random_reg <= 24'h694237;
        else
            random_reg <= {next_bit, random_reg[23] ^ random_source, random_reg[22:1]};
    end

    logic [7:0] mix;
    assign mix = {
        random_reg[0] ^ random_reg[8],
        random_reg[4] ^ random_reg[5],
        random_reg[7] ^ random_reg[2],
        random_reg[3] ^ random_reg[1],
        random_reg[6] ^ random_reg[9],
        random_reg[10] ^ random_reg[15],
        random_reg[12] ^ random_reg[13],
        random_reg[14] ^ random_reg[11]
    };
    
    assign tiles = {
        mix[7] & mix[3],
        mix[6] & mix[2],
        mix[5] & mix[1],
        mix[4] & mix[0]
    };

endmodule