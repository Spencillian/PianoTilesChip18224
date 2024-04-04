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