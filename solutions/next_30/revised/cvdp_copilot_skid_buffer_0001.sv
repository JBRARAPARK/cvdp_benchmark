module pipelined_skid_buffer(input clock,rst,input [3:0] data_i,input valid_i,output ready_o,valid_o,output [3:0] data_o,input ready_i);
wire [3:0] d0,d1,d2;wire v0,v1,v2,r0,r1,r2;
skid_buffer skid_0(clock,rst,data_i,valid_i,ready_o,d0,v0,r0);
register reg1(clock,rst,d0,v0,r0,v1,d1,r1);
skid_buffer skid_2(clock,rst,d1,v1,r1,d2,v2,r2);
register reg3(clock,rst,d2,v2,r2,valid_o,data_o,ready_i);
endmodule
module register(input clk,rst,input [3:0] data_in,input valid_in,output ready_out,valid_out,output [3:0] data_out,input ready_in);
reg [3:0] mem;reg data_present;
assign ready_out=!data_present || ready_in;assign valid_out=data_present;assign data_out=mem;
always @(posedge clk or posedge rst)if(rst)begin mem<=0;data_present<=0;end
else if(ready_out)begin data_present<=valid_in;if(valid_in)mem<=data_in;end
endmodule
module skid_buffer(input clk,reset,input [3:0] i_data,input i_valid,output o_ready,output [3:0] o_data,output o_valid,input i_ready);
reg full;reg [3:0] data_reg;
assign o_ready=!full;assign o_valid=full || i_valid;assign o_data=full?data_reg:i_data;
always @(posedge clk or posedge reset)if(reset)begin full<=0;data_reg<=0;end
else if(full)begin if(i_ready)full<=0;end
else if(i_valid && !i_ready)begin full<=1;data_reg<=i_data;end
endmodule
