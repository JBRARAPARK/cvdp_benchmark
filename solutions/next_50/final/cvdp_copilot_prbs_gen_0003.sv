module cvdp_prbs_gen #(parameter CHECK_MODE=0,POLY_LENGTH=31,POLY_TAP=3,WIDTH=16)(input clk,rst,input [WIDTH-1:0] data_in,output reg [WIDTH-1:0] data_out);
reg [POLY_LENGTH-1:0] state,next_state;reg [WIDTH-1:0] value;reg bit_value;integer i;
always @*begin next_state=state;value=0;bit_value=0;for(i=0;i<WIDTH;i=i+1)begin bit_value=next_state[0]^next_state[POLY_LENGTH-POLY_TAP];value[i]=CHECK_MODE?(bit_value^data_in[i]):bit_value;next_state={CHECK_MODE?data_in[i]:bit_value,next_state[POLY_LENGTH-1:1]};end end
always @(posedge clk)if(rst)begin state<={POLY_LENGTH{1'b1}};data_out<={WIDTH{1'b1}};end else begin state<=next_state;data_out<=value;end endmodule
