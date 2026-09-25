`timescale 1ns/1ps
module tb_immediate_error;
reg clk=0;
always #5 clk=~clk;
reg rst=0,item_button=0,cancel=0;
reg [2:0] item_selected=0;
reg [3:0] coin_input=0;
wire dispense_item,return_change,error,return_money;
wire [4:0] item_price,change_amount;
wire [2:0] dispense_item_id;
vending_machine dut(.*);
integer checks=0;
task check(input bit ok,input string msg);
 begin checks=checks+1;if(!ok)$fatal(1,"%s t=%0t",msg,$time);end
endtask
initial begin
 #1;rst=1;#1;check(!error,"reset masks error");
 @(negedge clk);rst=0;item_selected=6;
 #1;check(!error,"invalid unused ID in IDLE is ignored");
 @(negedge clk);item_button=1;item_selected=2;
 @(posedge clk);#1;check(!error,"selection begins with valid ID");
 // No rising edge occurs between these transitions (next edge is t=35).
 item_selected=6;#1;check(error,"invalid ID asserts before next rising edge");
 check(!return_money && !dispense_item,"no asynchronous state/action transition");
 item_selected=2;#1;check(!error,"unsampled transient clears immediately");
 @(negedge clk);item_button=0;item_selected=7;
 #1;check(error,"new invalid ID asserts without clock edge");
 @(posedge clk);#1;check(error,"sampled error retained as registered pulse");
 item_selected=2;#1;check(error,"registered error survives ID recovery");
 @(posedge clk);#1;check(!error && !return_money,"error clears after refund state with zero balance");
 @(negedge clk);item_button=1;item_selected=2;
 @(posedge clk);#1;item_selected=0;#1;check(error,"ID zero invalid during selection");
 rst=1;#1;check(!error,"asynchronous reset clears immediate and stored indication");
 $display("IMMEDIATE_ERROR_PASS assertions=%0d",checks);$finish;
end
initial begin #1000;$fatal(1,"timeout");end
endmodule
