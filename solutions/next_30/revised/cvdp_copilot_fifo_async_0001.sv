module fifo_async #(parameter DATA_WIDTH=32,DEPTH=16)(input w_clk,w_rst,w_inc,input [DATA_WIDTH-1:0] w_data,input r_clk,r_rst,r_inc,output w_full,r_empty,output wire [DATA_WIDTH-1:0] r_data);
localparam AW=$clog2(DEPTH);
reg [DATA_WIDTH-1:0] mem[0:DEPTH-1];
reg [AW:0] wb,rb,wg,rg,rs1,rs2,ws1,ws2;
wire [AW:0] wn=wb+{{AW{1'b0}},(w_inc&&!w_full)};
wire [AW:0] rn=rb+{{AW{1'b0}},(r_inc&&!r_empty)};
wire [AW:0] rbin;
genvar j;generate for(j=0;j<=AW;j=j+1)begin assign rbin[j]=^(rs2>>j);end endgenerate
assign w_full=(wb[AW]!=rbin[AW]) && (wb[AW-1:0]==rbin[AW-1:0]);
assign r_empty=rg==ws2;
assign r_data=mem[rb[AW-1:0]];
always @(posedge w_clk or posedge w_rst)if(w_rst)begin wb<=0;wg<=0;rs1<=0;rs2<=0;end
else begin rs1<=rg;rs2<=rs1;wb<=wn;wg<=(wn>>1)^wn;if(w_inc&&!w_full)mem[wb[AW-1:0]]<=w_data;end
always @(posedge r_clk or posedge r_rst)if(r_rst)begin rb<=0;rg<=0;ws1<=0;ws2<=0;end
else begin ws1<=wg;ws2<=ws1;rb<=rn;rg<=(rn>>1)^rn;end
endmodule
