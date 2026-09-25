module axis_joiner(input clk,rst,
input [7:0] s_axis_tdata_1,input s_axis_tvalid_1,output s_axis_tready_1,input s_axis_tlast_1,
input [7:0] s_axis_tdata_2,input s_axis_tvalid_2,output s_axis_tready_2,input s_axis_tlast_2,
input [7:0] s_axis_tdata_3,input s_axis_tvalid_3,output s_axis_tready_3,input s_axis_tlast_3,
output reg [7:0] m_axis_tdata,output reg m_axis_tvalid,input m_axis_tready,output reg m_axis_tlast,output reg [1:0] m_axis_tuser,output busy);
reg [1:0] state,selected;
always @*begin selected=state;if(state==0)begin if(s_axis_tvalid_1)selected=1;else if(s_axis_tvalid_2)selected=2;else if(s_axis_tvalid_3)selected=3;end
m_axis_tdata=0;m_axis_tvalid=0;m_axis_tlast=0;m_axis_tuser=0;
if(!rst)case(selected)
1:begin m_axis_tdata=s_axis_tdata_1;m_axis_tvalid=s_axis_tvalid_1;m_axis_tlast=s_axis_tlast_1;m_axis_tuser=1;end
2:begin m_axis_tdata=s_axis_tdata_2;m_axis_tvalid=s_axis_tvalid_2;m_axis_tlast=s_axis_tlast_2;m_axis_tuser=2;end
3:begin m_axis_tdata=s_axis_tdata_3;m_axis_tvalid=s_axis_tvalid_3;m_axis_tlast=s_axis_tlast_3;m_axis_tuser=3;end
endcase end
assign s_axis_tready_1=!rst&&selected==1&&m_axis_tready;assign s_axis_tready_2=!rst&&selected==2&&m_axis_tready;assign s_axis_tready_3=!rst&&selected==3&&m_axis_tready;assign busy=selected!=0;
always @(posedge clk or posedge rst)if(rst)state<=0;else if(m_axis_tvalid)begin if(m_axis_tready&&m_axis_tlast)state<=0;else state<=selected;end
endmodule
