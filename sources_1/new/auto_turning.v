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

parameter turning = 750; // * 0.002 = 1.5 s
reg [31:0] max_cnt;
reg [31:0] cnt;
reg clk_temp;

//state initialize
always @* begin
    if (~enable) begin
        is_turning = 1'b0;
        clk_temp = 1'b0;
        turn_right = 1'b0;
        turn_left = 1'b0;
        cnt <= 0;
    end
end

//state transfering
always @* begin
    if (enable) begin
        if (is_turning) begin
            if (cnt == max_cnt) begin
                cnt <= 0;
                is_turning <= 1'b0;
                turn_left <= 1'b0;
                turn_right <= 1'b0;
            end
        end else begin
            case ({trigger_turn_left, trigger_turn_right, trigger_turn_back})
                3'b100: begin
                    turn_left <= 1'b1;
                    is_turning <= 1'b1;
                    max_cnt <= (turning >> 1) - 1;
                end
                3'b010: begin
                    turn_right <= 1'b1;
                    is_turning <= 1'b1;
                    max_cnt <= (turning >> 1) - 1;
                end
                3'b001: begin
                    turn_left <= 1'b1;
                    is_turning <= 1'b1;
                    max_cnt <= ((turning >> 1) - 1) << 1;
                end
                default: ; //do nothing
            endcase
        end
    end
end

always @* begin
    if (is_turning && clk != clk_temp) begin
        if (clk)begin
            cnt <= cnt + 1;
        end
        clk_temp = clk;       
    end
end
    
endmodule