// Mode-0, MSB-first transmitter. Completion follows the final falling edge.
module spi_fsm(
 input wire i_clk,i_rst_b,input wire [15:0] i_data_in,
 input wire i_enable,i_fault,i_clear,
 output reg o_spi_cs_b,o_spi_clk,o_spi_data,
 output reg [4:0] o_bits_left,output reg o_done,
 output reg [1:0] o_fsm_state
);
 localparam IDLE=0,TRANSMIT=1,CLOCK_TOGGLE=2,ERROR=3;
 reg [15:0] data_q;
 always @(posedge i_clk or negedge i_rst_b) begin
  if(!i_rst_b) begin
   o_spi_cs_b<=1;o_spi_clk<=0;o_spi_data<=0;o_bits_left<=16;
   o_done<=0;o_fsm_state<=IDLE;data_q<=0;
  end else begin
   o_done<=0;
   if(i_clear || !i_enable) begin
    o_spi_cs_b<=1;o_spi_clk<=0;o_spi_data<=0;o_bits_left<=16;o_fsm_state<=IDLE;
   end else if(i_fault || o_fsm_state==ERROR) begin
    o_done<=o_fsm_state!=ERROR;
    o_spi_cs_b<=1;o_spi_clk<=0;o_spi_data<=0;o_bits_left<=16;o_fsm_state<=ERROR;
   end else case(o_fsm_state)
    IDLE:begin
     data_q<=i_data_in;o_spi_data<=i_data_in[15];
     o_spi_cs_b<=0;o_spi_clk<=0;o_bits_left<=16;o_fsm_state<=TRANSMIT;
    end
    TRANSMIT:begin
     // Data has been stable for a full system cycle before this sampling edge.
     o_bits_left<=o_bits_left-1'b1;o_spi_clk<=1;o_fsm_state<=CLOCK_TOGGLE;
    end
    CLOCK_TOGGLE:begin
     o_spi_clk<=0;
     if(o_bits_left==0)begin
      o_spi_cs_b<=1;o_spi_data<=0;o_done<=1;o_fsm_state<=IDLE;
     end else begin
      data_q<=data_q<<1;o_spi_data<=data_q[14];o_fsm_state<=TRANSMIT;
     end
    end
    default:begin o_spi_cs_b<=1;o_spi_clk<=0;o_spi_data<=0;o_bits_left<=16;o_fsm_state<=IDLE;end
   endcase
  end
 end
endmodule
