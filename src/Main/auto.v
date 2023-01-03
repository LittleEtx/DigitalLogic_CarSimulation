`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/09 14:18:39
// Design Name: 
// Module Name: auto
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


module auto(
    input enable,
    input clk,
    input moving,
    input is_turning,
    input [3:0] detector,
    output move_forward,
    output trigger_turn_left,
    output trigger_turn_right,
    output trigger_turn_back,
    output place_barrier_signal,
    output destroy_barrier_signal
    ); 
endmodule
