module decoder_64b66b(input clk_in,rst_in,decoder_data_valid_in,input [65:0] decoder_data_in,output reg [63:0] decoder_data_out,output reg [7:0] decoder_control_out,output reg sync_error,decoder_error_out);
wire [1:0] sync_header=decoder_data_in[65:64];wire [7:0] type_field=decoder_data_in[63:56];wire [55:0] d=decoder_data_in[55:0];
always @(posedge clk_in or posedge rst_in)begin
if(rst_in)begin decoder_data_out<=0;decoder_control_out<=0;sync_error<=0;decoder_error_out<=0;end
else if(decoder_data_valid_in)begin
 decoder_data_out<=0;decoder_control_out<=0;sync_error<=0;decoder_error_out<=0;
 if(sync_header==1)decoder_data_out<=decoder_data_in[63:0];
 else if(sync_header!=2)sync_error<=1;
 else case(type_field)
8'h1e:begin decoder_control_out<=8'hff;for(integer i=0;i<8;i=i+1)case(d[i*7+:7])7'h00:decoder_data_out[i*8+:8]<=8'h07;7'h1e:decoder_data_out[i*8+:8]<=8'hfe;default:begin decoder_data_out[i*8+:8]<=8'hfe;decoder_error_out<=1;end endcaseend
8'h33:begin decoder_data_out<={d[55:32],8'hfb,{4{8'h07}}};decoder_control_out<=8'h1f;end
8'h78:begin decoder_data_out<={d,8'hfb};decoder_control_out<=8'h01;end
8'h2d:begin decoder_data_out<={d[55:32],8'h9c,{4{8'h07}}};decoder_control_out<=8'h1f;end
8'h4b:begin decoder_data_out<={{4{8'h07}},d[23:0],8'h9c};decoder_control_out<=8'hf1;end
8'h55:begin decoder_data_out<={d[55:32],8'h9c,d[23:0],8'h9c};decoder_control_out<=8'h11;end
8'h66:begin decoder_data_out<={d[55:32],8'hfb,d[23:0],8'h9c};decoder_control_out<=8'h11;end
8'h87:begin decoder_data_out<={{7{8'h07}},8'hfd};decoder_control_out<=8'hfe;end
8'h99:begin decoder_data_out<={{6{8'h07}},8'hfd,d[7:0]};decoder_control_out<=8'hfe;end
8'haa:begin decoder_data_out<={{5{8'h07}},8'hfd,d[15:0]};decoder_control_out<=8'hfc;end
8'hb4:begin decoder_data_out<={{4{8'h07}},8'hfd,d[23:0]};decoder_control_out<=8'hf8;end
8'hcc:begin decoder_data_out<={{3{8'h07}},8'hfd,d[31:0]};decoder_control_out<=8'hf0;end
8'hd2:begin decoder_data_out<={{2{8'h07}},8'hfd,d[39:0]};decoder_control_out<=8'he0;end
8'he1:begin decoder_data_out<={{1{8'h07}},8'hfd,d[47:0]};decoder_control_out<=8'hc0;end
8'hff:begin decoder_data_out<={8'hfd,d[55:0]};decoder_control_out<=8'h80;end
default:begin decoder_error_out<=1;decoder_control_out<=8'hff;decoder_data_out<={8{8'hfe}};endendcase end end
endmodule
