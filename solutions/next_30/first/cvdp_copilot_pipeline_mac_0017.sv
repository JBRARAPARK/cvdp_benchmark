module pipeline_mac #(parameter DWIDTH=16,N=4)(input clk,rstn,input [DWIDTH-1:0] multiplicand,multiplier,input valid_i,output reg [2*DWIDTH+$clog2(N)-1:0] result,output reg valid_out);
localparam AW=2*DWIDTH+$clog2(N);
reg [2*DWIDTH-1:0] product;reg product_valid;reg [AW-1:0] acc;integer count;
always @(posedge clk or negedge rstn)begin
 if(!rstn)begin product<=0;product_valid<=0;acc<=0;count<=0;result<=0;valid_out<=0;end
 else begin
 product_valid<=valid_i;if(valid_i)product<=multiplicand*multiplier;
 valid_out<=0;
 if(product_valid)begin
 if(count==N-1)begin result<=acc+product;valid_out<=1;count<=0;acc<=0;end
 else begin acc<=acc+product;count<=count+1;end
 end
 end
end
endmodule
