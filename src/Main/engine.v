`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/09 13:58:31
// Design Name: 
// Module Name: Engine
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


module engine(
    input clk, //P17Main/Engine.v
    input rx, //N5
    input power, //S6
    input [1:0] mode_selection, //[N4,R1]
    input man_reverse, //P3 
    input man_brake, //P4
    input man_clutch, //P5
    input up, //J4
    input right, //R11
    input left, //V1
    input down, //R17
    output tx, //T4
    output left_light, //F6
    output right_light, //K2
    output [3:0] detector, //[K6, L1, M1, K3]
    output [3:0] move_signal, //[K1, H6, H5, J5]
    output [7:0] seg_en, //[G2, C2, C1, H1, G1, F1, E1, G6]
    output [7:0] seg_out0, //[B4, A4, A3, B1. A1, B3, B2, D5]
    output [7:0] seg_out1, //[D4, E3, D3, F4, F3, E2, D2, H2]
    
    //debug signals
    output [2:0] out_semi_state,
    input middle_click,
    input middle_click_reverse
    );
    wire turn_left, turn_right, move_forward, move_backward, place_barrier, destroy_barrier;
    assign move_signal = {move_forward, move_backward, turn_left, turn_right};
    SimulatedDevice device_inst(
        .sys_clk(clk), 
        .rx(rx), 
        .tx(tx), 
        .turn_left_signal(turn_left), 
        .turn_right_signal(turn_right), 
        .move_forward_signal(move_forward), 
        .move_backward_signal(move_backward), 
        .place_barrier_signal(place_barrier), 
        .destroy_barrier_signal(destroy_barrier),
        .front_detector(detector[3]), 
        .back_detector(detector[1]), //actual left
        .left_detector(detector[0]), //actual right
        .right_detector(detector[2]) //actual back
        );
      
    wire [1:0] mode;
    //mode selection
    wire mode_semi, mode_auto, mode_manual, mode_off;
    minterm_generator mode_select(.in(mode), .out({mode_semi, mode_auto, mode_manual, mode_off})); 
    clock_diviser clk_div(.clk(clk), .reset(mode_off), .out_clk(out_clk));
    
    //debug
    wire man_place_barrier, man_destroy_barrier;
    assign man_place_barrier = mode_manual & middle_click & ~middle_click_reverse;
    assign man_destroy_barrier = mode_manual & middle_click & middle_click_reverse;
    
    wire break;
    start start_inst(
        .clk(out_clk), 
        .power(power), 
        .mode_selection(mode_selection), 
        .break(break), 
        .mode(mode)
        );

    wire man_move_forward, man_turn_left, man_turn_right, man_move_backward; 
    man man_inst(
        .enable(mode_manual), 
        .clk(out_clk), 
        .reverse(man_reverse), 
        .brake(man_brake), 
        .clutch(man_clutch), 
        .throttle(up), 
        .left(left), 
        .right(right),
        .break(break), 
        .move_forward(man_move_forward), 
        .move_backward(man_move_backward), 
        .turn_left(man_turn_left), 
        .turn_right(man_turn_right)
        );

    //auto turning
    wire trigger_turn_left, trigger_turn_right, trigger_turn_back;
    wire is_turning, auto_turn_left, auto_turn_right, auto_enable;
    or u1(auto_enable, mode_semi, mode_auto);
    auto_turning auto_turning_inst(
        .clk(out_clk), 
        .enable(auto_enable), 
        .trigger_turn_left(trigger_turn_left), 
        .trigger_turn_right(trigger_turn_right), 
        .trigger_turn_back(trigger_turn_back), 
        .turn_left(auto_turn_left), 
        .turn_right(auto_turn_right), 
        .is_turning(is_turning)
        );

    //semi auto
    wire semi_move_forward, semi_trigger_turn_left, semi_trigger_turn_right, semi_trigger_turn_back;
    semi_auto semi_auto_inst(
        .enable(mode_semi), 
        .clk(out_clk), 
        .is_turning(is_turning), 
        .move_forward(up), 
        .move_left(left), 
        .move_right(right), 
        .move_backward(down), 
        .detector(detector),
        .out_move_forward(semi_move_forward), 
        .trigger_turn_left(semi_trigger_turn_left), 
        .trigger_turn_right(semi_trigger_turn_right), 
        .trigger_turn_back(semi_trigger_turn_back), 
        .out_state(out_semi_state)
        );
    
    //auto
    wire auto_move_forward, auto_trigger_turn_left, auto_trigger_turn_right, auto_trigger_turn_back, auto_move_backward;
    wire auto_place_barrier, auto_destroy_barrier;
    auto auto_inst(
        .enable(mode_auto), 
        .clk(out_clk), 
        .moving(up),
        .is_turning(is_turning), 
        .detector(detector),
        .move_forward(auto_move_forward),
        .move_backward(auto_move_backward), 
        .trigger_turn_left(auto_trigger_turn_left), 
        .trigger_turn_right(auto_trigger_turn_right), 
        .trigger_turn_back(auto_trigger_turn_back), 
        .place_barrier_signal(auto_place_barrier), 
        .destroy_barrier_signal(auto_destroy_barrier)
        );

    mux_4_to_1 auto_turn_left_sel(.in({semi_trigger_turn_left, auto_trigger_turn_left, 2'b00}),
        .sel(mode), .out(trigger_turn_left));
    mux_4_to_1 auto_turn_right_sel(.in({semi_trigger_turn_right, auto_trigger_turn_right, 2'b00}),
        .sel(mode), .out(trigger_turn_right));
    mux_4_to_1 auto_turn_back_sel(.in({semi_trigger_turn_back, auto_trigger_turn_back, 2'b00}),
        .sel(mode), .out(trigger_turn_back));

    mux_4_to_1 move_forward_sel(.in({semi_move_forward, auto_move_forward, man_move_forward, 1'b0}), 
        .sel(mode), .out(move_forward));
    mux_4_to_1 turn_left_sel(.in({auto_turn_left, auto_turn_left, man_turn_left, 1'b0}), 
        .sel(mode), .out(turn_left));
    mux_4_to_1 turn_right_sel(.in({auto_turn_right, auto_turn_right, man_turn_right, 1'b0}), 
        .sel(mode), .out(turn_right));
    mux_4_to_1 move_backward_sel(.in({1'b0, auto_move_backward, man_move_backward, 1'b0}), 
        .sel(mode), .out(move_backward));

    mux_4_to_1 place_barrier_sel(.in({1'b0, auto_place_barrier, man_place_barrier, 1'b0}), 
        .sel(mode), .out(place_barrier));
    mux_4_to_1 destroy_barrier_sel(.in({1'b0, auto_destroy_barrier, man_destroy_barrier, 1'b0}), 
        .sel(mode), .out(destroy_barrier));

    //displays
    wire [15:0] mile;
    car_mileage mileage_inst(out_clk, move_forward, move_backward, mile);
    car_seg seg_inst(out_clk, mode, mile, seg_en, seg_out0, seg_out1);
    car_LED LED_inst(out_clk, mode, turn_left, turn_right, left_light, right_light);

endmodule 
