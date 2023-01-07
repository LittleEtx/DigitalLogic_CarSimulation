`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/09 14:00:28
// Design Name: 
// Module Name: start
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


module start(
    input clk,
    input power,
    input [1:0] mode_selection,
    input break,
    output reg [1:0] mode
    );

parameter OFF = 2'b00, ON = 2'b01, PRESSING_ON = 2'b10, PRESSING_OFF = 2'b11;
reg [1:0] state;
reg [1:0] next_state;

parameter div = 500; // *0.002 = 1s
reg [31:0] cnt;

//state output
always@(*) begin
    case (state)
        OFF, PRESSING_ON: mode = 2'b00;
        ON, PRESSING_OFF: begin
            case (mode_selection)
                2'b00, 2'b10: mode = 2'b01; //man
                2'b01: mode = 2'b11; //semi_auto
                2'b11: mode = 2'b10; //auto
            endcase
        end
    endcase
end

//state transition
always @(*) begin
    case (state)
        OFF: begin
            if (power)
                next_state = PRESSING_ON;
            else
                next_state = OFF;
        end
        ON: begin
            if (power)
                next_state = PRESSING_OFF;
            else
                next_state = ON;
        end
        PRESSING_ON: begin
            if (cnt == div - 1)
                next_state = ON;
            else if (power)
                next_state = PRESSING_ON;
            else
                next_state = OFF;
        end
        PRESSING_OFF: begin
            if (cnt == div - 1)
                next_state = OFF;
            else if (power)
                next_state = PRESSING_OFF;
            else
                next_state = ON;
        end
    endcase
    
end

//state register
always @(posedge clk) begin
    if (break)
        state <= OFF;
    else
        state <= next_state;
end

//counting
always @(posedge clk) begin 
    case (state)
        PRESSING_ON, PRESSING_OFF: cnt <= cnt + 1;
        default: cnt <= 0;
    endcase
end



endmodule
