`timescale 1ns/1ps
module tb;
reg clk=0; always #5 clk=~clk;
reg rst=0,enable=0,fault=0,clear=0;reg [15:0] din=16'habcd;
wire cs,sclk,sdata,done;wire [4:0] left;wire [1:0] state;
spi_fsm dut(clk,rst,din,enable,fault,clear,cs,sclk,sdata,left,done,state);
integer n;reg [15:0] received=0;
initial begin
 #12;rst=1;@(negedge clk);enable=1;
 for(n=0;n<16;n=n+1)begin
  @(posedge sclk);#1;received={received[14:0],sdata};
  if(left!==15-n)$fatal(1,"remaining count mismatch");
 end
 if(received!==din)$fatal(1,"serial word mismatch");
 if(!done || state!=0)$fatal(1,"completion mismatch");
 @(negedge clk);enable=0;@(posedge clk);#1;
 if(done || !cs || sclk)$fatal(1,"idle mismatch");
 $display("PASS: all 16 bits, settled counter, completion, idle");$finish;
end
initial begin #2000;$fatal(1,"timeout");end
endmodule
