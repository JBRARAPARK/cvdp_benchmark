module ping_pong_buffer(input clk,rst_n,write_enable,read_enable,input [7:0] data_in,output reg [7:0] data_out,output buffer_full,buffer_empty,output buffer_select);
localparam DEPTH=256,ADDR_WIDTH=8;reg [8:0] wp,rp;reg [9:0] count;wire [7:0] data_out0,data_out1;wire push=write_enable&&!buffer_full;wire pop=read_enable&&!buffer_empty;
wire [7:0] write_ptr=wp[7:0],read_ptr=rp[7:0];assign buffer_select=rp[8];assign buffer_full=count==DEPTH;assign buffer_empty=count==0;
dual_port_memory memory0(clk,push&&!wp[8],write_ptr,data_in,read_ptr,data_out0);
dual_port_memory memory1(clk,push&&wp[8],write_ptr,data_in,read_ptr,data_out1);
always @(posedge clk or negedge rst_n)if(!rst_n)begin wp<=0;rp<=0;count<=0;data_out<=0;end else begin
if(push)wp<=wp+1'b1;if(pop)begin data_out<=rp[8]?data_out1:data_out0;rp<=rp+1'b1;end
case({push,pop})2'b10:count<=count+1'b1;2'b01:count<=count-1'b1;endcase end endmodule
