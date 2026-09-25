`timescale 1ns/1ps
module tb;
 reg clk=0;always #5 clk=~clk;
 reg rst=0,enable=0,fault=0,clear=0;reg [15:0] din=0;
 wire cs,sclk,sdata,done;wire [4:0] left;wire [1:0] state;
 spi_fsm dut(clk,rst,din,enable,fault,clear,cs,sclk,sdata,left,done,state);
 integer w,b,k,mode;reg [15:0] word_value,received;integer words=0,aborts=0;
 task tick;begin @(posedge clk);#1;end endtask
 task idle_check;begin if(cs!==1||sclk!==0||sdata!==0||state!==0)$fatal(1,"unsafe idle");end endtask
 task reset_dut;begin @(negedge clk);rst=0;enable=0;fault=0;clear=0;#1;idle_check();@(negedge clk);rst=1;end endtask
 task send_word(input [15:0] value);
 begin
  @(negedge clk);din=value;enable=1;tick();
  if(cs!==0||state!==1||left!==16)$fatal(1,"start");
  received=0;
  for(b=15;b>=0;b=b-1)begin
   // Verify setup and word capture independently of the sampling-edge check.
   if(sclk!==0||sdata!==value[b]||cs!==0)$fatal(1,"setup bit %0d",b);
   @(negedge clk);din=~value;
   @(posedge sclk);#1;
   if(cs!==0||left!==b||done!==0)$fatal(1,"sampling/count bit %0d",b);
   received={received[14:0],sdata};
   tick();
   if(b>0 && (done || cs))$fatal(1,"early finish");
  end
  if(received!==value||!done||left!==0)$fatal(1,"word/completion");
  idle_check();
  @(negedge clk);enable=0;tick();if(done)$fatal(1,"done not one cycle");
  words=words+1;
 end endtask
 initial begin
  reset_dut();
  send_word(0);send_word(16'hffff);send_word(16'haaaa);send_word(16'h5555);
  for(w=0;w<16;w=w+1)send_word(16'b1<<w);
  for(w=0;w<256;w=w+1)send_word($random);
  for(mode=0;mode<4;mode=mode+1)for(k=0;k<31;k=k+1)begin
   reset_dut();@(negedge clk);enable=1;din=16'hf00d;tick();
   repeat(k)tick();
   @(negedge clk);
   case(mode)0:enable=0;1:clear=1;2:fault=1;3:rst=0;endcase
   tick();
   if(mode==2)begin
    if(state!==3||!cs||sclk||sdata||!done)$fatal(1,"fault entry");
    @(negedge clk);fault=0;tick();if(state!==3||done)$fatal(1,"fault retention");
    @(negedge clk);clear=1;tick();idle_check();
   end else begin idle_check();if(done)$fatal(1,"abort done");end
   aborts=aborts+1;
  end
  $display("PASS SPI: %0d complete words, %0d abort/reset/fault phases",words,aborts);$finish;
 end
 initial begin #2000000;$fatal(1,"timeout");end
endmodule
