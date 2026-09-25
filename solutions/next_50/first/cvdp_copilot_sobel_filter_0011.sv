module sobel_filter #(parameter THRESHOLD=11'd128)(input clk,rst_n,input [7:0] pixel_in,input valid_in,output reg [7:0] edge_out,output reg valid_out);
reg [7:0] p[0:7];integer count,i,gx,gy,mag;
always @*begin gx=-int'(p[0])+int'(p[2])-2*int'(p[3])+2*int'(p[5])-int'(p[6])+int'(pixel_in);gy=-int'(p[0])-2*int'(p[1])-int'(p[2])+int'(p[6])+2*int'(p[7])+int'(pixel_in);mag=(gx<0?-gx:gx)+(gy<0?-gy:gy);end
always @(posedge clk or negedge rst_n)if(!rst_n)begin count<=0;edge_out<=0;valid_out<=0;for(i=0;i<8;i=i+1)p[i]<=0;end else begin edge_out<=0;valid_out<=0;if(valid_in)begin if(count==8)begin edge_out<=mag>THRESHOLD?255:0;valid_out<=1;count<=0;for(i=0;i<8;i=i+1)p[i]<=0;end else begin p[count]<=pixel_in;count<=count+1;end end end endmodule
