module dot_product(input clk_in,reset_in,start_in,input [6:0] dot_length_in,input [7:0] vector_a_in,input vector_a_valid_in,input [15:0] vector_b_in,input vector_b_valid_in,output reg [31:0] dot_product_out,output reg dot_product_valid_out);
reg [1:0] state;reg [6:0] count,length;reg [31:0] acc;
always @(posedge clk_in or posedge reset_in)if(reset_in)begin state<=0;count<=0;length<=0;acc<=0;dot_product_out<=0;dot_product_valid_out<=0;end
else begin dot_product_valid_out<=0;case(state)
0:if(start_in)begin count<=0;length<=dot_length_in;acc<=0;state<=dot_length_in==0?2:1;end
1:if(vector_a_valid_in&&vector_b_valid_in)begin acc<=acc+vector_a_in*vector_b_in;count<=count+1'b1;if(count==length-1)state<=2;end
2:begin dot_product_out<=acc;dot_product_valid_out<=1;state<=0;end
endcase end
endmodule
