`timescale 1ns / 1ps
module auto_turning_test ();

reg clk, enable, ttl, ttr, ttb;
wire tl, tr, it;

auto_turning test(
    .clk(clk),
    .enable(enable),
    .trigger_turn_left(ttl),
    .trigger_turn_right(ttr),
    .trigger_turn_back(ttb),
    .turn_left(tl),
    .turn_right(tr),
    .is_turning(it)
);

initial begin
    clk = 1'b0;
    enable = 1'b0;
    {ttl, ttr, ttb} = 3'b000;
    #10 ttl = 1'b1;
    #10 ttl = 1'b0;
    #10 enable = 1'b1;
    #10 ttl = 1'b1;
    #10 ttl = 1'b0;
    #760 ttr = 1'b1;
    #10 ttr = 1'b0;
    #760 ttb = 1'b1;
    #10 ttb = 1'b0;
    #1550 enable = 1'b0;
    #5 $finish;
end

always #1 clk = ~clk;

    
endmodule