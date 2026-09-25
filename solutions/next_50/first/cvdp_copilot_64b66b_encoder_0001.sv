module encoder_64b66b(input clk_in,rst_in,input [63:0] encoder_data_in,input [7:0] encoder_control_in,output reg [65:0] encoder_data_out);
always @(posedge clk_in or posedge rst_in)if(rst_in)encoder_data_out<=0;else encoder_data_out<=encoder_control_in==0?{2'b01,encoder_data_in}:{2'b10,64'b0};endmodule
