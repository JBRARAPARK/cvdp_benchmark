module tb;

reg clk=0,rst=1,system_clk=0;always #5 clk=~clk;wire jitter_detected;
clock_jitter_detection_module dut(.*);
task tick(input v,input e);begin @(negedge clk);system_clk=v;@(posedge clk);#1;if(jitter_detected!==e)$fatal(1,"jitter expected %d got %d",e,jitter_detected);end endtask
integer i;initial begin #12;rst=0;tick(1,0);for(i=0;i<4;i=i+1)tick(0,0);tick(1,0);for(i=0;i<5;i=i+1)tick(0,0);tick(1,0);for(i=0;i<7;i=i+1)tick(0,0);tick(1,1);tick(0,0);$display("PASS");$finish;end

initial begin #100000;$fatal(1,"timeout");end
endmodule
