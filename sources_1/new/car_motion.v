`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/09 14:22:48
// Design Name: 
// Module Name: car_motion
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


module car_motion(
    input model,
    input state,
    input move_forward,
    input move_backward,
    input clockwise,
    input degree,
    input clk,
    output turn_left_signal,
    output turn_right_signal,
    output move_forward_signal,
    output move_backward_signal,
    output place_barrier_signal,
    output destroy_barrier_signal
    );
endmodule
