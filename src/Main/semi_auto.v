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
    input move_forward,
    input move_left,
    input move_right,
    input move_backward,
    input [3:0] detector,
    output reg out_move_forward,
    output turn_left,
    output turn_right,
    output [2:0] out_state
    );

parameter WAITING = 3'b001, 
TRIGGER_LEFT = 3'b010, TRIGGER_RIGHT = 3'b011, TRIGGER_BACK = 3'b100, TURNING = 3'b101, 
DIR_MOVING = 3'b110, MOVING = 3'b111, MOVING_END = 3'b000;
reg [2:0] state;
reg [2:0] next_state;
//trigger time
parameter TURNING_TRIGGER = 100; // * 0.002 = 0.2 s
parameter MOVING_END_TIME = 50; // * 0.002 = 0.1 s
reg [31:0] turn_cnt;
reg [31:0] moving_end_cnt;

assign out_state = state;

//auto_turning
reg trigger_turn_left, trigger_turn_right, trigger_turn_back;
wire is_turning;
auto_turning auto_inst(
    .clk(clk),
    .enable(enable),
    .trigger_turn_left(trigger_turn_left),
    .trigger_turn_right(trigger_turn_right),
    .trigger_turn_back(trigger_turn_back),
    .turn_left(turn_left),
    .turn_right(turn_right),
    .is_turning(is_turning)
);

//state output
always @* begin
    case (state)
        WAITING, TURNING : begin
            {out_move_forward, trigger_turn_left, trigger_turn_right, trigger_turn_back} = 4'b0000;
        end 
        TRIGGER_LEFT : begin
            {out_move_forward, trigger_turn_left, trigger_turn_right, trigger_turn_back} = 4'b0100;
        end
        TRIGGER_RIGHT : begin
            {out_move_forward, trigger_turn_left, trigger_turn_right, trigger_turn_back} = 4'b0010;
        end
        TRIGGER_BACK : begin
            {out_move_forward, trigger_turn_left, trigger_turn_right, trigger_turn_back} = 4'b0001;
        end
        DIR_MOVING, MOVING, MOVING_END : begin
            {out_move_forward, trigger_turn_left, trigger_turn_right, trigger_turn_back} = 4'b1000;
        end
    endcase
end

//state transition
always @* begin
    case (state)
        WAITING : begin       
            case ({move_forward, move_left, move_right, move_backward, detector})
                8'b1000_0000, 8'b1000_0001, 8'b1000_0010, 8'b1000_0011, 
                8'b1000_0100, 8'b1000_0101, 8'b1000_0110, 8'b1000_0111: begin
                    next_state = DIR_MOVING;
                end
                8'b0100_0000, 8'b0100_0001, 8'b0100_0100, 8'b0100_0101,
                8'b0100_1000, 8'b0100_1001, 8'b0100_1100, 8'b0100_1101: begin
                    next_state = TRIGGER_LEFT;
                end
                8'b0010_0000, 8'b0010_0010, 8'b0010_0100, 8'b0010_0110,
                8'b0010_1000, 8'b0010_1010, 8'b0010_1100, 8'b0010_1110: begin
                    next_state = TRIGGER_RIGHT;
                end
                8'b0001_0000, 8'b0001_0001, 8'b0001_0010, 8'b0001_0011,
                8'b0001_1000, 8'b0001_1001, 8'b0001_1010, 8'b0001_1011: begin
                    next_state = TRIGGER_BACK;
                end
                default: begin
                    next_state = WAITING;
                end
            endcase
        end
        TRIGGER_LEFT, TRIGGER_RIGHT, TRIGGER_BACK : begin
            if (turn_cnt == TURNING_TRIGGER - 1) begin
                next_state = TURNING;
            end else begin
                next_state = state;
            end
        end
        TURNING : begin
            if (~is_turning) begin
                next_state = DIR_MOVING;
            end else begin
                next_state = TURNING;
            end
        end
        DIR_MOVING : begin
            if (detector == 4'b0011) begin
                next_state = MOVING;
            end else begin
                next_state = DIR_MOVING;
            end
        end
        MOVING : begin
            if (~detector[1] || ~detector[0] || detector[3]) begin 
                next_state = MOVING_END;
            end else begin
                next_state = MOVING;
            end   
        end
        MOVING_END : begin
            if (moving_end_cnt == MOVING_END_TIME - 1) begin
                case (detector)
                    4'b1011: next_state = TRIGGER_BACK;
                    4'b1001: next_state = TRIGGER_LEFT;
                    4'b1010: next_state = TRIGGER_RIGHT;
                    default: next_state = WAITING;
                endcase
            end else begin
                next_state = MOVING_END;
            end
        end
    endcase
end

//state register
always @(posedge clk) begin
    if (enable) begin
        state <= next_state;
    end else begin
        state <= WAITING;
    end
end

//counting
always @(posedge clk) begin
    case (state)
        TRIGGER_LEFT, TRIGGER_RIGHT, TRIGGER_BACK: turn_cnt <= turn_cnt + 1;
        default: turn_cnt <= 0;
    endcase
end

always @(posedge clk) begin
    case (state)
        MOVING_END: moving_end_cnt <= moving_end_cnt + 1;
        default: moving_end_cnt <= 0;
    endcase
end


endmodule
