`timescale 1ns / 1ps
module BCD_to_SEG(
    input [3:0] BCD,
    output reg [7:0] SEG
);
always @* begin
    case (BCD)
        4'b0000: SEG = 8'b1111_1100;
        4'b0001: SEG = 8'b0110_0000;
        4'b0010: SEG = 8'b1101_1010;
        4'b0011: SEG = 8'b1111_0010;
        4'b0100: SEG = 8'b0110_0110;
        4'b0101: SEG = 8'b1011_0110;
        4'b0110: SEG = 8'b1011_1110;
        4'b0111: SEG = 8'b1110_0000;
        4'b1000: SEG = 8'b1111_1110;
        4'b1001: SEG = 8'b1111_0110;
        4'b1010: SEG = 8'b1110_1110;
        4'b1011: SEG = 8'b0011_1110;
        4'b1100: SEG = 8'b1001_1100;
        4'b1101: SEG = 8'b0111_1010;
        4'b1110: SEG = 8'b1001_1110;
        4'b1111: SEG = 8'b1000_1110;
        default: SEG = 8'b0000_0000;
    endcase
end
endmodule