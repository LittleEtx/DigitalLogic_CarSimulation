`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/01/04 17:02:17
// Design Name: 
// Module Name: seg_sim
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


module seg_sim( );
reg clk_sim;
reg [1:0] mode_sim,state_sim;
wire[7:0] seg_en_sim,seg0_sim,seg1_sim;
car_mileage usrc1(clk_sim,mode_sim,state_sim,seg_en_sim,seg0_sim,seg1_sim);
initial
  begin
  clk_sim=1'b1;
  mode_sim=2'b01;
  state_sim=2'b00;
  #10 state_sim=2'b10;
  #50 mode_sim=2'b10;
  #50 mode_sim=2'b11;
  end
always #1 clk_sim=~clk_sim;
endmodule
