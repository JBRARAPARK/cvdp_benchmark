module axi_tap #(
    parameter ADDR_WIDTH = 32, // Width of AXI4-Lite Address
    parameter RESET_ACTIVE_LOW = 0,
    parameter DATA_WIDTH = 32  // Width of AXI4-Lite Data
)(
    // Global Ports
    input           clk_i,
    input           rst_i,

    // Master Write Address Channel (AW)
    input           inport_awvalid_i,
    input  [ADDR_WIDTH-1:0]   inport_awaddr_i,
    output          inport_awready_o,
    // Master Write Data Channel (W)
    input           inport_wvalid_i,
    input  [DATA_WIDTH-1:0]   inport_wdata_i,
    input  [3:0]    inport_wstrb_i,
    output          inport_wready_o,
    // Master Write Response Channel (B)
    input           inport_bready_i,
    output          inport_bvalid_o,
    output [1:0]    inport_bresp_o,
    // Master Read Address Channel (AR)
    input           inport_arvalid_i,
    input  [ADDR_WIDTH-1:0]   inport_araddr_i,
    output          inport_arready_o,
    // Master Read Data Channel (R)
    input           inport_rready_i,
    output          inport_rvalid_o,
    output [DATA_WIDTH-1:0]   inport_rdata_o,
    output [1:0]    inport_rresp_o,

    // Default AXI outport
    // Write Address Channel (AW)
    input           outport_awready_i,
    output          outport_awvalid_o,
    output [ADDR_WIDTH-1:0]   outport_awaddr_o,
    // Write Data Channel (W)
    input           outport_wready_i,
    output          outport_wvalid_o,
    output [DATA_WIDTH-1:0]   outport_wdata_o,
    output [3:0]    outport_wstrb_o,
    // Write Response Channel (B)
    input           outport_bvalid_i,
    input  [1:0]    outport_bresp_i,
    output          outport_bready_o,
    // Read Address Channel (AR)
    input           outport_arready_i,
    output          outport_arvalid_o,
    output [ADDR_WIDTH-1:0]   outport_araddr_o,
    // Read Data Channel (R)
    input           outport_rvalid_i,
    input  [DATA_WIDTH-1:0]   outport_rdata_i,
    input  [1:0]    outport_rresp_i,
    output          outport_rready_o,

    // Peripheral 0 interface
    // Write Address Channel (AW)
    input           outport_peripheral0_awready_i,
    output          outport_peripheral0_awvalid_o,
    output [ADDR_WIDTH-1:0]   outport_peripheral0_awaddr_o,
    // Write Data Channel (W)
    input           outport_peripheral0_wready_i,
    output          outport_peripheral0_wvalid_o,
    output [DATA_WIDTH-1:0]   outport_peripheral0_wdata_o,
    output [3:0]    outport_peripheral0_wstrb_o,
    // Write Response Channel (B)
    input  [1:0]    outport_peripheral0_bresp_i,
    input           outport_peripheral0_bvalid_i,
    output          outport_peripheral0_bready_o,
    // Read Address Channel (AR)
    input           outport_peripheral0_arready_i,
    output          outport_peripheral0_arvalid_o,
    output [ADDR_WIDTH-1:0]   outport_peripheral0_araddr_o,
    // Read Data Channel (R)
    input  [1:0]    outport_peripheral0_rresp_i,
    input           outport_peripheral0_rvalid_i,
    input  [DATA_WIDTH-1:0]   outport_peripheral0_rdata_i,
    output          outport_peripheral0_rready_o
);

// Default follows supplied RTL; select 1 for the prose's active-low reset.
wire reset=RESET_ACTIVE_LOW?!rst_i:rst_i;
reg wpending,wsent,rpending,wroute,rroute;
wire ws=wpending?wroute:inport_awaddr_i[31];wire rs=rpending?rroute:inport_araddr_i[31];
assign inport_awready_o=!reset&&!wpending&&(ws?outport_peripheral0_awready_i:outport_awready_i);
assign outport_awvalid_o=!reset&&!wpending&&inport_awvalid_i&&!ws;
assign outport_peripheral0_awvalid_o=!reset&&!wpending&&inport_awvalid_i&&ws;
assign outport_awaddr_o=inport_awaddr_i;assign outport_peripheral0_awaddr_o=inport_awaddr_i;
wire have_aw=wpending||(inport_awvalid_i&&inport_awready_o);
assign inport_wready_o=!reset&&have_aw&&!wsent&&(ws?outport_peripheral0_wready_i:outport_wready_i);
assign outport_wvalid_o=!reset&&have_aw&&!wsent&&inport_wvalid_i&&!ws;
assign outport_peripheral0_wvalid_o=!reset&&have_aw&&!wsent&&inport_wvalid_i&&ws;
assign outport_wdata_o=inport_wdata_i;assign outport_peripheral0_wdata_o=inport_wdata_i;
assign outport_wstrb_o=inport_wstrb_i;assign outport_peripheral0_wstrb_o=inport_wstrb_i;
assign inport_bvalid_o=!reset&&wpending&&wsent&&(ws?outport_peripheral0_bvalid_i:outport_bvalid_i);
assign inport_bresp_o=ws?outport_peripheral0_bresp_i:outport_bresp_i;
assign outport_bready_o=!reset&&wpending&&wsent&&inport_bready_i&&!ws;
assign outport_peripheral0_bready_o=!reset&&wpending&&wsent&&inport_bready_i&&ws;
assign inport_arready_o=!reset&&!rpending&&(rs?outport_peripheral0_arready_i:outport_arready_i);
assign outport_arvalid_o=!reset&&!rpending&&inport_arvalid_i&&!rs;
assign outport_peripheral0_arvalid_o=!reset&&!rpending&&inport_arvalid_i&&rs;
assign outport_araddr_o=inport_araddr_i;assign outport_peripheral0_araddr_o=inport_araddr_i;
assign inport_rvalid_o=!reset&&rpending&&(rs?outport_peripheral0_rvalid_i:outport_rvalid_i);
assign inport_rdata_o=rs?outport_peripheral0_rdata_i:outport_rdata_i;
assign inport_rresp_o=rs?outport_peripheral0_rresp_i:outport_rresp_i;
assign outport_rready_o=!reset&&rpending&&inport_rready_i&&!rs;
assign outport_peripheral0_rready_o=!reset&&rpending&&inport_rready_i&&rs;
always @(posedge clk_i or posedge reset)if(reset)begin wpending<=0;wsent<=0;rpending<=0;wroute<=0;rroute<=0;end else begin
if(inport_awvalid_i&&inport_awready_o)begin wpending<=1;wroute<=inport_awaddr_i[31];end
if(inport_wvalid_i&&inport_wready_o)wsent<=1;
if(inport_bvalid_o&&inport_bready_i)begin wpending<=0;wsent<=0;end
if(inport_arvalid_i&&inport_arready_o)begin rpending<=1;rroute<=inport_araddr_i[31];end
if(inport_rvalid_o&&inport_rready_i)rpending<=0;
end endmodule
