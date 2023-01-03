`timescale 1ns / 1ps
module car_seg (
    input clk, //500Hz
    input [1:0] mode,
    input [15:0] mile,
    output [7:0] seg_en,
    output [7:0] seg_out0,
    output [7:0] seg_out1
);

//TODO
assign seg_en = 8'b1111_1111;
assign seg_out0 = 8'b0110_0000;
assign seg_out1 = 8'b1101_1010;

endmodule