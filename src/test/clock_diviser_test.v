`timescale 1ns / 1ps
module clock_diviser_test ();

reg clk, reset;
wire clk_out;
clock_diviser test(
    .clk(clk),
    .reset(reset),
    .out_clk(clk_out)
);
initial begin
    clk = 1'b0;
    reset = 1'b1;
    #5 reset = 1'b0;
end
always #1 clk = ~clk;

endmodule