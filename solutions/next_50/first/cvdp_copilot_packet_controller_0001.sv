module packet_controller(input clk,rst,rx_valid_i,input [7:0] rx_data_8_i,input tx_done_tick_i,output reg tx_start_o,output reg [7:0] tx_data_8_o);
reg [7:0] rx[0:7];reg [7:0] tx[0:4];reg [7:0] checksum;reg [15:0] result;reg [2:0] state;integer count,index,i;
always @(posedge clk or posedge rst)if(rst)begin state<=0;count<=0;index<=0;checksum<=0;result<=0;tx_start_o<=0;tx_data_8_o<=0;for(i=0;i<8;i=i+1)rx[i]<=0;for(i=0;i<5;i=i+1)tx[i]<=0;end
else case(state)
0:begin tx_start_o<=0;if(rx_valid_i)begin rx[count]<=rx_data_8_i;checksum<=checksum+rx_data_8_i;if(count==7)begin count<=0;state<=1;end else count<=count+1;end end
1:begin if({rx[0],rx[1]}==16'hbacd && checksum==0)begin case(rx[6])0:result<={rx[2],rx[3]}+{rx[4],rx[5]};1:result<={rx[2],rx[3]}-{rx[4],rx[5]};default:result<=0;endcase state<=2;end else state<=0;checksum<=0;end
2:begin tx[0]<=8'hab;tx[1]<=8'hcd;tx[2]<=result[15:8];tx[3]<=result[7:0];tx[4]<=-(8'hab+8'hcd+result[15:8]+result[7:0]);index<=0;state<=3;end
3:begin tx_data_8_o<=tx[index];tx_start_o<=1;state<=4;end
4:if(tx_done_tick_i)begin tx_start_o<=0;if(index==4)state<=0;else begin index<=index+1;state<=3;end end
default:state<=0;endcase endmodule
