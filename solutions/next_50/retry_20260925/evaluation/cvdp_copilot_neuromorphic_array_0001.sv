module neuromorphic_array #(parameter NEURONS=8,INPUTS=8,OUTPUTS=8,CASCADE=0)(input [7:0] ui_in,uio_in,output [7:0] uo_out,input clk,rst_n);
wire [7:0] chain[0:NEURONS];assign chain[0]=uio_in;assign uo_out=chain[NEURONS];genvar i;generate for(i=0;i<NEURONS;i=i+1)begin:n single_neuron_dut u(clk,rst_n,ui_in[0],(CASCADE?chain[i]:uio_in),chain[i+1]);end endgenerate endmodule
module single_neuron_dut(input clk,rst_n,control,input [7:0] seq_in,output reg [7:0] seq_out);always @(posedge clk or negedge rst_n)if(!rst_n)seq_out<=0;else if(control)seq_out<=seq_in;endmodule
