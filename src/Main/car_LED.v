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
    input[1:0] state,
    input turn_left,
    input turn_right,
    output reg left_light,
    output reg right_light
    );
parameter OFF = 2'b00,NOT_STARTING=2'b01,STARTING=2'b11,MOVING=2'b10;
reg cnt=1'b0;
always@(posedge clk or state)
  begin
  if(cnt==1'b0) begin
  left_light=1'b0;
  right_light=1'b0;
  end
  cnt=1'b1;
  case(state)
  OFF:
    begin
    left_light<=1'b0;
    right_light<=1'b0;
    end
  NOT_STARTING:
    begin
    left_light<=1'b1;
    right_light<=1'b1;
    end
  default begin
    case({turn_left,turn_right})
    2'b10: begin left_light<=~left_light;  right_light<=1'b0; end
    2'b01: begin right_light<=~right_light; left_light<=1'b0; end
    default begin right_light<=1'b0; left_light<=1'b0; end
    endcase
    end
  endcase
  end
endmodule
