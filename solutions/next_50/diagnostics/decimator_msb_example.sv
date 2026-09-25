module tb;

reg clk=0,reset=1,valid_in=0;always #5 clk=~clk;reg [127:0] data_in;wire valid_out;wire [31:0] data_out;wire [15:0] peak_value;
advanced_decimator_with_adaptive_peak_detection dut(.*);
initial begin #12;reset=0;data_in={16'd10,16'd20,16'd30,16'd40,16'd50,16'd60,16'd70,16'd80};valid_in=1;@(posedge clk);#1;
if(data_out!={16'd10,16'd50}||peak_value!=50||!valid_out)$fatal(1,"MSB example");
@(negedge clk);data_in={16'hfffa,16'd0,16'd0,16'd0,16'hfffe,16'd0,16'd0,16'd0};@(posedge clk);#1;if(peak_value!=16'hfffe)$fatal(1,"signed peak");$display("PASS");$finish;end

initial begin #100000;$fatal(1,"timeout");end
endmodule
