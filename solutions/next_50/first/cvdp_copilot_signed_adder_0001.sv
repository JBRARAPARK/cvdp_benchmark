module signedadder #(parameter DATA_WIDTH=8)(input i_clk,i_rst_n,i_start,i_enable,i_mode,i_clear,input [DATA_WIDTH-1:0] i_operand_a,i_operand_b,output reg [DATA_WIDTH-1:0] o_resultant_sum,output reg o_overflow,o_ready,output reg [1:0] o_status);
reg signed [DATA_WIDTH-1:0] a,b;reg mode;reg signed [DATA_WIDTH:0] result;
always @(posedge i_clk or negedge i_rst_n)if(!i_rst_n)begin a<=0;b<=0;mode<=0;result<=0;o_resultant_sum<=0;o_overflow<=0;o_ready<=0;o_status<=0;end
else if(i_clear)begin a<=0;b<=0;mode<=0;result<=0;o_resultant_sum<=0;o_overflow<=0;o_ready<=0;o_status<=0;end
else if(i_enable)begin o_ready<=0;case(o_status)
0:if(i_start)o_status<=1;
1:begin a<=i_operand_a;b<=i_operand_b;mode<=i_mode;o_status<=2;end
2:begin if(mode)result<={a[DATA_WIDTH-1],a}-{b[DATA_WIDTH-1],b};else result<={a[DATA_WIDTH-1],a}+{b[DATA_WIDTH-1],b};o_status<=3;end
3:begin o_resultant_sum<=result[DATA_WIDTH-1:0];o_overflow<=result[DATA_WIDTH]^result[DATA_WIDTH-1];o_ready<=1;o_status<=0;end
endcase end else o_ready<=0;
endmodule
