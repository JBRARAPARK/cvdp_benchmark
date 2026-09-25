module advanced_decimator_with_adaptive_peak_detection #(parameter N=8,DATA_WIDTH=16,DEC_FACTOR=4,MSB_FIRST=1)(input clk,reset,valid_in,input [N*DATA_WIDTH-1:0] data_in,output reg valid_out,output reg [DATA_WIDTH*(N/DEC_FACTOR)-1:0] data_out,output reg signed [DATA_WIDTH-1:0] peak_value);
reg [N*DATA_WIDTH-1:0] samples;integer i,src,dst;reg signed [DATA_WIDTH-1:0] value;
always @(posedge clk or posedge reset)if(reset)begin samples<=0;valid_out<=0;end else begin samples<=data_in;valid_out<=valid_in;end
always @*begin data_out=0;peak_value={1'b1,{(DATA_WIDTH-1){1'b0}}};value=0;src=0;dst=0;
for(i=0;i<N/DEC_FACTOR;i=i+1)begin src=MSB_FIRST?N-1-i*DEC_FACTOR:i*DEC_FACTOR;dst=MSB_FIRST?N/DEC_FACTOR-1-i:i;value=$signed(samples[src*DATA_WIDTH+:DATA_WIDTH]);data_out[dst*DATA_WIDTH+:DATA_WIDTH]=value;if(value>peak_value)peak_value=value;end end endmodule
