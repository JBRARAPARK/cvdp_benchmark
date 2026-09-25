module convolutional_encoder(input clk,rst,data_in,output reg encoded_bit1,encoded_bit2);reg [1:0] history;
always @(posedge clk or posedge rst)if(rst)begin history<=0;encoded_bit1<=0;encoded_bit2<=0;end else begin encoded_bit1<=data_in^history[0]^history[1];encoded_bit2<=data_in^history[1];history<={history[0],data_in};end endmodule
