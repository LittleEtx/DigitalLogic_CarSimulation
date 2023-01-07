`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/09 14:24:01
// Design Name: 
// Module Name: car_LED
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


module car_LED(
    input clk,
    input stay,
    input twinkle_left,
    input twinkle_right,
    output reg left_light,
    output reg right_light
    );

parameter div = 150; // *0.002 = 0.3s
reg clk_div;
reg [31:0] cnt;
//counting
always @(posedge clk) begin 
    if (cnt == (div >> 1) - 1) begin
        clk_div <= ~clk_div;
        cnt <= 0;
    end
    else begin
        cnt <= cnt + 1;
    end
end


always@(posedge clk_div) begin
  case ({stay, twinkle_left, twinkle_right})
    3'b100, 3'b111: {left_light, right_light} <= 2'b11;
    3'b110, 3'b010: {left_light, right_light} <= {~left_light, 1'b0};
    3'b101, 3'b001: {left_light, right_light} <= {1'b0, ~right_light};
    default: {left_light, right_light} <= 2'b00;
  endcase
end

endmodule
