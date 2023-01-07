`timescale 1ns / 1ps
module car_seg (
    input clk, //500Hz
    input reset,
    input [1:0] mode,
    input [15:0] mile,
    output reg [7:0] seg_en,
    output reg [7:0] seg_out0,
    output reg [7:0] seg_out1
);

parameter 
SEG_null = 8'b0000_0000,
SEG_O = 8'b1111_1100,
SEG_F = 8'b1000_1110,
SEG_H = 8'b0110_1110,
SEG_A = 8'b1110_1110,
SEG_U = 8'b0111_1100,
SEG_S = 8'b1011_0110,
SEG_E = 8'b1001_1110;

reg [31:0] seg0;
wire [31:0] seg1;
reg [3:0] enable;

always @(*) begin
    if (mode == 2'b00) begin
        seg_en = {enable, 4'b0000};
    end else begin
        seg_en = {enable, enable};
    end
end

always@(*) begin
    case(mode)
    2'b00: seg0 = {SEG_null, SEG_O, SEG_F, SEG_F};
    2'b01: seg0 = {SEG_null, SEG_null, SEG_H, SEG_A};
    2'b10: seg0 = {SEG_null, SEG_null, SEG_A, SEG_U};
    2'b11: seg0 = {SEG_null, SEG_null, SEG_S, SEG_E};
    endcase
end

BCD_to_SEG s3(
    .BCD(mile[15:12]),
    .SEG(seg1[31:24])
);
BCD_to_SEG s2(
    .BCD(mile[11:8]),
    .SEG(seg1[23:16])
);
BCD_to_SEG s1(
    .BCD(mile[7:4]),
    .SEG(seg1[15:8])
);
BCD_to_SEG s0(
    .BCD(mile[3:0]),
    .SEG(seg1[7:0])
);

reg[3:0] number_mask;
always@(*) begin
    if (mile >> 12) number_mask = 4'b1111;
    else if (mile >> 8) number_mask = 4'b0111;
    else number_mask = 4'b0011;
end

always@(*) begin
    case (enable)
        4'b1000: begin
            seg_out0 = seg0[31:24];
            if (number_mask[3]) seg_out1 = seg1[31:24];
            else seg_out1 = SEG_null;
        end
        4'b0100: begin
            seg_out0 = seg0[23:16];
            if (number_mask[2]) seg_out1 = seg1[23:16];
            else seg_out1 = SEG_null;
        end
        4'b0010: begin
            seg_out0 = seg0[15:8];
            if (number_mask[1]) seg_out1 = {seg1[15:9], 1'b1};
            else seg_out1 = SEG_null;
        end
        4'b0001: begin
            seg_out0 = seg0[7:0];
            if (number_mask[0]) seg_out1 = seg1[7:0];
            else seg_out1 = SEG_null;
        end
        default: begin
            seg_out0 = SEG_null;
            seg_out1 = SEG_null;
        end
    endcase
end

always@(posedge clk) begin
    if (reset) begin
        enable <= 4'b0000;
    end
    else begin
        if (enable == 4'b0000) enable <= 4'b1000;
        else enable <= enable >> 1;
    end
end


endmodule