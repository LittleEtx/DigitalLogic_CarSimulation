`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/01/04 13:29:07
// Design Name: 
// Module Name: led_sim
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


module led_sim( );
reg clk_sim;
reg turn_left_sim,turn_right_sim;
reg [1:0] state_sim;
wire left_sim,right_sim;
car_LED usrc1(clk_sim,state_sim,turn_left_sim,turn_right_sim,left_sim,right_sim);
initial
  begin
    clk_sim=1'b0;
    state_sim=2'b00;
    {turn_left_sim,turn_right_sim}=2'b00;
    #10 {turn_left_sim,turn_right_sim}=2'b01;
    #10 {turn_left_sim,turn_right_sim}=2'b11;
    #10 {turn_left_sim,turn_right_sim}=2'b10;
    #10 state_sim=2'b01; {turn_left_sim,turn_right_sim}=2'b00;
    #10 {turn_left_sim,turn_right_sim}=2'b01;
    #10 {turn_left_sim,turn_right_sim}=2'b11;
    #10 {turn_left_sim,turn_right_sim}=2'b10;
    #10 state_sim=2'b10; {turn_left_sim,turn_right_sim}=2'b00;
    #10 {turn_left_sim,turn_right_sim}=2'b01;
    #10 {turn_left_sim,turn_right_sim}=2'b11;
    #10 {turn_left_sim,turn_right_sim}=2'b10;
    #10 state_sim=2'b11; {turn_left_sim,turn_right_sim}=2'b00;
    #10 {turn_left_sim,turn_right_sim}=2'b01;
    #10 {turn_left_sim,turn_right_sim}=2'b11;
    #10 {turn_left_sim,turn_right_sim}=2'b10;
    #10 $finish();
  end
always #1 clk_sim=~clk_sim;
endmodule
