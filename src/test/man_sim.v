`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/30 11:56:10
// Design Name: 
// Module Name: man_sim
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


module man_sim();
reg enable_sim,clk_sim,reverse_sim,brake_sim,clutch_sim,throttle_sim,left_sim,right_sim;
reg [1:0] state_cur_sim;
wire break_sim,move_forward_sim,move_backward_sim,turn_left_sim,turn_right_sim;
wire [1:0] state_next_sim;
man usrc1(state_cur_sim,enable_sim,clk_sim,reverse_sim,brake_sim,clutch_sim,
throttle_sim,left_sim,right_sim,break_sim,move_forward_sim,move_backward_sim,
turn_left_sim,turn_right_sim,state_next_sim);

initial
  begin
  clk_sim=1'b0;
  enable_sim=1'b1;
  {reverse_sim,brake_sim,clutch_sim,throttle_sim,left_sim,right_sim}=6'b000000;state_cur_sim=2'b01;
  #10 {reverse_sim,brake_sim,clutch_sim,throttle_sim}=4'b1011;//δ�𲽵���2
  #10 {reverse_sim,brake_sim,clutch_sim,throttle_sim,left_sim,right_sim}=6'b000000;state_cur_sim=2'b01;
  #10 state_cur_sim=state_next_sim; {reverse_sim,brake_sim,clutch_sim,throttle_sim}=4'b0011;//δ�𲽵���1
  #10 state_cur_sim=state_next_sim; {reverse_sim,brake_sim,clutch_sim,throttle_sim}=4'b0000;//��״̬�¹�����ֹͣ
  #10 state_cur_sim=state_next_sim; {reverse_sim,brake_sim,clutch_sim,throttle_sim}=4'b0001;//��״̬�¿������ƶ�
  #10 state_cur_sim=state_next_sim; {reverse_sim,brake_sim,clutch_sim,throttle_sim}=4'b0100;//��ɲ���ص�δ��
  #10 state_cur_sim=state_next_sim; {reverse_sim,brake_sim,clutch_sim,throttle_sim}=4'b0101;//δ����ɲ�������������޷�Ӧ
  #10 state_cur_sim=state_next_sim; {reverse_sim,brake_sim,clutch_sim,throttle_sim}=4'b0001;//δ��δɲ��ֱ�Ӳ�����Ϩ��
  #10 enable_sim=1'b1;{reverse_sim,brake_sim,clutch_sim,throttle_sim,left_sim,right_sim}=6'b000000;state_cur_sim=2'b01;
  #10 state_cur_sim=state_next_sim; {reverse_sim,brake_sim,clutch_sim,throttle_sim}=4'b0011;//δ�𲽵���1
  #10 state_cur_sim=state_next_sim; {reverse_sim,brake_sim,clutch_sim,throttle_sim}=4'b1011;//�ص���״̬����ȷ��ɲ����
  #10 state_cur_sim=state_next_sim; {reverse_sim,brake_sim,clutch_sim,throttle_sim}=4'b1111;//��ɲ���ص�δ��
  #10 state_cur_sim=state_next_sim; {reverse_sim,brake_sim,clutch_sim,throttle_sim}=4'b1001;//�����ɲ����Ϩ��
  #10 $finish();
  end
always #1 clk_sim=~clk_sim;
endmodule
