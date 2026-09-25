module gf_multiplier(input [7:0] A,B,output reg [7:0] result);
reg [8:0] term;integer i;
always @*begin term={1'b0,A};result=0;
 for(i=0;i<8;i=i+1)begin if(B[i])result=result^term[7:0];term=term<<1;if(term[8])term=term^9'h11b;end
end
endmodule
