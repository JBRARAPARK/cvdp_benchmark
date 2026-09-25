`timescale 1ns/1ps
module tb;
reg clk=0,rst_n=0,write_enable=0,read_enable=0;always #5 clk=~clk;reg [7:0] data_in=0;wire [7:0] data_out;wire buffer_full,buffer_empty,buffer_select;integer i;
ping_pong_buffer dut(.*);
initial begin #12;rst_n=1;
for(i=0;i<600;i=i+1)begin @(negedge clk);write_enable=1;read_enable=1;data_in=i;@(posedge clk);#1;if(data_out!==data_in||!buffer_empty||buffer_full)$fatal(1,"empty bypass %d",i);end
@(negedge clk);rst_n=0;#1;if(!buffer_empty||buffer_select)$fatal(1,"reset");$display("PASS: 600 empty simultaneous transfers and bank wrapping");$finish;end
initial begin #10000;$fatal(1,"timeout");end
endmodule
