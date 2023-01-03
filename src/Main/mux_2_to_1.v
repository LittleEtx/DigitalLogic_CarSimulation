`timescale 1ns / 1ps
module mux_2_to_1 (
    input [1:0] in,
    input sel,
    output reg out
);
always @(*) begin
    if (sel == 1'b0) begin
        out = in[0];
    end else begin
        out = in[1];
    end
end
    
endmodule