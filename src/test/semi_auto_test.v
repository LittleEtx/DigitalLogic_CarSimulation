`timescale 1ns / 1ps;
module semi_auto_test ();

reg enable, clk, is_turning, move_forward, move_left, move_right, move_backward;
reg [3:0] detector;
wire out_move_forward, trigger_turn_left, trigger_turn_right, trigger_turn_back;

semi_auto test(
    enable,
    clk, //500Hz
    is_turning,
    move_forward,
    move_left,
    move_right,
    move_backward,
    detector,
    out_move_forward,
    trigger_turn_left,
    trigger_turn_right,
    trigger_turn_back
);

initial begin
    clk = 1'b0;
    enable = 1'b0;
    is_turning = 1'b0;
    move_forward = 1'b0;
    move_left = 1'b0;
    move_right = 1'b0;
    move_backward = 1'b0;
    detector = 4'b0011;
    //test disable
    #10 move_forward = 1'b1;
    #10 move_forward = 1'b0;
    #10 enable = 1'b1;
    //test move forward
    #10 move_forward = 1'b1;
    #10 move_forward = 1'b0;
    #30 detector = 4'b1001;
    //test move left
    #10 begin 
    move_left = 1'b1;
    is_turning = 1'b1;
    end
    #10 move_left = 1'b0;
    #10 is_turning = 1'b0;
    #10 detector = 4'b0011;
    #30 detector = 4'b1000;
    //test move right
    #10 begin 
    move_right = 1'b1;
    is_turning = 1'b1;
    end
    #10 move_right = 1'b0;
    #10 is_turning = 1'b0;
    #10 detector = 4'b0011;
    #30 detector = 4'b1011;
    //test move backward
    #10 begin 
    move_backward = 1'b1;
    is_turning = 1'b1;
    end
    #10 move_backward = 1'b0;
    #30 is_turning = 1'b0;
    #10 detector = 4'b0011;
    #30 detector = 4'b1001;
    //test blocking
    #10 move_right = 1'b1;
    #10 move_right = 1'b0;
    #10 move_left = 1'b1;
    #5 is_turning = 1'b1;
    #10 move_left = 1'b0;
    #10 is_turning = 1'b0;
    #10 detector = 4'b0011;
    #30 detector = 4'b0001;
    //test disable
    #10 enable = 1'b0;
    #10 move_forward = 1'b1;
    #10 move_forward = 1'b0;
    #5 $finish;
end

always #1 clk = ~clk;
    
endmodule