module tb;

reg clk=0,rst=0;always #5 clk=~clk;reg [15:0] data_in=0;wire [7:0] crc_out;reg [7:0] refcrc;integer i,n;
crc_generator #(.DATA_WIDTH(16),.CRC_WIDTH(8),.POLY(8'h07)) dut(.*);
initial begin #12;rst=1;for(n=0;n<100;n=n+1)begin @(negedge clk);data_in=$random;refcrc=0;for(i=15;i>=0;i=i-1)begin if(refcrc[7]^data_in[i])refcrc=(refcrc<<1)^8'h07;else refcrc=refcrc<<1;end @(posedge clk);#1;if(crc_out!==refcrc)$fatal(1,"CRC recurrence");end $display("PASS");$finish;end

initial begin #100000;$fatal(1,"timeout");end
endmodule
