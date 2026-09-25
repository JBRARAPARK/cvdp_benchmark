module signed_unsigned_comparator #(parameter WIDTH=5)(input [WIDTH-1:0] i_A,i_B,input i_enable,i_mode,output reg o_greater,o_less,o_equal);
always @* begin
 o_greater=0;o_less=0;o_equal=0;
 if(i_enable)begin
 o_equal=i_A==i_B;
 if(i_mode)begin o_greater=$signed(i_A)>$signed(i_B);o_less=$signed(i_A)<$signed(i_B);end
 else begin o_greater=i_A>i_B;o_less=i_A<i_B;end
 end
end
endmodule
