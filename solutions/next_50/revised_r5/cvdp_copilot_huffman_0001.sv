module huffman_encoder(input clk,reset,data_valid,input [3:0] data_in,input [1:0] data_priority,input update_enable,input [3:0] config_symbol,input [6:0] config_code,input [2:0] config_length,output reg [6:0] huffman_code_out,output reg code_valid,error_flag);
reg [6:0] codes[0:15];reg [2:0] lengths[0:15];reg [3:0] q[0:2][0:15];integer rd[0:2],wr[0:2],count[0:2];integer selected,level,i;
always @*begin level=data_priority>2?2:data_priority;selected=-1;for(integer j=0;j<3;j=j+1)if(count[j]>0)selected=j;end
always @(posedge clk or posedge reset)if(reset)begin huffman_code_out<=0;code_valid<=0;error_flag<=0;for(i=0;i<16;i=i+1)begin codes[i]<=i;lengths[i]<=4;end for(i=0;i<3;i=i+1)begin rd[i]<=0;wr[i]<=0;count[i]<=0;end end
else begin code_valid<=0;error_flag<=0;
if(update_enable)begin if((config_code>>config_length)!=0)error_flag<=1;else begin codes[config_symbol]<=config_code;lengths[config_symbol]<=config_length;end end
else if(selected>=0)begin huffman_code_out<=codes[q[selected][rd[selected]]];code_valid<=lengths[q[selected][rd[selected]]]!=0;if(lengths[q[selected][rd[selected]]]==0)error_flag<=1;rd[selected]<=(rd[selected]+1)%16;end
for(i=0;i<3;i=i+1)begin
if(data_valid&&level==i&&count[i]<16)begin q[i][wr[i]]<=data_in;wr[i]<=(wr[i]+1)%16;end
case({(data_valid&&level==i&&count[i]<16),(!update_enable&&selected==i)})2'b10:count[i]<=count[i]+1;2'b01:count[i]<=count[i]-1;endcase
end
if(data_valid&&count[level]==16)error_flag<=1;
end endmodule
module single_port_ram #(parameter DATA_WIDTH=8,ADDR_WIDTH=4)(input clk,we,input [ADDR_WIDTH-1:0] addr,input [DATA_WIDTH-1:0] din,output reg [DATA_WIDTH-1:0] dout);
reg [DATA_WIDTH-1:0] mem[0:(1<<ADDR_WIDTH)-1];always @(posedge clk)begin if(we)mem[addr]<=din;else dout<=mem[addr];end endmodule
