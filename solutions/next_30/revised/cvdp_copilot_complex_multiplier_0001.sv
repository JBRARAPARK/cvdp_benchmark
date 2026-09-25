module complex_multiplier(input clk,arst_n,input signed [15:0] a_real,a_imag,b_real,b_imag,output reg signed [31:0] result_real,result_imag);
always @(posedge clk or negedge arst_n)begin
 if(!arst_n)begin result_real<=0;result_imag<=0;end
 else begin result_real<=a_real*b_real-a_imag*b_imag;result_imag<=a_real*b_imag+a_imag*b_real;end
end
endmodule
