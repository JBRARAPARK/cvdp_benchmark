module spi_fsm(input i_clk,i_rst_b,input [15:0] i_data_in,input i_enable,i_fault,i_clear,output reg o_spi_cs_b,o_spi_clk,o_spi_data,output reg [4:0] o_bits_left,output reg o_done,output reg [1:0] o_fsm_state);
reg [15:0] data_q;
always @(posedge i_clk or negedge i_rst_b)begin
 if(!i_rst_b)begin o_fsm_state<=0;o_spi_cs_b<=1;o_spi_clk<=0;o_spi_data<=0;o_bits_left<=16;o_done<=0;data_q<=0;end
 else begin
 o_done<=0;
 if(i_clear || !i_enable)begin o_fsm_state<=0;o_spi_cs_b<=1;o_spi_clk<=0;o_spi_data<=0;o_bits_left<=16;end
 else if(i_fault || o_fsm_state==3)begin o_done<=o_fsm_state!=3;o_fsm_state<=3;o_spi_cs_b<=1;o_spi_clk<=0;o_spi_data<=0;o_bits_left<=16;end
 else case(o_fsm_state)
 0:begin data_q<=i_data_in;o_bits_left<=16;o_spi_cs_b<=0;o_spi_clk<=0;o_spi_data<=0;o_fsm_state<=1;end
 1:begin o_spi_cs_b<=0;o_spi_clk<=0;o_spi_data<=data_q[15];o_fsm_state<=2;end
 2:begin o_spi_clk<=1;data_q<=data_q<<1;o_bits_left<=o_bits_left-1'b1;
 if(o_bits_left==1)begin o_done<=1;o_fsm_state<=0;end else o_fsm_state<=1;end
 default:o_fsm_state<=0;
 endcase
 end
end
endmodule
