module wishbone_to_ahb_bridge(input clk_i,rst_i,cyc_i,stb_i,input [3:0] sel_i,input we_i,input [31:0] addr_i,data_i,input hclk,hreset_n,input [31:0] hrdata,input [1:0] hresp,input hready,output reg [31:0] data_o,output reg ack_o,output reg [1:0] htrans,output reg [2:0] hsize,output [2:0] hburst,output reg hwrite,output reg [31:0] haddr,hwdata);
reg request,completed,cs1,cs2,rs1,rs2,busy;reg [31:0] address,data,read_data;reg [3:0] lanes;reg wr;reg [1:0] state;
assign hburst=0;
function [31:0] swap(input [31:0] v);begin swap={v[7:0],v[15:8],v[23:16],v[31:24]};end endfunction
wire reset_n=rst_i&&hreset_n;
always @(posedge clk_i or negedge reset_n)if(!reset_n)begin request<=0;cs1<=0;cs2<=0;busy<=0;ack_o<=0;data_o<=0;address<=0;data<=0;lanes<=0;wr<=0;end else begin
cs1<=completed;cs2<=cs1;ack_o<=0;
if(!busy&&cyc_i&&stb_i&&!ack_o)begin address<=addr_i;data<=data_i;lanes<=sel_i;wr<=we_i;request<=~request;busy<=1;end
else if(busy&&cs2==request)begin data_o<=swap(read_data);ack_o<=cyc_i;busy<=0;end end
always @(posedge hclk or negedge reset_n)if(!reset_n)begin rs1<=0;rs2<=0;completed<=0;state<=0;htrans<=0;hsize<=0;hwrite<=0;haddr<=0;hwdata<=0;read_data<=0;end else begin
rs1<=request;rs2<=rs1;
case(state)
0:if(rs2!=completed)begin haddr<=address;hwrite<=wr;hwdata<=swap(data);htrans<=2;state<=1;
case(lanes)1:begin hsize<=0;haddr<={address[31:2],2'd0};end 2:begin hsize<=0;haddr<={address[31:2],2'd1};end 4:begin hsize<=0;haddr<={address[31:2],2'd2};end 8:begin hsize<=0;haddr<={address[31:2],2'd3};end 3:begin hsize<=1;haddr<={address[31:2],2'b00};end 12:begin hsize<=1;haddr<={address[31:2],2'b10};end default:hsize<=2;endcase end
1:if(hready)begin htrans<=0;state<=2;end
2:if(hready)begin read_data<=hrdata;completed<=rs2;state<=0;end
endcase end endmodule
