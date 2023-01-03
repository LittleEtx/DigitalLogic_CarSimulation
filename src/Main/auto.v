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
    output move_backward,
    output trigger_turn_left,
    output trigger_turn_right,
    output trigger_turn_back,
    output place_barrier_signal,
    output destroy_barrier_signal
    ); 
    //TODO
    assign move_forward = 0;
    assign move_backward = 0;
    assign trigger_turn_left = 0;
    assign trigger_turn_right = 0;
    assign trigger_turn_back = 0;
    assign place_barrier_signal = 0;
    assign destroy_barrier_signal = 0;
endmodule
