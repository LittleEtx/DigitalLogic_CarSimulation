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
reg is_turning_temp;
reg turn_left_temp;
reg turn_right_temp;

//state transfering
always @* begin
    if (is_turning) begin
        if (cnt == max_cnt) begin
            is_turning_temp = 1'b0;
        end else begin
            is_turning_temp = 1'b1;
        end
    end else begin
        case ({trigger_turn_left, trigger_turn_right, trigger_turn_back})
            3'b100: begin
                turn_left_temp = 1'b1;
                is_turning_temp = 1'b1;
                max_cnt = (turning >> 1) - 1;
            end
            3'b010: begin
                turn_right_temp = 1'b1;
                is_turning_temp = 1'b1;
                max_cnt = (turning >> 1) - 1;
            end
            3'b001: begin
                turn_left_temp = 1'b1;
                is_turning_temp = 1'b1;
                max_cnt <= ((turning >> 1) - 1) << 1;
            end
            default: begin
                //do nothing
                is_turning_temp = 1'b0;
                turn_left_temp = 1'b0;
                turn_right_temp = 1'b0;
            end 
        endcase
    end
end

//counter
always @(posedge clk) begin
    if (is_turning) begin
        cnt <= cnt + 1;
    end else begin
        cnt <= 0;
    end
end

//state register
always @(posedge clk) begin
    if (enable) begin
        {is_turning, turn_left, turn_right} <= {is_turning_temp, turn_left_temp, turn_right_temp};
    end else begin
        {is_turning, turn_left, turn_right} = 3'b000;
    end
end

endmodule