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
    output [3:0] out_state
    ); 
    assign destroy_barrier_signal = 0;
    parameter SEMI_WAITING_STATE = 3'b001, SEMI_DIR_MOVING_STATE = 3'b110,
    SEMI_TRIGGER_TURN_BACK = 3'b100, SEMI_TRIGGER_TURN_LEFT = 3'b010, SEMI_TRIGGER_TURN_RIGHT = 3'b011;

    parameter WAITING = 4'b0000, MAKING_DESICION = 4'b0001, 
    TRIGGER_FRONT = 4'b0010, TRIGGER_LEFT = 4'b0011, TRIGGER_RIGHT = 4'b0100, TRIGGER_BACK = 4'b0101,
    TURNING = 4'b1000, MOVING_FROM_END = 4'b1010, MOVING = 4'b1001, BACKING = 4'b0110, FORWARD = 4'b0111,
    TRIGGER_LOOP = 4'b1100, LOOP_TURN_LEFT = 4'b1101, LOOP_TURN_RIGHT = 4'b1110, LOOP_TURNING = 4'b1111;
    reg [3:0] state;
    reg [3:0] next_state;
    assign out_state = state;

    //semi auto
    reg trigger_forward, trigger_left, trigger_right, trigger_back;
    wire semi_turn_left, semi_turn_right;
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
        .turn_left(semi_turn_left),
        .turn_right(semi_turn_right),
        .out_state(semi_state)
    );
    
    reg auto_forward;
    mux_2_to_1 mux_inst(.in({semi_forward, auto_forward}), .sel(semi_enable), .out(move_forward));
    always @(*) begin
        case (state)
            TRIGGER_FRONT: {trigger_forward, trigger_left, trigger_right, trigger_back} = 4'b1000;
            TRIGGER_LEFT: {trigger_forward, trigger_left, trigger_right, trigger_back} = 4'b0100;
            TRIGGER_RIGHT: {trigger_forward, trigger_left, trigger_right, trigger_back} = 4'b0010;
            TRIGGER_BACK: {trigger_forward, trigger_left, trigger_right, trigger_back} = 4'b0001;
            default: {trigger_forward, trigger_left, trigger_right, trigger_back} = 4'b0000;
        endcase
    end
    always @(*) begin
        case (state)
            TRIGGER_FRONT, TRIGGER_LEFT, TRIGGER_RIGHT, TRIGGER_BACK,
            TURNING, MOVING_FROM_END, MOVING: 
                semi_enable = 1'b1;
            default: semi_enable = 1'b0;
        endcase
    end


    //auto turning
    wire auto_turn_left, auto_turn_right, auto_is_turning;
    reg auto_turn_trigger_left, auto_turn_trigger_right;
    reg auto_turn_enable;
    auto_turning auto_turn_inst(
        .enable(auto_turn_enable),
        .clk(clk),
        .trigger_turn_left(auto_turn_trigger_left),
        .trigger_turn_right(auto_turn_trigger_right),
        .trigger_turn_back(1'b0),
        .turn_left(auto_turn_left),
        .turn_right(auto_turn_right),
        .is_turning(auto_is_turning)
    );

    mux_4_to_1 mux_turn_left(.in({1'b0, auto_turn_left, semi_turn_left, 1'b0}), 
        .sel({auto_turn_enable, semi_enable}), .out(turn_left));
    mux_4_to_1 mux_turn_right(.in({1'b0, auto_turn_right, semi_turn_right, 1'b0}),
        .sel({auto_turn_enable, semi_enable}), .out(turn_right));
    
    always @(*) begin
        case (state)
            LOOP_TURN_LEFT: {auto_turn_enable, auto_turn_trigger_left, auto_turn_trigger_right} = 3'b110;
            LOOP_TURN_RIGHT: {auto_turn_enable, auto_turn_trigger_left, auto_turn_trigger_right} = 3'b101;
            LOOP_TURNING: {auto_turn_enable, auto_turn_trigger_left, auto_turn_trigger_right} = 3'b100;
            default: {auto_turn_enable, auto_turn_trigger_left, auto_turn_trigger_right} = 3'b000;
        endcase
    end

    //counting
    reg [31:0] backward_cnt;
    reg [31:0] forward_cnt;
    parameter BACKWARD_TIME = 750; // * 0.002 = 2.0 s
    parameter FORWARD_TIME = 375; // * 0.002 = 1.0 s

    //coordinate and direction
    reg [31:0] x;
    reg [31:0] y;
    reg [31:0] mark_x;
    reg [31:0] mark_y;
    reg [1:0] dir;
    reg [1:0] mark_dir;
    parameter NORTH = 2'b00, EAST = 2'b01, SOUTH = 2'b10, WEST = 2'b11;

    //coordinate control
    always @(posedge clk) begin
        if (enable) begin
            case ({move_forward, move_backward})
                2'b10: begin
                    case (dir)
                        NORTH: x <= x + 1;
                        EAST: y <= y + 1;
                        SOUTH: x <= x - 1;
                        WEST: y <= y - 1;
                    endcase
                end
                2'b01: begin
                    case (dir)
                        NORTH: x <= x - 1;
                        EAST: y <= y - 1;
                        SOUTH: x <= x + 1;
                        WEST: y <= y + 1;
                    endcase
                end
                default: begin
                    x <= x;
                    y <= y;
                end
            endcase
        end else begin
            x <= 0;
            y <= 0;
        end
    end

    reg [3:0] old_state;
    always @(posedge clk) begin
        old_state <= state;
    end
    reg [2:0] old_semi_state;
    always @(posedge clk) begin
        old_semi_state <= semi_state;
    end

    //direction control
    always @(posedge clk) begin
        if (enable) begin
            if (state == MOVING) begin
                if (old_semi_state != semi_state) begin
                    case (semi_state)
                        SEMI_TRIGGER_TURN_LEFT: dir <= dir - 1;
                        SEMI_TRIGGER_TURN_RIGHT: dir <= dir + 1;
                        default: dir <= dir;
                    endcase
                end else begin
                    dir <= dir;
                end
            end else if (old_state != state && state == TURNING) begin
                case (old_state)
                    TRIGGER_LEFT, LOOP_TURN_LEFT: dir <= dir - 1;
                    TRIGGER_RIGHT, LOOP_TURN_RIGHT: dir <= dir + 1;
                    TRIGGER_BACK, MOVING: dir <= dir + 2;
                    default: dir <= dir;
                endcase
            end else begin
                dir <= dir;
            end
        end else begin
            dir <= NORTH;
        end
    end

    //mark control
    reg remark;
    always @(posedge clk) begin
        if (enable) begin
            if (old_state != state && state == MAKING_DESICION) begin
                case (old_state)
                    WAITING, FORWARD: remark <= 1'b1;
                    default: remark <= 1'b0;
                endcase
            end else begin
                remark <= remark;
            end
        end else begin
            remark <= 1'b0;
        end
    end

    //remark
    parameter REMARK_COUNT = 1000;
    reg trigger_remark_delay;
    reg [31:0] remark_count;
    reg [31:0] temp_mark_x;
    reg [31:0] temp_mark_y;
    reg [1:0] temp_mark_dir;
    always @(posedge clk) begin
        if (state != old_state && state == MOVING && remark) begin
            temp_mark_x <= x;
            temp_mark_y <= y;
            temp_mark_dir <= dir;
            trigger_remark_delay <= 1'b1;
        end else begin
            temp_mark_x <= temp_mark_x;
            temp_mark_y <= temp_mark_y;
            temp_mark_dir <= temp_mark_dir;
            trigger_remark_delay <= 1'b0;
        end
    end
    //counting for remark delay
    reg trigger_remark;
    always @(posedge clk) begin
        if (enable) begin 
            if (remark_count != 0 || trigger_remark_delay) begin
                if (remark_count == REMARK_COUNT) begin
                    trigger_remark <= 1'b1;
                    remark_count <= 0;
                end else begin
                    trigger_remark <= 1'b0;
                    remark_count <= remark_count + 1;
                end
            end else begin
                trigger_remark <= 1'b0;
                remark_count <= 0;
            end
        end else begin
            trigger_remark <= 1'b0;
            remark_count <= 0;
        end
    end

    always @(posedge clk) begin
        case ({enable, trigger_remark})
            2'b10: begin
                mark_x <= mark_x;
                mark_y <= mark_y;
                mark_dir <= mark_dir;
            end
            2'b11: begin
                mark_x <= temp_mark_x;
                mark_y <= temp_mark_y;
                mark_dir <= temp_mark_dir;
            end
            default: begin
                mark_x <= 1 << 30;
                mark_y <= 1 << 30;
                mark_dir <= NORTH;
            end
        endcase
    end

    //delta x and y, take abs value
    wire [31:0] temp_delta_x;
    assign temp_delta_x = x - mark_x;
    wire [31:0] temp_delta_y;
    assign temp_delta_y = y - mark_y;
    reg [31:0] delta_x;
    reg [31:0] delta_y;
    always @(*) begin
        if (temp_delta_x[31]) begin
            delta_x = -temp_delta_x;
        end else begin
            delta_x = temp_delta_x;
        end
    end
    always @(*) begin
        if (temp_delta_y[31]) begin
            delta_y = -temp_delta_y;
        end else begin
            delta_y = temp_delta_y;
        end
    end
    
    //forward and backing output
    always @(*) begin
        case (state)
            BACKING: {auto_forward, move_backward, place_barrier_signal} = 3'b010;
            FORWARD: {auto_forward, move_backward, place_barrier_signal} = 3'b101;
            default: {auto_forward, move_backward, place_barrier_signal} = 3'b000;
        endcase
    end

    //state transiton
    always @(*) begin
        case (state)
            WAITING: begin
                if (start) begin 
                    next_state = MAKING_DESICION;
                end else begin
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
                    next_state = TURNING;
                end else begin                                        
                    next_state = state;
                end
            end
            TURNING: begin
                if (semi_state == SEMI_DIR_MOVING_STATE) begin
                    if (detector == 4'b0111) begin
                        next_state = MOVING_FROM_END;
                    end else begin
                        next_state = MOVING;
                    end
                end else begin
                    next_state = TURNING;
                end
            end
            MOVING: begin
                case (semi_state)
                    SEMI_TRIGGER_TURN_BACK: next_state = TURNING; 
                    SEMI_WAITING_STATE: next_state = MAKING_DESICION;
                    default: begin
                        if (delta_x >> 5 == 32'b0 && delta_y >> 5 == 32'b0 && dir == mark_dir) begin
                            next_state = TRIGGER_LOOP;
                        end else begin
                            next_state = MOVING;
                        end
                    end
                endcase
            end
            MOVING_FROM_END: begin
                case (semi_state)
                    SEMI_WAITING_STATE: next_state = BACKING;
                    SEMI_TRIGGER_TURN_BACK: next_state = WAITING;
                    default: next_state = MOVING_FROM_END;
                endcase
            end
            TRIGGER_LOOP: begin
                case (detector)
                    4'b0000, 4'b0010, 4'b0110: next_state = LOOP_TURN_LEFT; 
                    4'b0101: next_state = LOOP_TURN_RIGHT;
                    4'b0001, 4'b0011: next_state = BACKING;
                    default: next_state = WAITING; //unexpected
                endcase
            end
            LOOP_TURN_LEFT, LOOP_TURN_RIGHT: begin
                if (auto_is_turning) begin
                    next_state = LOOP_TURNING;
                end else begin
                    next_state = state;
                end
            end
            LOOP_TURNING: begin
                if (auto_is_turning) begin
                    next_state = LOOP_TURNING;
                end else begin
                    next_state = BACKING;
                end
            end
            BACKING: begin
                if (backward_cnt == BACKWARD_TIME) begin
                    next_state = FORWARD;
                end else begin
                    next_state = BACKING;
                end
            end
            FORWARD: begin
                if (forward_cnt == FORWARD_TIME) begin
                    next_state = MAKING_DESICION;
                end else begin
                    next_state = FORWARD;
                end
            end
            default: next_state = WAITING;
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
