module barrel_shifter #(parameter data_width=16,shift_bits_width=4)(input [data_width-1:0] data_in,input [shift_bits_width-1:0] shift_bits,input left_right,rotate_left_right,output reg [data_width-1:0] data_out);
integer amount;
always @* begin
 amount=shift_bits%data_width;
 if(!rotate_left_right)data_out=left_right?(data_in<<shift_bits):(data_in>>shift_bits);
 else if(amount==0)data_out=data_in;
 else if(left_right)data_out=(data_in<<amount)|(data_in>>(data_width-amount));
 else data_out=(data_in>>amount)|(data_in<<(data_width-amount));
end
endmodule
