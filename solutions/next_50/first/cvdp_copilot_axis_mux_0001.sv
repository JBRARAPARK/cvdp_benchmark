`timescale 1ns/1ps

module axis_mux #(
  parameter integer C_AXIS_DATA_WIDTH = 32,
  parameter integer C_AXIS_TUSER_WIDTH = 4,
  parameter integer C_AXIS_TID_WIDTH   = 2,
  parameter integer C_AXIS_TDEST_WIDTH = 2,
  parameter integer NUM_INPUTS         = 4
)(
  input  wire                                   aclk,
  input  wire                                   aresetn,
  input  wire [$clog2(NUM_INPUTS)-1:0]          sel,
  input  wire [NUM_INPUTS-1:0]                  s_axis_tvalid,
  output wire [NUM_INPUTS-1:0]                  s_axis_tready,
  input  wire [NUM_INPUTS*C_AXIS_DATA_WIDTH-1:0]   s_axis_tdata,
  input  wire [NUM_INPUTS*C_AXIS_DATA_WIDTH/8-1:0] s_axis_tkeep,
  input  wire [NUM_INPUTS-1:0]                  s_axis_tlast,
  input  wire [NUM_INPUTS*C_AXIS_TID_WIDTH-1:0] s_axis_tid,
  input  wire [NUM_INPUTS*C_AXIS_TDEST_WIDTH-1:0] s_axis_tdest,
  input  wire [NUM_INPUTS*C_AXIS_TUSER_WIDTH-1:0] s_axis_tuser,
  output wire                                   m_axis_tvalid,
  input  wire                                   m_axis_tready,
  output wire [C_AXIS_DATA_WIDTH-1:0]           m_axis_tdata,
  output wire [C_AXIS_DATA_WIDTH/8-1:0]         m_axis_tkeep,
  output wire                                   m_axis_tlast,
  output wire [C_AXIS_TID_WIDTH-1:0]            m_axis_tid,
  output wire [C_AXIS_TDEST_WIDTH-1:0]          m_axis_tdest,
  output wire [C_AXIS_TUSER_WIDTH-1:0]          m_axis_tuser
);

reg [$clog2(NUM_INPUTS)-1:0] sel_reg;reg frame_reg;
wire [$clog2(NUM_INPUTS)-1:0] chosen=frame_reg?sel_reg:sel;
wire active=aresetn && chosen<NUM_INPUTS;
always @(posedge aclk or negedge aresetn)if(!aresetn)begin sel_reg<=0;frame_reg<=0;end else if(active && s_axis_tvalid[chosen])begin
if(!frame_reg)sel_reg<=chosen;
frame_reg<=!(m_axis_tready && s_axis_tlast[chosen]);end
assign m_axis_tvalid=active?s_axis_tvalid[chosen]:0;
generate for(genvar i=0;i<NUM_INPUTS;i=i+1)begin assign s_axis_tready[i]=active && chosen==i && m_axis_tready;end endgenerate
assign m_axis_tdata=active?s_axis_tdata[chosen*(C_AXIS_DATA_WIDTH)+:(C_AXIS_DATA_WIDTH)]:'0;
assign m_axis_tkeep=active?s_axis_tkeep[chosen*(C_AXIS_DATA_WIDTH/8)+:(C_AXIS_DATA_WIDTH/8)]:'0;
assign m_axis_tid=active?s_axis_tid[chosen*(C_AXIS_TID_WIDTH)+:(C_AXIS_TID_WIDTH)]:'0;
assign m_axis_tdest=active?s_axis_tdest[chosen*(C_AXIS_TDEST_WIDTH)+:(C_AXIS_TDEST_WIDTH)]:'0;
assign m_axis_tuser=active?s_axis_tuser[chosen*(C_AXIS_TUSER_WIDTH)+:(C_AXIS_TUSER_WIDTH)]:'0;
assign m_axis_tlast=active?s_axis_tlast[chosen]:0;

endmodule

