`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/09 14:18:39
// Design Name: 
// Module Name: auto
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


module auto(
    input enable,
    input clk,
    input start,
    input [3:0] detector,
    output move_forward,
    output turn_left,
    output turn_right,
    output reg move_backward,
    output reg place_barrier_signal,
    output destroy_barrier_signal,
    output reg [3:0] out_state
    ); 
    assign destroy_barrier_signal = 0;
    parameter SEMI_WAITING_STATE = 3'b001;

    parameter WAITING = 4'b0000, MAKING_DESICION = 4'b0001, 
    TRIGGER_FRONT = 4'b0010, TRIGGER_LEFT = 4'b0011, TRIGGER_RIGHT = 4'b0100, TRIGGER_BACK = 4'b0101,
    MOVING = 4'b1000, BACKING = 4'b0110, FORWARD = 4'b0111;
    reg [3:0] state;
    reg [3:0] next_state;

    reg trigger_forward, trigger_left, trigger_right, trigger_back;
    reg semi_enable;
    wire semi_forward;
    wire [2:0] semi_state;
    semi_auto semi_inst(
        .enable(semi_enable),
        .clk(clk),
        .move_forward(trigger_forward),
        .move_left(trigger_left),
        .move_right(trigger_right),
        .move_backward(trigger_back),
        .detector(detector),
        .out_move_forward(semi_forward),
        .turn_left(turn_left),
        .turn_right(turn_right),
        .out_state(semi_state)
    );
    
    always @(*) begin
        if (state == MOVING) begin
            out_state = {state[3], semi_state};
        end else begin
            out_state = state;
        end
    end
    
    reg auto_forward;
    mux_2_to_1 mux_inst(.in({semi_forward, auto_forward}), .sel(semi_enable), .out(move_forward));

    //counting
    reg [31:0] backward_cnt;
    reg [31:0] forward_cnt;
    parameter BACKWARD_TIME = 750; // * 0.002 = 1.5 s
    parameter FORWARD_TIME = 375; // * 0.002 = 0.75 s
    
    //state output
    always @(*) begin
        case (state)
            WAITING, MAKING_DESICION: {auto_forward, move_backward, semi_enable, place_barrier_signal,
                trigger_forward, trigger_left, trigger_right, trigger_back} = 8'b0000_0000;
            TRIGGER_FRONT: {auto_forward, move_backward, semi_enable, place_barrier_signal,
                trigger_forward, trigger_left, trigger_right, trigger_back} = 8'b0010_1000;
            TRIGGER_LEFT: {auto_forward, move_backward, semi_enable, place_barrier_signal,
                trigger_forward, trigger_left, trigger_right, trigger_back} = 8'b0010_0100;
            TRIGGER_RIGHT: {auto_forward, move_backward, semi_enable, place_barrier_signal,
                trigger_forward, trigger_left, trigger_right, trigger_back} = 8'b0010_0010;
            TRIGGER_BACK: {auto_forward, move_backward, semi_enable, place_barrier_signal,
                trigger_forward, trigger_left, trigger_right, trigger_back} = 8'b0010_0001;
            MOVING: {auto_forward, move_backward, semi_enable, place_barrier_signal,
                trigger_forward, trigger_left, trigger_right, trigger_back} = 8'b0010_0000;
            BACKING: {auto_forward, move_backward, semi_enable, place_barrier_signal,
                trigger_forward, trigger_left, trigger_right, trigger_back} = 8'b0100_0000;
            FORWARD: {auto_forward, move_backward, semi_enable, place_barrier_signal,
                trigger_forward, trigger_left, trigger_right, trigger_back} = 8'b1001_0000;
        endcase
    end

    //state transiton
    always @(*) begin
        case (state)
            WAITING: begin
                if (start) begin
                    next_state = MAKING_DESICION;
                end
                else begin
                    next_state = WAITING;
                end
            end
            MAKING_DESICION : begin
                case (detector)
                    4'b0000, 4'b0010, 4'b0100, 4'b0110, 
                    4'b1100, 4'b1110, 4'b1000, 4'b1010: begin
                        next_state = TRIGGER_RIGHT;
                    end
                    4'b0001, 4'b0011, 4'b0101, 4'b0111: begin
                        next_state = TRIGGER_FRONT;
                    end
                    4'b1101, 4'b1001: begin
                        next_state = TRIGGER_LEFT;
                    end
                    4'b1011: begin
                        next_state = TRIGGER_BACK;
                    end
                    default: next_state = WAITING;
                endcase
            end
            TRIGGER_FRONT, TRIGGER_LEFT, TRIGGER_RIGHT, TRIGGER_BACK: begin
                if (semi_state != SEMI_WAITING_STATE) begin
                    next_state = MOVING;
                end
                else begin
                    next_state = state;
                end
            end
            MOVING: begin
                if (semi_state == SEMI_WAITING_STATE) begin
                    next_state = BACKING;
                end
                else begin
                    next_state = MOVING;
                end
            end
            BACKING: begin
                if (backward_cnt == BACKWARD_TIME) begin
                    next_state = FORWARD;
                end
                else begin
                    next_state = BACKING;
                end
            end
            FORWARD: begin
                if (forward_cnt == FORWARD_TIME) begin
                    next_state = MAKING_DESICION;
                end
                else begin
                    next_state = FORWARD;
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
            BACKING: backward_cnt <= backward_cnt + 1;
            default: backward_cnt <= 0;
        endcase
    end

    always @(posedge clk) begin
        case (state)
            FORWARD: forward_cnt <= forward_cnt + 1;
            default: forward_cnt <= 0;
        endcase
    end

endmodule
