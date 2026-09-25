module binary_multiplier #(parameter WIDTH=32)(input clk,rst_n,input [WIDTH-1:0] A,B,input valid_in,output reg [2*WIDTH-1:0] Product,output reg valid_out);
reg [WIDTH-1:0] a_q;reg [2*WIDTH-1:0] shifted,sum;integer count;reg busy;
always @(posedge clk or negedge rst_n)begin
 if(!rst_n)begin Product<=0;valid_out<=0;a_q<=0;shifted<=0;sum<=0;count<=0;busy<=0;end
 else begin valid_out<=0;
 if(!busy)begin if(valid_in)begin a_q<=A;shifted<={{WIDTH{1'b0}},B};sum<=0;count<=0;busy<=1;end end
 else if(count<WIDTH)begin if(a_q[0])sum<=sum+shifted;a_q<=a_q>>1;shifted<=shifted<<1;count<=count+1;end
 else begin Product<=sum;valid_out<=1;busy<=0;end
 end
end
endmodule
