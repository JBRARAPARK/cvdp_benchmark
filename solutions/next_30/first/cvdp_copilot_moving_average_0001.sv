module moving_average(input clk,reset,input [11:0] data_in,output reg [11:0] data_out);
reg [11:0] samples[0:7];reg [2:0] ptr;reg [14:0] sum;integer i;
wire [14:0] next_sum=sum-{3'b0,samples[ptr]}+{3'b0,data_in};
always @(posedge clk)begin
 if(reset)begin ptr<=0;sum<=0;data_out<=0;for(i=0;i<8;i=i+1)samples[i]<=0;end
 else begin samples[ptr]<=data_in;ptr<=ptr+1'b1;sum<=next_sum;data_out<=next_sum[14:3];end
end
endmodule
