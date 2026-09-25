module clock_divider(input clk,rst_n,input [1:0] sel,output reg clk_out);
reg [2:0] count;
always @(posedge clk or negedge rst_n)begin
 if(!rst_n)begin count<=0;clk_out<=0;end
 else case(sel)
 0:begin count<=0;clk_out<=~clk_out;end
 1:if(count==1)begin count<=0;clk_out<=~clk_out;end else count<=count+1'b1;
 2:if(count==3)begin count<=0;clk_out<=~clk_out;end else count<=count+1'b1;
 default:begin count<=0;clk_out<=0;end
 endcase
end
endmodule
