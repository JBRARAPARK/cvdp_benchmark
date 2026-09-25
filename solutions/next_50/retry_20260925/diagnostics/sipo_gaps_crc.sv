`timescale 1ns/1ps
module tb;
reg clk=0,reset_n=0,serial_in=0,shift_en=0;always #5 clk=~clk;
wire done,error_detected,error_corrected,crc_error;wire [15:0] data_out;wire [20:0] encoded;wire [7:0] crc_out;reg [20:0] received=0;reg [7:0] received_crc=0;
sipo_top #(.DATA_WIDTH(16),.CRC_WIDTH(8),.CODE_WIDTH(21),.POLY(8'h07)) dut(.*);
reg [15:0] word_data;reg [7:0] expected;integer n,i,j;
initial begin #12;reset_n=1;
for(n=0;n<5;n=n+1)begin
 word_data=16'h5a31^(n*16'h3127);
 for(i=15;i>=0;i=i-1)begin
  @(negedge clk);shift_en=1;serial_in=word_data[i];@(posedge clk);#1;
  if(done!==(i==0))$fatal(1,"done must count accepted bits");
  if(i%3==0&&i!=0)begin @(negedge clk);shift_en=0;repeat(2)begin @(posedge clk);#1;if(done)$fatal(1,"done during stall");end end
 end
 if(dut.uut_sipo.parallel_out!==word_data)$fatal(1,"word mismatch");
 @(negedge clk);shift_en=0;expected=0;
 for(j=15;j>=0;j=j-1)begin if(expected[7]^word_data[j])expected=(expected<<1)^8'h07;else expected=expected<<1;end
 @(posedge clk);#1;if(done||crc_out!==expected)$fatal(1,"CRC after final bit");
end
$display("PASS: five words, accepted-bit done, stalls, final-word CRC");$finish;end
initial begin #10000;$fatal(1,"timeout");end
endmodule
