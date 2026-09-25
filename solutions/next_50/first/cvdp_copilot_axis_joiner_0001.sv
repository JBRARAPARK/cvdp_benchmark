module axis_joiner(input clk,rst,
input [7:0] s_axis_tdata_1,input s_axis_tvalid_1,output s_axis_tready_1,input s_axis_tlast_1,
input [7:0] s_axis_tdata_2,input s_axis_tvalid_2,output s_axis_tready_2,input s_axis_tlast_2,
input [7:0] s_axis_tdata_3,input s_axis_tvalid_3,output s_axis_tready_3,input s_axis_tlast_3,
output reg [7:0] m_axis_tdata,output reg m_axis_tvalid,input m_axis_tready,output reg m_axis_tlast,output reg [1:0] m_axis_tuser,output busy);
reg [1:0] state;wire room=!m_axis_tvalid||m_axis_tready;assign busy=state!=0||m_axis_tvalid;
assign s_axis_tready_1=!rst&&state==1&&room;
assign s_axis_tready_2=!rst&&state==2&&room;
assign s_axis_tready_3=!rst&&state==3&&room;
always @(posedge clk or posedge rst)if(rst)begin state<=0;m_axis_tdata<=0;m_axis_tvalid<=0;m_axis_tlast<=0;m_axis_tuser<=0;end else begin
if(room)m_axis_tvalid<=0;
case(state)
0:if(s_axis_tvalid_1)state<=1;else if(s_axis_tvalid_2)state<=2;else if(s_axis_tvalid_3)state<=3;
1:if(room && s_axis_tvalid_1)begin m_axis_tdata<=s_axis_tdata_1;m_axis_tvalid<=1;m_axis_tlast<=s_axis_tlast_1;m_axis_tuser<=1;if(s_axis_tlast_1)state<=0;end
2:if(room && s_axis_tvalid_2)begin m_axis_tdata<=s_axis_tdata_2;m_axis_tvalid<=1;m_axis_tlast<=s_axis_tlast_2;m_axis_tuser<=2;if(s_axis_tlast_2)state<=0;end
3:if(room && s_axis_tvalid_3)begin m_axis_tdata<=s_axis_tdata_3;m_axis_tvalid<=1;m_axis_tlast<=s_axis_tlast_3;m_axis_tuser<=3;if(s_axis_tlast_3)state<=0;end
endcase end endmodule
