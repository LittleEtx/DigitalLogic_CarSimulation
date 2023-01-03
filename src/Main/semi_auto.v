`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/09 14:10:53
// Design Name: 
// Module Name: semi_command
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


module semi_auto(
    input enable,
    input clk, //500Hz
    input is_turning,
    input move_forward,
    input move_left,
    input move_right,
    input move_backward,
    input [3:0] detector,
    output reg out_move_forward,
    output reg trigger_turn_left,
    output reg trigger_turn_right,
    output reg trigger_turn_back
    );

parameter WAITING = 3'b001, 
TRIGGER_LEFT = 3'b010, TRIGGER_RIGHT = 3'b011, TRIGGER_BACK = 3'b100, TURNING = 3'b101, 
DIR_MOVING = 3'b110, MOVING = 3'b111;
reg [2:0] state;
reg [31:0] cnt;
reg [2:0] next_state;
reg turn_left;
reg turn_right;
reg turn_back;

//state output
always @* begin
    case (state)
        WAITING, TURNING : begin
            out_move_forward = 1'b0;
            {turn_left, turn_right, turn_back} = 3'b000;
        end 
        TRIGGER_LEFT : begin
            out_move_forward = 1'b0;
            {turn_left, turn_right, turn_back} = 3'b100;
        end
        TRIGGER_RIGHT : begin
            out_move_forward = 1'b0;
            {turn_left, turn_right, turn_back} = 3'b010;
        end
        TRIGGER_BACK : begin
            out_move_forward = 1'b0;
            {turn_left, turn_right, turn_back} = 3'b001;
        end
        DIR_MOVING, MOVING : begin
            out_move_forward = 1'b1;
            {turn_left, turn_right, turn_back} = 3'b000;
        end
    endcase
end

//state transfrom
always @* begin
    case (state)
        WAITING : begin       
            case ({move_forward, move_left, move_right, move_backward, detector})
                8'b1000_0000, 8'b1000_0001, 8'b1000_0010, 8'b1000_0011, 
                8'b1000_0100, 8'b1000_1001, 8'b1000_0110, 8'b1000_0111: begin
                    next_state = DIR_MOVING;
                end
                8'b0100_0000, 8'b0100_0001, 8'b0100_0100, 8'b0100_0101,
                8'b0100_1000, 8'b0100_1001, 8'b0100_1100, 8'b0100_1101: begin
                    next_state = TRIGGER_LEFT;
                end
                8'b0010_0000, 8'b0010_0010, 8'b0010_0100, 8'b0010_0110,
                8'b0010_1000, 8'b0010_1010, 8'b0010_1100, 8'b0010_1110: begin
                    next_state = TRIGGER_BACK;
                end
                8'b0001_0000, 8'b0001_0001, 8'b0001_0010, 8'b0001_0011,
                8'b0001_1000, 8'b0001_1001, 8'b0001_1010, 8'b0001_1011: begin
                    next_state = TRIGGER_RIGHT;
                end
                default: begin
                    next_state = WAITING;
                end
            endcase
        end
        TRIGGER_LEFT, TRIGGER_RIGHT, TRIGGER_BACK : begin
            if (cnt == (turning >> 1) - 1)
                next_state = TURNING;
            else
                next_state = state;
        end
        TURNING : begin
            if (~is_turning)
                next_state = DIR_MOVING;
            else
                next_state = TURNING;
        end
        DIR_MOVING : begin
            if (detector == 4'b0011)
                next_state = MOVING;
            else
                next_state = DIR_MOVING;
        end
        MOVING : begin
            case (detector)
                4'b0011: next_state = MOVING;
                4'b1011: next_state = TRIGGER_BACK;
                4'b1001: next_state = TRIGGER_LEFT;
                4'b1010: next_state = TRIGGER_RIGHT;
                default: next_state = WAITING;
            endcase
        end
    endcase
end

//state register
always @(posedge clk) begin
    if (enable) begin
        {state, trigger_turn_back, trigger_turn_left, trigger_turn_right} <= {next_state, turn_back, turn_left, turn_right};
    end else begin
        {state, trigger_turn_back, trigger_turn_left, trigger_turn_right} <= {WAITING, 3'b000};
    end
end


parameter turning = 10; // * 0.002 = 0.02 s
//counting
always @(posedge clk) begin
    case (state)
        TRIGGER_LEFT, TRIGGER_RIGHT, TRIGGER_BACK: cnt <= cnt + 1;
        default: cnt <= 0;
    endcase
end


endmodule
