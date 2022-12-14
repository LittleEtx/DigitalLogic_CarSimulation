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

parameter WAITING = 2'b00, TURNING = 2'b01, 
DIR_MOVING = 2'b11, MOVING = 2'b10;
reg [1:0] state;
reg clk_temp;
reg [31:0] cnt;

//state register
always @* begin
    if (~enable) begin
        state <= WAITING;
        out_move_forward <= 1'b0;
        trigger_turn_left <= 1'b0;
        trigger_turn_right <= 1'b0;
        trigger_turn_back <= 1'b0;
        clk_temp = 1'b0;
        cnt <= 0;
    end
end

//state transfrom
always @* begin
    if (enable) begin
        case (state)
            WAITING : begin
                if (move_forward & ~detector[3])
                    state <= DIR_MOVING;
                if (move_left & ~detector[1]) begin
                    cnt <= 0;
                    state <= TURNING;
                    trigger_turn_left <= move_left;
                end
                if (move_right & ~detector[0]) begin
                    cnt <= 0;
                    state <= TURNING;
                    trigger_turn_right <= move_right;
                end
                if (move_backward & ~detector[2]) begin
                    cnt <= 0;
                    state <= TURNING;
                    trigger_turn_back <= move_backward;
                end
            end
            TURNING :
                if ({trigger_turn_back, trigger_turn_left, trigger_turn_right} == 3'b000 && ~is_turning)
                    state <= DIR_MOVING;
            DIR_MOVING : begin
                out_move_forward <= 1'b1;
                if (detector == 4'b0011)
                    state <= MOVING;
            end
            MOVING :
                if (detector != 4'b0011) begin
                    out_move_forward <= 1'b0;
                    state <= WAITING;
                end
        endcase
    end
end

parameter turning = 10; // * 0.002 = 0.02 s
//counting
always @* begin
    if (state == TURNING && {trigger_turn_back, trigger_turn_left, trigger_turn_right} != 3'b000) begin
        $display(cnt);
        if (cnt == (turning >> 1) - 1) begin
            cnt <= 0;
            {trigger_turn_back, trigger_turn_left, trigger_turn_right} <= 3'b000;
        end
        else begin
            if (clk != clk_temp) begin
                if (clk)
                    cnt <= cnt + 1;
                clk_temp = clk;
            end    
        end
    end
end


endmodule
