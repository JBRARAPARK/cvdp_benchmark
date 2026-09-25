module reed_solomon_encoder #(parameter DATA_WIDTH=8,N=255,K=223)(input clk,reset,enable,input [DATA_WIDTH-1:0] data_in,input valid_in,output reg [DATA_WIDTH-1:0] codeword_out,output reg valid_out,output reg [DATA_WIDTH-1:0] parity_0,parity_1);
localparam PARITY_SYMBOLS=N-K;wire [DATA_WIDTH-1:0] feedback=data_in^parity_1;
function [DATA_WIDTH-1:0] generator_polynomial(input integer index);begin generator_polynomial=index==0?8'h1d:8'h33;end endfunction
function [DATA_WIDTH-1:0] gf_mult(input [DATA_WIDTH-1:0] a,b);reg [DATA_WIDTH-1:0] x,y,z;integer i;begin x=a;y=b;z=0;for(i=0;i<DATA_WIDTH;i=i+1)begin if(y[0])z=z^x;x=x[DATA_WIDTH-1]?(x<<1)^8'h1d:x<<1;y=y>>1;end gf_mult=z;end endfunction
always @(posedge clk or posedge reset)if(reset)begin parity_0<=0;parity_1<=0;codeword_out<=0;valid_out<=0;end else begin valid_out<=enable&&valid_in;if(enable&&valid_in)begin parity_0<=feedback;parity_1<=parity_0^(feedback*generator_polynomial(1));codeword_out<=data_in;end end
endmodule
