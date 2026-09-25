module binary_to_bcd(input logic [7:0] binary_in,output logic [11:0] bcd_out);
reg [19:0] shift_reg;integer i,j;
always @*begin
 shift_reg={12'd0,binary_in};
 for(i=0;i<8;i=i+1)begin
 for(j=8;j<20;j=j+4)if(shift_reg[j+:4]>=5)shift_reg[j+:4]=shift_reg[j+:4]+4'd3;
 shift_reg=shift_reg<<1;
 end
 bcd_out=shift_reg[19:8];
end
endmodule
