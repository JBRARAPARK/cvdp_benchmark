module square_root_seq #(parameter WIDTH=16)(input [WIDTH-1:0] num,input clk,rst,start,output reg [WIDTH/2-1:0] final_root,output reg done);
reg busy;reg [WIDTH:0] remainder,odd;reg [WIDTH/2-1:0] root;
always @(posedge clk or posedge rst)if(rst)begin busy<=0;remainder<=0;odd<=0;root<=0;final_root<=0;done<=0;end
else begin done<=0;if(!busy)begin if(start)begin remainder<={1'b0,num};odd<=1;root<=0;busy<=1;end end
else if(remainder>=odd)begin remainder<=remainder-odd;odd<=odd+2;root<=root+1'b1;end
else begin final_root<=root;done<=1;busy<=0;end end
endmodule
