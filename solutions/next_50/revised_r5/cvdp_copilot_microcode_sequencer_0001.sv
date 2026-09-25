module microcode_sequencer(input clk,c_n_in,c_inc_in,r_en,cc,ien,input [3:0] d_in,input [4:0] instr_in,input oen,output [3:0] d_out,output c_n_out,c_inc_out,full,empty);
reg [3:0] pc,aux,stack[0:15],popped,pop_delay;reg [4:0] count;reg [4:0] sum;wire enabled=!ien&&!cc;
assign full=count==16;assign empty=count==0;assign d_out=oen?4'bz:sum[3:0];assign c_n_out=sum[4];wire [4:0] pc_next={1'b0,pc}+c_inc_in;assign c_inc_out=pc_next[4];
always @*begin sum=0;if(enabled)case(instr_in)
0:sum=0;1:sum={1'b0,pc};2:sum={1'b0,aux};3:sum={1'b0,d_in};4:sum={1'b0,aux}+d_in+c_n_in;11:sum={1'b0,pc};14:sum={1'b0,pop_delay};default:sum=0;endcase end
always @(posedge clk)begin
if(!r_en)aux<=d_in;
if(enabled)begin case(instr_in)
0:begin pc<={3'b0,c_inc_in};count<=0;popped<=0;pop_delay<=0;end
11:begin if(!full)begin stack[count]<=pc;count<=count+1'b1;end pc<=pc_next[3:0];end
14:begin popped<=stack[empty?0:count-1];if(!empty)count<=count-1'b1; pop_delay<=popped;pc<=pop_delay;end
default:pc<=pc_next[3:0];endcase end end endmodule
