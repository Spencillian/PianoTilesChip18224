`default_nettype none

module Random(
    input logic random_source,

    output logic [3:0] tiles,

    input logic clk,
    input logic rst_n
);

    logic [23:0] random_reg;
    logic next_byte;
    assign next_bit = (random_reg 
                    ^ (random_reg >> 1) 
                    ^ (random_reg >> 2)
                    ^ (random_reg >> 7)
                    ^ (random_reg >> 23)) & 1;
    
    always_ff @(posedge clk) begin
        if(~rst_n)
            random_reg <= 24'h694237;
        else
            random_reg <= {next_bit, random_reg[23:1]};
    end

    assign tiles = random_reg[4:1] & random_reg[3:0];

endmodule