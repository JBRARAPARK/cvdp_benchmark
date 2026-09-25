module ir_receiver(input reset_in,clk_in,ir_signal_in,output reg [6:0] ir_function_code_out,output reg [4:0] ir_device_address_out,output reg ir_output_valid);
reg prev;reg [2:0] state;integer ticks,bits,delay_count;reg [11:0] frame;
always @(posedge clk_in or posedge reset_in)if(reset_in)begin prev<=0;state<=0;ticks<=0;bits<=0;delay_count<=0;frame<=0;ir_function_code_out<=0;ir_device_address_out<=0;ir_output_valid<=0;end
else begin prev<=ir_signal_in;ir_output_valid<=0;ir_function_code_out<=0;ir_device_address_out<=0;
case(state)
0:if(ir_signal_in)begin ticks<=1;state<=1;end
1:if(ir_signal_in)ticks<=ticks+1;else begin if(ticks>=23&&ticks<=25)begin state<=2;bits<=0;ticks<=1;frame<=0;end else state<=0;end
2:begin if(ir_signal_in==prev)ticks<=ticks+1;else begin ticks<=1;if(prev)begin if((ticks>=5&&ticks<=7)||(ticks>=11&&ticks<=13))begin frame[bits]<=ticks>=10;bits<=bits+1;if(bits==11)begin state<=3;delay_count<=0;end end else state<=0;end else if(ticks<5||ticks>7)state<=0;end if(ticks>30)state<=0;end
3:if(delay_count==2)begin ir_output_valid<=1;ir_device_address_out<=frame[11:7]<5?(5'b1<<frame[11:7]):0;
case(frame[6:0])0,1,2,3,4,5,6,7,8:ir_function_code_out<=frame[6:0]+1;9:ir_function_code_out<=0;16:ir_function_code_out<=31;17:ir_function_code_out<=47;18:ir_function_code_out<=63;19:ir_function_code_out<=79;20:ir_function_code_out<=95;21:ir_function_code_out<=111;22:ir_function_code_out<=127;default:ir_output_valid<=0;endcase
state<=4;ticks<=0;end else delay_count<=delay_count+1;
4:if(ticks>=449)begin state<=0;ticks<=0;end else ticks<=ticks+1;
default:state<=0;endcase end endmodule
