`default_nettype none

module Async2Sync(
    input logic async,
    input logic clk,

    output logic sync
);

    logic metastable;

    always_ff @(posedge clk) begin
        metastable <= async;
        sync <= metastable;
    end

endmodule

module HalfClock(
    input logic clk,
    input logic rst_n,
    
    output logic half_clk
);

    always_ff @(posedge clk) begin
        if(~rst_n)
            half_clk <= clk;
        else
            half_clk <= ~half_clk;
    end

endmodule