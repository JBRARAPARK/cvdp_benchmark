module dbi_enc(input [39:0] data_in,input clk,rst_n,output reg [39:0] data_out,output reg [1:0] dbi_cntrl);
integer a,b,i;always @*begin a=0;b=0;for(i=0;i<20;i=i+1)begin a=a+(data_in[i]^data_out[i]);b=b+(data_in[i+20]^data_out[i+20]);end end
always @(posedge clk or negedge rst_n)if(!rst_n)begin data_out<=0;dbi_cntrl<=0;end else begin dbi_cntrl<={b>10,a>10};data_out<={b>10?~data_in[39:20]:data_in[39:20],a>10?~data_in[19:0]:data_in[19:0]};end endmodule
