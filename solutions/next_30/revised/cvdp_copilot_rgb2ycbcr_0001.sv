module axis_rgb2ycbcr #(parameter PIXEL_WIDTH=16,FIFO_DEPTH=16)(input aclk,aresetn,input [15:0] s_axis_tdata,input s_axis_tvalid,output s_axis_tready,input s_axis_tlast,s_axis_tuser,output [15:0] m_axis_tdata,output m_axis_tvalid,input m_axis_tready,output m_axis_tlast,m_axis_tuser);
reg [15:0] fifo_data[0:FIFO_DEPTH-1];reg fifo_tlast[0:FIFO_DEPTH-1],fifo_tuser[0:FIFO_DEPTH-1];
integer write_ptr,read_ptr,count;
wire [7:0] r={s_axis_tdata[15:11],3'b0},g={s_axis_tdata[10:5],2'b0},b={s_axis_tdata[4:0],3'b0};
wire [7:0] y_calc=((77*r+150*g+29*b)>>8)+16;
wire [7:0] cb_calc=((-43*r-85*g+128*b)>>8)+128;
wire [7:0] cr_calc=((128*r-107*g-21*b)>>8)+128;
assign s_axis_tready=count<FIFO_DEPTH;assign m_axis_tvalid=count!=0;
wire empty=count==0; wire fifo_read=m_axis_tvalid && m_axis_tready;
wire push=s_axis_tvalid && s_axis_tready;wire pop=m_axis_tvalid && m_axis_tready;
assign m_axis_tdata=fifo_data[read_ptr];assign m_axis_tlast=fifo_tlast[read_ptr];assign m_axis_tuser=fifo_tuser[read_ptr];
always @(posedge aclk)begin
 if(!aresetn)begin write_ptr<=0;read_ptr<=0;count<=0;end
 else begin
 case({push,pop})2'b10:count<=count+1;2'b01:count<=count-1;endcase
 if(push)begin fifo_data[write_ptr]<={y_calc[7:3],cb_calc[7:2],cr_calc[7:3]};fifo_tlast[write_ptr]<=s_axis_tlast;fifo_tuser[write_ptr]<=s_axis_tuser;write_ptr<=write_ptr==FIFO_DEPTH-1?0:write_ptr+1;end
 if(pop)read_ptr<=read_ptr==FIFO_DEPTH-1?0:read_ptr+1;
 end
end
endmodule
