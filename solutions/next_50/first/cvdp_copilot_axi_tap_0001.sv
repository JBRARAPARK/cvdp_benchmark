module axi_tap #(
    parameter ADDR_WIDTH = 32, // Width of AXI4-Lite Address
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

reg awfull,wfull,awsent,wsent,arfull,arsent;reg [ADDR_WIDTH-1:0] awaddr,araddr;reg [DATA_WIDTH-1:0] wdata;reg [3:0] wstrb;
wire wsel=|(awaddr & 32'h80000000);wire rsel=|(araddr & 32'h80000000);
assign inport_awready_o=rst_i&&!awfull;assign inport_wready_o=rst_i&&!wfull;assign inport_arready_o=rst_i&&!arfull;
assign inport_bvalid_o=awfull&&wfull&&awsent&&wsent&&(wsel?outport_peripheral0_bvalid_i:outport_bvalid_i);
assign inport_bresp_o=wsel?outport_peripheral0_bresp_i:outport_bresp_i;
assign inport_rvalid_o=arfull&&arsent&&(rsel?outport_peripheral0_rvalid_i:outport_rvalid_i);
assign inport_rdata_o=rsel?outport_peripheral0_rdata_i:outport_rdata_i;
assign inport_rresp_o=rsel?outport_peripheral0_rresp_i:outport_rresp_i;
assign outport_awvalid_o=rst_i&&awfull&&!awsent&&!wsel;assign outport_awaddr_o=awaddr;
assign outport_wvalid_o=rst_i&&awfull&&wfull&&!wsent&&!wsel;assign outport_wdata_o=wdata;assign outport_wstrb_o=wstrb;
assign outport_bready_o=inport_bready_i&&awfull&&wfull&&awsent&&wsent&&!wsel;
assign outport_peripheral0_awvalid_o=rst_i&&awfull&&!awsent&&wsel;assign outport_peripheral0_awaddr_o=awaddr;
assign outport_peripheral0_wvalid_o=rst_i&&awfull&&wfull&&!wsent&&wsel;assign outport_peripheral0_wdata_o=wdata;assign outport_peripheral0_wstrb_o=wstrb;
assign outport_peripheral0_bready_o=inport_bready_i&&awfull&&wfull&&awsent&&wsent&&wsel;
assign outport_arvalid_o=rst_i&&arfull&&!arsent&&!rsel;assign outport_araddr_o=araddr;assign outport_rready_o=inport_rready_i&&arfull&&arsent&&!rsel;
assign outport_peripheral0_arvalid_o=rst_i&&arfull&&!arsent&&rsel;assign outport_peripheral0_araddr_o=araddr;assign outport_peripheral0_rready_o=inport_rready_i&&arfull&&arsent&&rsel;
always @(posedge clk_i or negedge rst_i)if(!rst_i)begin awfull<=0;wfull<=0;awsent<=0;wsent<=0;arfull<=0;arsent<=0;awaddr<=0;araddr<=0;wdata<=0;wstrb<=0;end else begin
if(inport_awvalid_i&&inport_awready_o)begin awfull<=1;awaddr<=inport_awaddr_i;end
if(inport_wvalid_i&&inport_wready_o)begin wfull<=1;wdata<=inport_wdata_i;wstrb<=inport_wstrb_i;end
if((outport_awvalid_o&&outport_awready_i)||(outport_peripheral0_awvalid_o&&outport_peripheral0_awready_i))awsent<=1;
if((outport_wvalid_o&&outport_wready_i)||(outport_peripheral0_wvalid_o&&outport_peripheral0_wready_i))wsent<=1;
if(inport_bvalid_o&&inport_bready_i)begin awfull<=0;wfull<=0;awsent<=0;wsent<=0;end
if(inport_arvalid_i&&inport_arready_o)begin arfull<=1;araddr<=inport_araddr_i;end
if((outport_arvalid_o&&outport_arready_i)||(outport_peripheral0_arvalid_o&&outport_peripheral0_arready_i))arsent<=1;
if(inport_rvalid_o&&inport_rready_i)begin arfull<=0;arsent<=0;end
end endmodule
