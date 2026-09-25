module convolutional_encoder(input clk,rst,data_in,output reg encoded_bit1,encoded_bit2);reg [1:0] shift_reg;
always @(posedge clk or posedge rst)if(rst)begin shift_reg<=0;encoded_bit1<=0;encoded_bit2<=0;end else begin encoded_bit1<=data_in^shift_reg[0]^shift_reg[1];encoded_bit2<=data_in^shift_reg[1];shift_reg<={shift_reg[0],data_in};end endmodule
