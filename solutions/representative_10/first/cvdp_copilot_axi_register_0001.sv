module axi_register #(parameter ADDR_WIDTH=32, DATA_WIDTH=32)(
input logic clk_i,rst_n_i,input logic [ADDR_WIDTH-1:0] awaddr_i,input logic awvalid_i,
input logic [DATA_WIDTH-1:0] wdata_i,input logic wvalid_i,input logic [DATA_WIDTH/8-1:0] wstrb_i,
input logic bready_i,input logic [ADDR_WIDTH-1:0] araddr_i,input logic arvalid_i,rready_i,done_i,
output logic awready_o,wready_o,output logic [1:0] bresp_o,output logic bvalid_o,arready_o,
output logic [DATA_WIDTH-1:0] rdata_o,output logic rvalid_o,output logic [1:0] rresp_o,
output logic [19:0] beat_o,output logic start_o,writeback_o);
logic have_addr,have_data,done_q;
logic [11:0] addr;
logic [DATA_WIDTH-1:0] data_q;
logic [DATA_WIDTH/8-1:0] strb_q;
assign awready_o= !have_addr && !bvalid_o;
assign wready_o= !have_data && !bvalid_o;
assign arready_o= !rvalid_o;
always_ff @(posedge clk_i or negedge rst_n_i) begin
 if(!rst_n_i) begin have_addr<=0;have_data<=0;addr<=0;data_q<=0;strb_q<=0;done_q<=0;
 bvalid_o<=0;bresp_o<=0;rvalid_o<=0;rresp_o<=0;rdata_o<=0;beat_o<=0;start_o<=0;writeback_o<=0;end
 else begin
 if(done_i)done_q<=1;
 if(awready_o && awvalid_i)begin addr<=awaddr_i[11:0];have_addr<=1;end
 if(wready_o && wvalid_i)begin data_q<=wdata_i;strb_q<=wstrb_i;have_data<=1;end
 if(bvalid_o && bready_i)bvalid_o<=0;
 if(have_addr && have_data && !bvalid_o)begin
 have_addr<=0;have_data<=0;bvalid_o<=1;bresp_o<=0;
 case(addr)
 12'h100: if(&strb_q)beat_o<=20'(data_q);
 12'h200: if(&strb_q)start_o<=data_q[0];
 12'h300: if((&strb_q) && data_q[0])done_q<=0;
 12'h400: if(&strb_q)writeback_o<=data_q[0];
 default:bresp_o<=2'b10;
 endcase
 end
 if(rvalid_o && rready_i)rvalid_o<=0;
 if(arready_o && arvalid_i)begin
 rvalid_o<=1;rresp_o<=0;
 case(araddr_i[11:0])
 12'h100:rdata_o<=DATA_WIDTH'(beat_o);
 12'h200:rdata_o<=DATA_WIDTH'(start_o);
 12'h300:rdata_o<=DATA_WIDTH'(done_q | done_i);
 12'h400:rdata_o<=DATA_WIDTH'(writeback_o);
 12'h500:rdata_o<=DATA_WIDTH'(32'h00010001);
 default:begin rdata_o<=0;rresp_o<=2'b10;end
 endcase
 end
 end
end
endmodule
