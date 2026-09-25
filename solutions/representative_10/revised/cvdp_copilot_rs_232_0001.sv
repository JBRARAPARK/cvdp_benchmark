module copilot_rs_232 #(parameter HIGH=1'b1,LOW=1'b0,CLOCK_FREQ=100000000,BAUD_RATE=115200,REG_INPUT=1,BAUD_ACC_WIDTH=16)(
input clock,reset_neg,tx_datain_ready,Present_Processing_Completed,input [7:0] tx_datain,
output reg tx_transmitter,output wire tx_transmitter_valid);
reg busy;
reg [3:0] bit_index;
reg [9:0] frame;
wire baud_pulse;
assign tx_transmitter_valid=busy;
baud_rate_generator #(.CLOCK_FREQ(CLOCK_FREQ),.BAUD_RATE(BAUD_RATE),.BAUD_ACC_WIDTH(BAUD_ACC_WIDTH)) gen_baud(
.clock(clock),.reset_neg(reset_neg),.enable(busy && !Present_Processing_Completed),.baud_pulse(baud_pulse));
always @(posedge clock or negedge reset_neg)begin
 if(!reset_neg)begin busy<=0;bit_index<=0;frame<=10'h3ff;tx_transmitter<=1;end
 else if(Present_Processing_Completed)tx_transmitter<=1;
 else if(!busy)begin
 tx_transmitter<=1;
 if(tx_datain_ready)begin frame<={1'b1,tx_datain,1'b0};bit_index<=0;busy<=1;tx_transmitter<=0;end
 end else begin
 tx_transmitter<=frame[bit_index];
 if(baud_pulse)begin
 if(bit_index==9)begin busy<=0;tx_transmitter<=1;end
 else begin bit_index<=bit_index+1'b1;tx_transmitter<=frame[bit_index+1'b1];end
 end
 end
end
endmodule
module baud_rate_generator #(parameter CLOCK_FREQ=100000000,BAUD_RATE=115200,BAUD_ACC_WIDTH=16)(
input clock,reset_neg,enable,output reg baud_pulse);
localparam [BAUD_ACC_WIDTH:0] INC=((BAUD_RATE << (BAUD_ACC_WIDTH-4))+(CLOCK_FREQ >> 5))/(CLOCK_FREQ >> 4);
reg [BAUD_ACC_WIDTH:0] acc;
always @(posedge clock or negedge reset_neg)begin
 if(!reset_neg)begin acc<=0;baud_pulse<=0;end
 else if(enable)begin acc<={1'b0,acc[BAUD_ACC_WIDTH-1:0]}+INC;baud_pulse<=acc[BAUD_ACC_WIDTH];end
 else begin acc<=0;baud_pulse<=0;end
end
endmodule
