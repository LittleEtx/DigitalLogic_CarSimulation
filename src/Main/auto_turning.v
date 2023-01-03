`timescale 1ns / 1ps
module auto_turning (
    input clk, //500HZ
    input enable,
    input trigger_turn_left,
    input trigger_turn_right,
    input trigger_turn_back,
    output reg turn_left,
    output reg turn_right,
    output reg is_turning
);

parameter TURNING_TIME = 450; // * 0.002 = 0.9 s
reg [31:0] max_cnt;
reg [31:0] cnt;
reg is_turning_temp;
reg turn_left_temp;
reg turn_right_temp;

reg [1:0] state;
reg [1:0] next_state;
parameter WAITING = 2'b00, LEFT_TURNING = 2'b01, RIGHT_TURNING = 2'b10, BACK_TURNING = 2'b11;

//state output
always @* begin
    case (state)
        WAITING :  {turn_left, turn_right, is_turning} = 3'b000;
        LEFT_TURNING : {turn_left, turn_right, is_turning} = 3'b101;
        RIGHT_TURNING : {turn_left, turn_right, is_turning} = 3'b011;
        BACK_TURNING : {turn_left, turn_right, is_turning} = 3'b011;
    endcase
end

//state transfering
always @* begin
    case (state)
        WAITING : begin
            case ({trigger_turn_left, trigger_turn_right, trigger_turn_back})
                3'b100: next_state = LEFT_TURNING;
                3'b010: next_state = RIGHT_TURNING;
                3'b001: next_state = BACK_TURNING;
                default:  next_state = WAITING;
            endcase
        end
        LEFT_TURNING, RIGHT_TURNING: begin
            if (cnt == TURNING_TIME - 1) begin
                next_state = WAITING;
            end else begin
                next_state = state;
            end
        end 
        BACK_TURNING : begin
            if (cnt == (TURNING_TIME << 1) - 1) begin
                next_state = WAITING;
            end else begin
                next_state = state;
            end
        end
    endcase
end

//counter
always @(negedge clk) begin
    case (state)
        LEFT_TURNING, RIGHT_TURNING, BACK_TURNING: cnt <= cnt + 1;
        default: cnt <= 0;
    endcase
end

//state register
always @(negedge clk) begin
    if (enable) begin
        state <= next_state;
    end else begin
        state <= WAITING;
    end
end

endmodule