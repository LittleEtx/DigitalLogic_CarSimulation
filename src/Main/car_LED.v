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
    input stay_left,
    input stay_right,
    input twinkle_left,
    input twinkle_right,
    output reg left_light,
    output reg right_light
    );

always@(posedge clk) begin
  case ({stay_left, twinkle_left})
    2'b10, 2'b11: left_light <= 1'b1;
    2'b01: left_light <= ~left_light;
    default: left_light <= 1'b0;
  endcase
end

always@(posedge clk) begin
  case ({stay_right, twinkle_right})
    2'b10, 2'b11: right_light <= 1'b1;
    2'b01: right_light <= ~right_light;
    default: right_light <= 1'b0;
  endcase
end


endmodule
