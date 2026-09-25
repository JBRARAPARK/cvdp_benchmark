module axi_alu(input axi_clk_in,fast_clk_in,reset_in,
input axi_awvalid_i,axi_wvalid_i,axi_bready_i,axi_arvalid_i,axi_rready_i,
output axi_awready_o,axi_wready_o,output reg axi_bvalid_o,output axi_arready_o,output reg axi_rvalid_o,
input [31:0] axi_awaddr_i,axi_wdata_i,axi_araddr_i,input [3:0] axi_wstrb_i,output reg [31:0] axi_rdata_o,output [63:0] result_o,
input [7:0] axi_awlen_i,axi_arlen_i,input [2:0] axi_awsize_i,axi_arsize_i,input [1:0] axi_awburst_i,axi_arburst_i,input axi_wlast_i,output reg axi_rlast_o,output [1:0] axi_rresp_o,axi_bresp_o);
reg [31:0] csr[0:31];wire [31:0] ram[0:15];

reg wa,ra;reg [1:0] read_delay;reg [31:0] waddr,raddr;reg [7:0] wleft,rleft;reg [2:0] wsize,rsize;reg [1:0] wburst,rburst;
wire mem_we=axi_wvalid_i&&axi_wready_o&&waddr>=32'h20&&waddr<32'h60;
alu_memory_block u_memory_block(axi_clk_in,reset_in,mem_we,((waddr-32'h20)>>2),axi_wdata_i,axi_wstrb_i,ram);
wire clock_control=csr[4][0];wire clk=clock_control?fast_clk_in:axi_clk_in;
reg [98:0] sync1,sync2;wire [98:0] request={csr[3][2:0],csr[2],csr[1],csr[0]};wire [98:0] req=clock_control?sync2:request;
reg [31:0] a,b,c;reg [63:0] result,result_sync1,result_sync2;
assign result_o=result;assign axi_awready_o=!wa&&!axi_bvalid_o;assign axi_wready_o=wa&&!axi_bvalid_o;assign axi_arready_o=!ra&&!axi_rvalid_o;assign axi_rresp_o=0;assign axi_bresp_o=0;
function [31:0] read_word(input [31:0] address);begin if(address>=32'h20&&address<32'h60)read_word=ram[(address-32'h20)>>2];else if(address<128)read_word=csr[address>>2];else read_word=0;end endfunction
integer i,j;
always @(posedge fast_clk_in or posedge reset_in)if(reset_in)begin sync1<=0;sync2<=0;end else begin sync1<=request;sync2<=sync1;end
always @(posedge clk or posedge reset_in)if(reset_in)begin a<=0;b<=0;c<=0;result<=0;end else begin
 a<=ram[req[3:0]];b<=ram[req[35:32]];c<=ram[req[67:64]];
 if(req[98])case(req[97:96])0:result<=({32'b0,a}+b)*c;1:result<={32'b0,a}*b;2:result<=a>>b[4:0];3:result<=b==0?64'hDEADDEAD:a/b;endcase
end
always @(posedge axi_clk_in or posedge reset_in)if(reset_in)begin
wa<=0;ra<=0;read_delay<=0;waddr<=0;raddr<=0;wleft<=0;rleft<=0;wsize<=0;rsize<=0;wburst<=0;rburst<=0;
axi_bvalid_o<=0;axi_rvalid_o<=0;axi_rlast_o<=0;axi_rdata_o<=0;result_sync1<=0;result_sync2<=0;
for(i=0;i<32;i=i+1)csr[i]<=0;
end else begin
result_sync1<=result;result_sync2<=result_sync1;
if(csr[3][2]&&ram[0]<31)begin csr[ram[0]]<=clock_control?result_sync2[31:0]:result[31:0];csr[ram[0]+1]<=clock_control?result_sync2[63:32]:result[63:32];end
if(ra&&!axi_rvalid_o)begin if(read_delay!=0)read_delay<=read_delay-1'b1;else begin axi_rvalid_o<=1;axi_rdata_o<=read_word(raddr);axi_rlast_o<=rleft==0;end end
if(axi_bvalid_o&&axi_bready_i)axi_bvalid_o<=0;
if(axi_awvalid_i&&axi_awready_o)begin wa<=1;waddr<=axi_awaddr_i;wleft<=axi_awlen_i;wsize<=axi_awsize_i;wburst<=axi_awburst_i;end
if(axi_wvalid_i&&axi_wready_o)begin
for(j=0;j<4;j=j+1)if(axi_wstrb_i[j])begin
if(waddr<32'h20)csr[waddr>>2][j*8+:8]<=axi_wdata_i[j*8+:8];end
if(wleft==0||axi_wlast_i)begin wa<=0;axi_bvalid_o<=1;end else begin wleft<=wleft-1;if(wburst==1)waddr<=waddr+(32'b1<<wsize);end end
if(axi_arvalid_i&&axi_arready_o)begin ra<=1;raddr<=axi_araddr_i;rleft<=axi_arlen_i;rsize<=axi_arsize_i;rburst<=axi_arburst_i;read_delay<=1;axi_rvalid_o<=0;axi_rlast_o<=0;end
if(axi_rvalid_o&&axi_rready_i)begin if(rleft==0)begin ra<=0;axi_rvalid_o<=0;axi_rlast_o<=0;end else begin rleft<=rleft-1;axi_rlast_o<=rleft==1;if(rburst==1)begin raddr<=raddr+(32'b1<<rsize);axi_rdata_o<=read_word(raddr+(32'b1<<rsize));end else axi_rdata_o<=read_word(raddr);end end
end
endmodule

module alu_memory_block(input clk,reset,we,input [31:0] address,input [31:0] data,input [3:0] strobe,output reg [31:0] ram[0:15]);
integer i,j;always @(posedge clk or posedge reset)if(reset)begin for(i=0;i<16;i=i+1)ram[i]<=0;end else if(we)for(j=0;j<4;j=j+1)if(strobe[j])ram[address[3:0]][8*j+:8]<=data[8*j+:8];endmodule
