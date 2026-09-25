module rounding #(parameter WIDTH=24)(input [WIDTH-1:0] in_data,input sign,roundin,stickyin,input [2:0] rm,output [WIDTH-1:0] out_data,output inexact,cout,r_up);
reg rounding_up;
always @*case(rm)
0:rounding_up=roundin&(stickyin|in_data[0]);1:rounding_up=0;
2:rounding_up=~sign&(roundin|stickyin);3:rounding_up=sign&(roundin|stickyin)&(~(&in_data));
4:rounding_up=roundin;default:rounding_up=0;endcase
assign {cout,out_data}={1'b0,in_data}+rounding_up;
assign inexact=roundin|stickyin;assign r_up=rounding_up;
endmodule
