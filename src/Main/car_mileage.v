`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/09 14:26:48
// Design Name: 
// Module Name: car_mileage
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

module car_mileage(
    input clk,
    input [1:0] mode,
    input [1:0]state,
    output reg[7:0]seg_en,
    output reg [7:0]seg0,
    output reg [7:0]seg1
    );
parameter OFF = 2'b00,NOT_STARTING=2'b01,STARTING=2'b11,MOVING=2'b10;
parameter maxcnt=50;
reg divclk=0;
reg [15:0] mile;
reg [3:0] an1;
  wire [1:0] s;
  reg[3:0] digit;
  reg[19:0] clkdiv=20'b0;
  reg[3:0] an;
  reg [1:0] disp_bit=2'b11;
always@(mode)
  begin
  case(mode)
  2'b00: 
    begin
    an=4'b1111;
    seg0<=8'b0000_0001;
    seg1<=8'b0000_0001;
    an1=4'b1111;
    end
  2'b01:
    begin
    seg0<=8'b0110_0000;
    an1=4'b0001;
    end
  2'b10:
    begin
    seg0<=8'b1111_0010;
    an1=4'b0001;
    end
  2'b11:
    begin
    seg0<=8'b0110_0110;
    an1=4'b0001;
    end
  endcase
  seg_en={4'b0000,an1};
  end
always@(posedge clk)
  begin
  if(mode==2'b01) begin
    case(state)
      OFF: begin 
        mile<=16'h0; 
        seg_en<=8'hff;
        seg0<=8'b0000_0001;
        seg1<=8'b0000_0001;
        end
      MOVING:mile<=mile+1;
      default: mile<=mile;
    endcase
    end
  end
  assign s=clkdiv[19:18];
  always@(posedge clk)
    begin
    if(clkdiv==4'b1111) //ÆµÂÊµ÷Õû
      begin
      clkdiv<=0;
      divclk<=~divclk;
      end
    else clkdiv<=clkdiv+1;
    end
  always@(posedge divclk)
  begin
    if(disp_bit==2'b11) disp_bit=2'b0;
    else disp_bit=disp_bit+1;
    case(disp_bit)
      2'b00:an=4'b0001;
      2'b01:an=4'b0010;
      2'b10:an=4'b0100;
      2'b11:an=4'b1000;
      default:an=4'b0000;
    endcase
    seg_en={an,4'b0000};
  end
      always@(posedge divclk)
        case(s)
          0:digit=mile[3:0];
          1:digit=mile[7:4];
          2:digit=mile[11:9];
          3:digit=mile[15:12];
          default digit=mile[3:0];
        endcase
      always @(posedge divclk)
        case(digit)
        4'h0: seg1 = 8'b1111_1100; //0
        4'h1: seg1 = 8'b0110_0000; //1
        4'h2: seg1 = 8'b1101_1010; //2
        4'h3: seg1 = 8'b1111_0010; //3
        4'h4: seg1 = 8'b0110_0110; //4
        4'h5: seg1 = 8'b1011_0110; //5
        4'h6: seg1 = 8'b1011_1110; //6
        4'h7: seg1 = 8'b1110_0000; //7
        4'h8: seg1 = 8'b1111_1110; //8
        4'h9: seg1 = 8'b1110_0110; //9
        default: seg1 = 8'b0000_0001;
        endcase
endmodule

