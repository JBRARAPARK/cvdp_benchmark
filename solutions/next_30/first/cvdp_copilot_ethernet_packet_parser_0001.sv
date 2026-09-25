module ethernet_packet_parser(input clk,rst,vld,sof,input [31:0] data,input eof,output ack,output reg [15:0] field,output reg field_vld);
reg [1:0] state;reg [15:0] captured;reg [3:0] beat_cnt;
assign ack=1;
always @(posedge clk or posedge rst)begin
 if(rst)begin state<=0;captured<=0;field<=0;field_vld<=0;beat_cnt<=0;end
 else if(eof)begin state<=0;field_vld<=0;end
 else case(state)
 0:if(vld && sof)begin state<=1;beat_cnt<=1;field<=0;field_vld<=0;end
 1:if(vld)begin beat_cnt<=beat_cnt+1'b1;if(beat_cnt==1)begin captured<=data[31:16];state<=2;end end
 2:begin field<=captured;field_vld<=1;state<=3;end
 3:begin end
 endcase
end
endmodule
