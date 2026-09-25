module tb;

reg clk=0,rst_n=0,write_enable=0,read_enable=0;reg [7:0] data_in=0;wire [7:0] data_out;wire buffer_full,buffer_empty,buffer_select;always #5 clk=~clk;integer i,b;
ping_pong_buffer dut(.*);
initial begin #12;rst_n=1;
for(b=0;b<2;b=b+1)begin
for(i=0;i<256;i=i+1)begin @(negedge clk);write_enable=1;data_in=i^8'hac;end
@(negedge clk);write_enable=0;if(!buffer_full)$fatal(1,"capacity");
for(i=0;i<256;i=i+1)begin read_enable=1;@(posedge clk);#1;if(data_out!==(i^8'hac))$fatal(1,"FIFO ordering %d",i);@(negedge clk);end
read_enable=0;if(!buffer_empty||buffer_select!==(b==0))$fatal(1,"bank switch");end
write_enable=0;read_enable=0;rst_n=0;#1;if(!buffer_empty||buffer_full||buffer_select)$fatal(1,"asynchronous reset");
#9;rst_n=1;repeat(2)@(posedge clk);#1;if(!buffer_empty)$fatal(1,"quiescent reset");$display("PASS");$finish;end

initial begin #100000;$fatal(1,"timeout");end
endmodule
