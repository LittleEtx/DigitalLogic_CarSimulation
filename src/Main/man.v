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
    input[1:0] state_cur,
    input enable,
    input clk,
    input reverse,
    input brake,
    input clutch,
    input throttle,
    input left,
    input right,
    output reg break,
    output reg move_forward,
    output reg move_backward,
    output reg turn_left,
    output reg turn_right,
    output reg[1:0] state_next
    );
parameter OFF = 2'b00,NOT_STARTING=2'b01,STARTING=2'b11,MOVING=2'b10;
reg[3:0] cur;
reg dir;
reg turn;
reg clk_temp;
reg turn_state=1'b0;

always@(*)
  begin
  if(~enable)
    begin
      state_next <= state_cur;
      {break,move_forward,move_backward,turn_left,turn_right,clk_temp} <= 6'b000000;
    end
  end
  
always@(*)
  begin
  if(enable)
    begin
    cur={reverse,brake,clutch,throttle};
    move_forward=1'b0;
    move_backward=1'b0;
      case(state_cur)
        NOT_STARTING:
          begin
          turn=1'b0;
          break=1'b0;
          dir=1'b0;
            casex(cur)
            4'b0101:state_next <= NOT_STARTING;
            4'bx011:state_next <= STARTING;
            4'bxx01:begin state_next <= OFF;break<=1'b1; end
            4'b1x00:begin state_next <= OFF;break<=1'b1; end
            default:state_next <= NOT_STARTING;
            endcase
          end
        STARTING:
          begin
          turn=1'b1;
          break=1'b0;
          dir=1'b0;
            casex(cur)
            4'b0001:begin state_next <= MOVING; move_forward <= 1'b1;move_backward <= 1'b0;end
            4'b1011:begin state_next <= MOVING; move_forward <= 1'b0;move_backward <= 1'b1; end
            4'b01xx:state_next <= NOT_STARTING;
            4'b111x:state_next <= NOT_STARTING;
            4'b1x0x:begin state_next <= OFF;break<=1'b1; end
            default:state_next <= STARTING;
            endcase
          end
        MOVING:
          begin
          turn=1'b1;
          break=1'b0;
          dir=1'b1;
            casex(cur)
            4'b0001:begin state_next <= MOVING;move_forward <= 1'b1;move_backward <= 1'b0; end
            4'b1x0x:begin state_next <= OFF;break<=1'b1; end
            4'b01xx:state_next <= NOT_STARTING;
            4'b111x:state_next <= NOT_STARTING;
            4'bx0x0:state_next <= STARTING;
            4'b0011:state_next <= STARTING;
            4'b1011:begin state_next <= MOVING;move_forward <= 1'b0;move_backward <= 1'b1; end
            endcase
          end
        default:
          begin
            turn=1'b0;
            break=1'b0;
            dir=1'b0;
            state_next <= state_cur;
          end
      endcase
    turn_left <= turn & left & ~right;
    turn_right <= turn &~left & right;
    if((turn_left || turn_right) && turn_state==1'b0) begin turn_state=1'b1; end
    end
  end
endmodule
