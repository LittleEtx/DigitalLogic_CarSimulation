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
    output [7:0] seg_out1 //[D4, E3, D3, F4, F3, E2, D2, H2]
    );
    wire turn_left, turn_right, move_forward, move_backward, place_barrier, destroy_barrier;
    assign move_signal = {move_forward, move_backward, turn_left, turn_right};
    SimulatedDevice device_inst(clk, rx, tx, turn_left, turn_right, move_forward, move_backward, place_barrier, destroy_barrier, 
            detector[0], detector[1], detector[2], detector[3]);

    wire [1:0] mode;
    //mode selection
    wire mode_semi, mode_auto, mode_manual, mode_off;
    minterm_generator mode_select(mode, {mode_semi, mode_auto, mode_manual, mode_off}); 
    clock_diviser clk_div(clk, mode_off, out_clk);
    wire break;
    start start_inst(out_clk, power, mode_selection, break, mode);

    wire man_move_forward, man_turn_left, man_turn_right; 
    man man_inst(mode_manual, out_clk, man_reverse, man_brake, man_clutch, up, left, right,
            break, man_move_forward, move_backward, man_turn_left, man_turn_right);

    //auto turning
    wire trigger_turn_left, trigger_turn_right, trigger_turn_back;
    wire is_turning, auto_turn_left, auto_turn_right, auto_enable;
    or u1(auto_enable, mode_semi, mode_auto);
    auto_turning auto_turning_inst(out_clk, auto_enable, trigger_turn_left, trigger_turn_right, trigger_turn_back, 
            auto_turn_left, auto_turn_right, is_turning);

    //semi auto
    wire semi_move_forward, semi_trigger_turn_left, semi_trigger_turn_right, semi_trigger_turn_back;
    semi_auto semi_auto_inst(mode_semi, out_clk, is_turning, up, left, right, down, detector,
            semi_move_forward, semi_trigger_turn_left, semi_trigger_turn_right, semi_trigger_turn_back);
    
    //auto
    wire auto_move_forward, auto_trigger_turn_left, auto_trigger_turn_right, auto_trigger_turn_back;
    auto auto_inst(mode_auto, out_clk, up, is_turning, detector,
            auto_move_forward, auto_trigger_turn_left, auto_trigger_turn_right, auto_trigger_turn_back, place_barrier, destroy_barrier);

    mux_4_to_1 auto_turn_left_sel({semi_trigger_turn_left, auto_trigger_turn_left, 2'b00}, mode, trigger_turn_left);
    mux_4_to_1 auto_turn_right_sel({semi_trigger_turn_right, auto_trigger_turn_right, 2'b00}, mode, trigger_turn_right);
    mux_4_to_1 auto_turn_back_sel({semi_trigger_turn_back, auto_trigger_turn_back, 2'b00}, mode, trigger_turn_back);

    mux_4_to_1 move_forward_sel({semi_move_forward, auto_move_forward, man_move_forward, 1'b0}, mode, move_forward);
    mux_2_to_1 turn_left_sel({auto_turn_left, man_turn_left}, auto_enable, turn_left);
    mux_2_to_1 turn_right_sel({auto_turn_right, man_turn_right}, auto_enable, turn_right);

    //displays
    wire [15:0] mile;
    car_mileage mileage_inst(out_clk, move_forward, move_backward, mile);
    car_seg seg_inst(out_clk, mode, mile, seg_en, seg_out0, seg_out1);
    car_LED LED_inst(out_clk, mode, turn_left, turn_right, left_light, right_light);

endmodule 
