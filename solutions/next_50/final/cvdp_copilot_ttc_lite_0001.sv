module ttc_counter_lite(input clk,reset,input [3:0] axi_addr,input [31:0] axi_wdata,input axi_write_en,axi_read_en,output reg [31:0] axi_rdata,output reg interrupt);
reg [15:0] count,match_value,reload_value;reg [2:0] control_reg;wire enable=control_reg[0],interval_mode=control_reg[1],interrupt_enable=control_reg[2];
always @(posedge clk or posedge reset)if(reset)begin count<=0;match_value<=0;reload_value<=0;control_reg<=0;interrupt<=0;end else begin
if(control_reg[0])begin if(count==match_value)begin if(control_reg[2])interrupt<=1;if(control_reg[1])count<=reload_value;end else count<=count+1'b1;end
if(axi_write_en)case(axi_addr)1:match_value<=axi_wdata[15:0];2:reload_value<=axi_wdata[15:0];3:control_reg<=axi_wdata[2:0];4:interrupt<=0;default:;endcase end
always @*begin axi_rdata=0;case(axi_addr)0:axi_rdata={16'b0,count};1:axi_rdata={16'b0,match_value};2:axi_rdata={16'b0,reload_value};3:axi_rdata={29'b0,control_reg};4:axi_rdata={31'b0,interrupt};default:axi_rdata=0;endcase end endmodule
