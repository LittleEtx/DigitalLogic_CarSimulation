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
    input enable,
    input clk,
    input reverse,
    input brake,
    input clutch,
    input throttle,
    input left,
    input right,
    input enable_auto_turing,
    input back,
    output reg break,
    output reg move_forward,
    output reg move_backward,
    output reg turn_left,
    output reg turn_right,
    output [1:0] out_state
    );
parameter BREAK = 2'b11, NOT_STARTING = 2'b00, STARTING = 2'b01, MOVING = 2'b10;
reg [1:0] state;
reg [1:0] next_state;

assign out_state = state;

//state output - move
always @(*) begin
  case (state)
    MOVING: begin
      if (reverse) begin
        {move_forward, move_backward} = 2'b01;
      end else begin
        {move_forward, move_backward} = 2'b10;
      end
    end
    default: {move_forward, move_backward} = 2'b00;
    endcase
end

wire auto_left, auto_right;
auto_turning auto_inst(
    .clk(clk),
    .enable(enable_auto_turing),
    .trigger_turn_left(left),
    .trigger_turn_right(right),
    .trigger_turn_back(back),
    .turn_left(auto_left),
    .turn_right(auto_right),
    .is_turning()
    );

//state output - turn
always @(*) begin
  case (state)
    STARTING, MOVING: begin
      if (enable_auto_turing) {turn_left, turn_right} = {auto_left, auto_right};
      else {turn_left, turn_right} = {left, right};
    end
    default: {turn_left, turn_right} = 2'b00;
  endcase
end

//state output - break
always @(*) begin
  case (state)
    BREAK: break = 1'b1;
    default: break = 1'b0;
  endcase
end

reg temp_reverse;

//state transition
always @(*) begin
  case (state)
    NOT_STARTING: begin
      case ({brake, throttle, clutch})
        3'b010: next_state = BREAK;
        3'b011: next_state = STARTING;
        default: next_state = NOT_STARTING;
      endcase
    end
    STARTING: begin
      case ({brake, throttle, clutch})
        3'b100, 3'b101, 3'b110, 3'b111: next_state = NOT_STARTING;
        3'b010: next_state = MOVING;
        default: next_state = STARTING;
      endcase
    end
    MOVING: begin
      if (temp_reverse != reverse) begin
         next_state = BREAK;
      end else begin
        case ({brake, throttle, clutch})
          3'b100, 3'b101, 3'b110, 3'b111: next_state = NOT_STARTING;
          3'b001, 3'b000, 3'b011: next_state = STARTING;
          3'b010: next_state = MOVING;
        endcase
      end 
    end
    default: next_state = state;
  endcase
end

//state register
always@(posedge clk) begin
  temp_reverse <= reverse;
  if (enable) begin
    state <= next_state;
  end else begin
    state <= NOT_STARTING;
  end
end 
endmodule
