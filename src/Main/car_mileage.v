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

parameter FORWARD_COUNT = 46; // * 0.002s = 0.09s
parameter BACKWARD_COUNT = 92; // * 0.002s = 0.18s

reg [1:0] state;
reg [31:0] forward_cnt;
reg [31:0] backward_cnt;
parameter STOP = 2'b00, FORWARD = 2'b01, BACKWARD = 2'b10, CLEAR = 2'b11;

//state output
reg [15:0] temp_mile;
always@(*) begin
  case (state)
    CLEAR: temp_mile = 16'b0;
    STOP: temp_mile = mile;
    FORWARD: begin
      if (forward_cnt == FORWARD_COUNT - 1)
        temp_mile = mile + 1;
      else
        temp_mile = mile;
    end
    BACKWARD: begin
      if (backward_cnt == BACKWARD_COUNT - 1)
        temp_mile = mile + 1;
      else
        temp_mile = mile;
    end
  endcase
end

//state transition
always @(*) begin
  case ({reset, move_forward, move_backward})
    3'b000, 3'b111: state = STOP;
    3'b010: state = FORWARD;
    3'b001: state = BACKWARD;
    default: state = CLEAR;
  endcase
end

//counting
always @(posedge clk) begin 
  case (state)
    FORWARD: begin
      backward_cnt <= backward_cnt;
      if (forward_cnt == FORWARD_COUNT - 1)
        forward_cnt <= 0;
      else
        forward_cnt <= forward_cnt + 1;
    end
    BACKWARD: begin
      if (backward_cnt == BACKWARD_COUNT - 1)
        backward_cnt <= 0;
      else
        backward_cnt <= backward_cnt + 1;
    end
    STOP: begin
      forward_cnt <= forward_cnt;
      backward_cnt <= backward_cnt;
    end
    CLEAR: begin
      forward_cnt <= 0;
      backward_cnt <= 0;
    end
  endcase
end

reg [2:0] carry;
wire [3:0] added_mile1;
wire [3:0] added_mile2;
wire [3:0] added_mile3;
assign added_mile1 = temp_mile[7:4] + carry[0];
assign added_mile2 = temp_mile[11:8] + carry[1];
assign added_mile3 = temp_mile[15:12] + carry[2];
//convert binary to BCD code
always @(posedge clk) begin
  case (temp_mile[3:0]) 
    4'b1010, 4'b1011, 4'b1100, 4'b1101, 
    4'b1110, 4'b1111: {carry[0], mile[3:0]} <= {1'b1, temp_mile[3:0] - 4'b1010};
    default: {carry[0], mile[3:0]} <= {1'b0, temp_mile[3:0]};
  endcase
  case (added_mile1) 
    4'b1010, 4'b1011, 4'b1100, 4'b1101, 
    4'b1110, 4'b1111: {carry[1], mile[7:4]} <= {1'b1, added_mile1 - 4'b1010};
    default: {carry[1], mile[7:4]} <= {1'b0, added_mile1};
  endcase
  case (added_mile2) 
    4'b1010, 4'b1011, 4'b1100, 4'b1101, 
    4'b1110, 4'b1111: {carry[2], mile[11:8]} <= {1'b1, added_mile2 - 4'b1010};
    default: {carry[2], mile[11:8]} <= {1'b0, added_mile2};
  endcase
  case (added_mile3) 
    4'b1010, 4'b1011, 4'b1100, 4'b1101, 
    4'b1110, 4'b1111: mile[15:12] <= added_mile3 - 4'b1010;
    default: mile[15:12] <= added_mile3;
  endcase
end


endmodule

