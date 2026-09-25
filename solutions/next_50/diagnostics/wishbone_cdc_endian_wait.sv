module tb;

reg clk_i=0,hclk=0;always #5 clk_i=~clk_i;always #7 hclk=~hclk;
reg rst_i=0,hreset_n=0,cyc_i=0,stb_i=0,we_i=0,hready=0;reg [3:0] sel_i=15;reg [31:0] addr_i=0,data_i=0,hrdata=32'h78563412;reg [1:0] hresp=0;
wire [31:0] data_o,haddr,hwdata;wire ack_o,hwrite;wire [1:0] htrans;wire [2:0] hsize,hburst;
wishbone_to_ahb_bridge dut(.*);
initial begin #21;rst_i=1;hreset_n=1;@(negedge clk_i);cyc_i=1;stb_i=1;we_i=1;addr_i=32'h1000;data_i=32'h12345678;
wait(htrans==2);#1;if(hwdata!=32'h78563412||haddr!=32'h1000||!hwrite)$fatal(1,"write phase");repeat(3)begin @(posedge hclk);#1;if(ack_o||htrans!=2)$fatal(1,"wait state");end @(negedge hclk);hready=1;wait(ack_o);#1;if(data_o!=32'h12345678)$fatal(1,"read endian");@(negedge clk_i);cyc_i=0;stb_i=0;$display("PASS");$finish;end

initial begin #100000;$fatal(1,"timeout");end
endmodule
