`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/09 14:26:48
// Design Name: 
// Module Name: car_mileage
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

module car_mileage(
  input clk,
  input reset,
  input move_forward,
  input move_backward,
  output reg [15:0] mile
  );

reg clk_div;
parameter div = 25;

reg [15:0] temp_mile;
always@(posedge clk_div) begin
  if(reset)
    temp_mile <= 0;
  else if(move_forward | move_backward)
    temp_mile <= mile + 1;
  else
    temp_mile <= mile;
end

reg [31:0] cnt;
//counting
always @(posedge clk) begin 
  if (reset) begin
    cnt <= 0;
    clk_div <= 1'b0;
  end else begin
    if (cnt == div - 1) begin
      clk_div <= ~clk_div;
      cnt <= 0;
    end
    else begin
      cnt <= cnt + 1;
    end
  end
end

reg [2:0] carry;
//convert binary to BCD code
always @(*) begin
  case (temp_mile[3:0]) 
    4'b1010, 4'b1011, 4'b1100, 4'b1101, 
    4'b1110, 4'b1111: {carry[0], mile[3:0]} <= {1'b1, temp_mile[3:0] - 4'b1010};
    default: {carry[0], mile[3:0]} <= {1'b0, temp_mile[3:0]};
  endcase
  case (temp_mile[7:4] + carry[0]) 
    4'b1010, 4'b1011, 4'b1100, 4'b1101, 
    4'b1110, 4'b1111: {carry[1], mile[7:4]} <= {1'b1, temp_mile[7:4] - 4'b1010};
    default: {carry[1], mile[7:4]} <= {1'b0, temp_mile[7:4]};
  endcase
  case (temp_mile[11:8] + carry[1]) 
    4'b1010, 4'b1011, 4'b1100, 4'b1101, 
    4'b1110, 4'b1111: {carry[2], mile[11:8]} <= {1'b1, temp_mile[11:8] - 4'b1010};
    default: {carry[2], mile[11:8]} <= {1'b0, temp_mile[11:8]};
  endcase
  case (temp_mile[15:12] + carry[2]) 
    4'b1010, 4'b1011, 4'b1100, 4'b1101, 
    4'b1110, 4'b1111: mile[15:12] <= temp_mile[15:12] - 4'b1010;
    default: mile[15:12] <= temp_mile[15:12];
  endcase
end


endmodule

