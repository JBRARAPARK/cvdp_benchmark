module low_pass_filter #(parameter DATA_WIDTH=16,COEFF_WIDTH=16,NUM_TAPS=8,localparam NBW_MULT=DATA_WIDTH+COEFF_WIDTH)(input clk,reset,input [DATA_WIDTH*NUM_TAPS-1:0] data_in,input valid_in,input [COEFF_WIDTH*NUM_TAPS-1:0] coeffs,output signed [NBW_MULT+$clog2(NUM_TAPS)-1:0] data_out,output reg valid_out);
localparam AW=NBW_MULT+$clog2(NUM_TAPS), LEAVES=1<<$clog2(NUM_TAPS);
reg [DATA_WIDTH*NUM_TAPS-1:0] d;reg [COEFF_WIDTH*NUM_TAPS-1:0] c;
always @(posedge clk)if(reset)begin d<=0;c<=0;valid_out<=0;end else begin valid_out<=valid_in;if(valid_in)begin d<=data_in;c<=coeffs;end end
wire signed [AW-1:0] tree[1:2*LEAVES-1];genvar i;
generate for(i=0;i<LEAVES;i=i+1)begin:leaf
if(i<NUM_TAPS)begin wire signed [NBW_MULT-1:0] p;assign p=$signed(d[i*DATA_WIDTH+:DATA_WIDTH])*$signed(c[(NUM_TAPS-1-i)*COEFF_WIDTH+:COEFF_WIDTH]);assign tree[LEAVES+i]=p;end else assign tree[LEAVES+i]=0;end
for(i=1;i<LEAVES;i=i+1)begin:sum assign tree[i]=tree[2*i]+tree[2*i+1];end endgenerate
assign data_out=tree[1];endmodule
