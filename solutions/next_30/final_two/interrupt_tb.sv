`timescale 1ns/1ps
module tb;
 parameter THRESHOLD=5;
 reg clk=0;always #5 clk=~clk;
 reg rst=0,clear=0,ack=0,trig=0,override_en=0;
 reg [9:0] req=0,mask=0;reg [3:0] override_priority=0,override_id=0;
 wire [3:0] id;wire valid,starved;wire [9:0] status,missed;
 interrupt_controller #(.STARVATION_THRESHOLD(THRESHOLD),.SERVICE_TIMEOUT(64)) dut(
 clk,rst,clear,req,ack,trig,mask,override_priority,override_id,override_en,id,valid,status,missed,starved);
 integer n,m,guard,checks=0;
 task tick;begin @(posedge clk);#1;end endtask
 task reset_dut;begin
  @(negedge clk);rst=0;clear=0;ack=0;trig=0;req=0;mask=0;override_en=0;#1;
  if(valid||status||missed||starved)$fatal(1,"reset");
  @(negedge clk);rst=1;tick();
 end endtask
 task request(input [9:0] bits);
 begin @(negedge clk);req=bits;trig=1;tick();@(negedge clk);req=0;trig=0;end endtask
 task expect_irq(input integer expected);
 begin
  guard=0;while(!valid && guard<8)begin tick();guard=guard+1;end
  if(!valid||id!==expected||status!==(10'b1<<expected))$fatal(1,"IRQ got %0d valid %b expected %0d",id,valid,expected);
  checks=checks+1;
 end endtask
 task acknowledge;
 begin @(negedge clk);ack=1;tick();if(valid||status)$fatal(1,"ack clear");@(negedge clk);ack=0;end endtask
 initial begin
  // Every source, both mask polarities; no source may leak through the mask.
  for(n=0;n<10;n=n+1)begin
   reset_dut();mask=10'b1<<n;request(10'b1<<n);repeat(5)tick();
   if(valid||missed!==(10'b1<<n))$fatal(1,"mask %0d",n);
   mask=0;request(10'b1<<n);expect_irq(n);acknowledge();repeat(5)tick();if(valid)$fatal(1,"repeated IRQ");
  end
  // Static priorities and deterministic tie policy.
  reset_dut();request(10'b1000000001);expect_irq(THRESHOLD==1?9:0);acknowledge();expect_irq(THRESHOLD==1?0:9);acknowledge();
  reset_dut();override_en=1;override_id=9;override_priority=10;
  request(10'b1000000001);expect_irq(9);acknowledge();expect_irq(0);acknowledge();
  // An active service must not change ID when priorities change.
  reset_dut();request(10'b0000001000);expect_irq(3);
  request(10'b1000000000);
  @(negedge clk);override_en=1;override_id=9;override_priority=15;
  repeat(3)begin tick();if(!valid||id!==3)$fatal(1,"active IRQ changed");end
  acknowledge();expect_irq(9);acknowledge();
  // Waiting is counted per arbitration, independently of service clock duration.
  reset_dut();request(10'b1000000001);
  for(m=1;m<THRESHOLD;m=m+1)begin
   expect_irq(0);
   @(negedge clk);ack=1;trig=1;req=1;tick();
   @(negedge clk);ack=0;trig=0;req=0;
  end
  expect_irq(9);
  if(!starved)$fatal(1,"arbitration aging not detected, threshold %0d",THRESHOLD);
  acknowledge();
  // A newly arrived same-source request concurrent with ACK must survive.
  reset_dut();request(4);expect_irq(2);
  @(negedge clk);ack=1;trig=1;req=4;tick();
  @(negedge clk);ack=0;trig=0;req=0;expect_irq(2);acknowledge();
  // Another source concurrent with ACK is also retained.
  reset_dut();request(2);expect_irq(1);
  @(negedge clk);ack=1;trig=1;req=128;tick();
  @(negedge clk);ack=0;trig=0;req=0;expect_irq(7);acknowledge();
  // Explicit clear wins over a simultaneous request and clears missed flags.
  reset_dut();mask=1;request(3);expect_irq(1);
  @(negedge clk);clear=1;req=1023;trig=1;tick();
  if(valid||status||missed||starved)$fatal(1,"software reset");
  @(negedge clk);clear=0;trig=0;req=0;repeat(5)tick();if(valid)$fatal(1,"clear lost");
  // Spurious ACK is harmless; timeout makes progress and records the lost service.
  reset_dut();@(negedge clk);ack=1;tick();@(negedge clk);ack=0;
  request(32);expect_irq(5);repeat(65)tick();
  if(valid||missed!==32)$fatal(1,"timeout handling");
  request(8);expect_irq(3);acknowledge();
  $display("PASS IRQ threshold=%0d: %0d service checks; mask, priority, starvation, ACK collisions, reset, timeout",THRESHOLD,checks);$finish;
 end
 initial begin #1000000;$fatal(1,"timeout");end
endmodule
