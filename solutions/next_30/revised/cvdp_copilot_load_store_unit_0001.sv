module load_store_unit(input clk,rst_n,output reg dmem_req_o,input dmem_gnt_i,output reg [31:0] dmem_req_addr_o,output reg dmem_req_we_o,output reg [3:0] dmem_req_be_o,output reg [31:0] dmem_req_wdata_o,input dmem_rvalid_i,input [31:0] dmem_rsp_rdata_i,input ex_if_req_i,ex_if_we_i,input [1:0] ex_if_type_i,input [31:0] ex_if_wdata_i,ex_if_addr_base_i,ex_if_addr_offset_i,output ex_if_ready_o,output reg [31:0] wb_if_rdata_o,output reg wb_if_rvalid_o);
reg [1:0] state;
wire [31:0] addr=ex_if_addr_base_i+ex_if_addr_offset_i;
wire aligned=(ex_if_type_i==0)||((ex_if_type_i==1)&&!addr[0])||((ex_if_type_i==2)&&addr[1:0]==0);
assign ex_if_ready_o=state==0;
always @(posedge clk or negedge rst_n)begin
 if(!rst_n)begin state<=0;dmem_req_o<=0;dmem_req_addr_o<=0;dmem_req_we_o<=0;dmem_req_be_o<=0;dmem_req_wdata_o<=0;wb_if_rdata_o<=0;wb_if_rvalid_o<=0;end
 else begin wb_if_rvalid_o<=0;
 case(state)
 0:if(ex_if_req_i && aligned)begin state<=1;dmem_req_o<=1;dmem_req_addr_o<=addr;dmem_req_we_o<=ex_if_we_i;dmem_req_wdata_o<=ex_if_we_i?ex_if_wdata_i:0;
 case(ex_if_type_i)0:dmem_req_be_o<=4'b1<<addr[1:0];1:dmem_req_be_o<=4'b11<<addr[1:0];2:dmem_req_be_o<=4'b1111;endcase end
 1:if(dmem_gnt_i)begin state<=dmem_req_we_o?0:2;dmem_req_o<=0;dmem_req_we_o<=0;dmem_req_addr_o<=0;dmem_req_be_o<=0;dmem_req_wdata_o<=0;end
 2:if(dmem_rvalid_i)begin wb_if_rdata_o<=dmem_rsp_rdata_i;wb_if_rvalid_o<=1;state<=0;end
 default:state<=0;
 endcase end
end
endmodule
