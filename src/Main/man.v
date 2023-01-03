`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/09 14:03:54
// Design Name: 
// Module Name: man
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


module man(
    input enable,
    input clk,
    input reverse,
    input brake,
    input clutch,
    input throttle,
    input left,
    input right,
    output break,
    output move_forward,
    output move_backward,
    output turn_left,
    output turn_right
    );
endmodule
