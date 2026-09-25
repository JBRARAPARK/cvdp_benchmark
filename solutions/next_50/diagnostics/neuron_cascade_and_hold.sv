module tb;

reg clk=0,rst_n=0;always #5 clk=~clk;reg [7:0] ui_in=0,uio_in=0;wire [7:0] uo_out;reg [7:0] expected[0:3];integer i,n;
neuromorphic_array #(.NEURONS(4)) dut(.*);
initial begin for(i=0;i<4;i=i+1)expected[i]=0;#12;rst_n=1;
for(n=0;n<40;n=n+1)begin @(negedge clk);ui_in=n%3!=0;uio_in=n*7;@(posedge clk);if(ui_in[0])begin for(i=3;i>0;i=i-1)expected[i]=expected[i-1];expected[0]=uio_in;end #1;if(uo_out!==expected[3])$fatal(1,"cascade/hold");end $display("PASS");$finish;end

initial begin #100000;$fatal(1,"timeout");end
endmodule
