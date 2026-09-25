module priority_encoder_8x3(input wire [7:0] in, output reg [2:0] out);
integer i;
always @* begin
 out=0;
 for(i=0;i<8;i=i+1) if(in[i]) out=i;
end
endmodule
