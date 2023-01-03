`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/09 14:24:01
// Design Name: 
// Module Name: car_LED
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module car_LED(
    input clk,
    input [1:0] mode,
    input turn_left,
    input turn_right,
    output left_light,
    output right_light
    );

//TODO
assign left_light = 1'b1;
assign right_light = 1'b1;
endmodule
