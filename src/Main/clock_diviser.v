`timescale 1ns / 1ps
module clock_diviser (
    input clk, //100MHZ
    input reset,
    output reg out_clk //500HZ
);

parameter div = 200_000;
reg [31:0] cnt;
//counting
always @(posedge clk) begin 
    if (reset) begin
        cnt <= 0;
        out_clk <= 1'b0;
    end else begin
        if (cnt == (div >> 1) - 1) begin
            out_clk <= ~out_clk;
            cnt <= 0;
        end
        else begin
            cnt <= cnt + 1;
        end
    end
end

endmodule 