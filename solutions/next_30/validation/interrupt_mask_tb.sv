`timescale 1ns/1ps
module tb;
reg clk=0;always #5 clk=~clk;
reg rst=0,clear=0,ack=0,trig=0;reg [9:0] req=0,mask=0;
wire [3:0] id;wire valid,starved;wire [9:0] status,missed;
interrupt_controller dut(clk,rst,clear,req,ack,trig,mask,4'b0,4'b0,1'b0,id,valid,status,missed,starved);
initial begin
 #12;rst=1;@(negedge clk);mask=10'b10;req=10'b11;trig=1;
 @(negedge clk);trig=0;req=0;
 wait(valid);#1;
 if(id!==0 || status!==1 || missed!==2)$fatal(1,"mask/service mismatch");
 @(negedge clk);ack=1;@(negedge clk);ack=0;
 repeat(3)@(negedge clk);
 if(valid)$fatal(1,"ack did not clear");
 $display("PASS: explicit mask, pending IRQ selection, missed flag, acknowledge");$finish;
end
initial begin #1000;$fatal(1,"timeout");end
endmodule
