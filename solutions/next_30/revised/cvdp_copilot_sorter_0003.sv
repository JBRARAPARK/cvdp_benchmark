module sorting_engine #(parameter N=8,WIDTH=8)(input clk,rst,start,input [N*WIDTH-1:0] in_data,output reg done,output reg [N*WIDTH-1:0] out_data);
localparam IDLE=0,SORTING=1,DONE=2;
reg [1:0] state,phase;reg [WIDTH-1:0] array[0:N-1],key;integer i,j;
always @(posedge clk or posedge rst)begin
 if(rst)begin state<=IDLE;phase<=0;i<=0;j<=0;key<=0;done<=0;out_data<=0;end
 else case(state)
 IDLE:begin done<=0;if(start)begin for(integer k=0;k<N;k=k+1)array[k]<=in_data[k*WIDTH+:WIDTH];i<=1;phase<=0;state<=SORTING;end end
 SORTING:case(phase)
 0:if(i>=N)state<=DONE;else begin key<=array[i];j<=i-1;phase<=1;end
 1:if(j>=0 && array[j]>key)begin array[j+1]<=array[j];j<=j-1;end else phase<=2;
 2:begin array[j+1]<=key;i<=i+1;phase<=0;end
 default:phase<=0;
 endcase
 DONE:begin for(integer k=0;k<N;k=k+1)out_data[k*WIDTH+:WIDTH]<=array[k];done<=1;state<=IDLE;end
 default:state<=IDLE;
 endcase
end
endmodule
