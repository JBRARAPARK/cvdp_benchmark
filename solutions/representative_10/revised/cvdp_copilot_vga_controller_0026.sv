module vga_controller (
    input logic clock,      // 25 MHz
    input logic reset,      // Active high
    input logic [7:0] color_in, // Pixel color data (RRRGGGBB)
    output logic [9:0] next_x,  // x-coordinate of NEXT pixel that will be drawn
    output logic [9:0] next_y,  // y-coordinate of NEXT pixel that will be drawn
    output logic hsync,     // HSYNC (to VGA connector)
    output logic vsync,     // VSYNC (to VGA connector)
    output logic [7:0] red, // RED (to resistor DAC VGA connector)
    output logic [7:0] green, // GREEN (to resistor DAC to VGA connector)
    output logic [7:0] blue, // BLUE (to resistor DAC to VGA connector)
    output logic sync,      // SYNC to VGA connector
    output logic clk,       // CLK to VGA connector
    output logic blank,     // BLANK to VGA connector
    output logic [7:0] h_state, // States of Horizontal FSM
    output logic [7:0] v_state  // States of Vertical FSM
);

    parameter logic [9:0] H_ACTIVE  =  10'd640;
    parameter logic [9:0] H_FRONT   =  10'd16;
    parameter logic [9:0] H_PULSE   =  10'd96;
    parameter logic [9:0] H_BACK    =  10'd48;
    parameter logic [9:0] V_ACTIVE  =  10'd480;
    parameter logic [9:0] V_FRONT   =  10'd10;
    parameter logic [9:0] V_PULSE   =  10'd2;
    parameter logic [9:0] V_BACK    =  10'd33;
    parameter logic LOW   = 1'b0;
    parameter logic HIGH  = 1'b1;
    parameter logic [7:0] H_ACTIVE_STATE  = 8'd0;
    parameter logic [7:0] H_FRONT_STATE   = 8'd1;
    parameter logic [7:0] H_PULSE_STATE   = 8'd2;
    parameter logic [7:0] H_BACK_STATE    = 8'd3;
    parameter logic [7:0] V_ACTIVE_STATE  = 8'd0;
    parameter logic [7:0] V_FRONT_STATE   = 8'd1;
    parameter logic [7:0] V_PULSE_STATE   = 8'd2;
    parameter logic [7:0] V_BACK_STATE    = 8'd3;

    
    logic line_done;
    logic [9:0] h_counter;
    logic [9:0] v_counter;
    


logic [9:0] h_limit,v_limit;
logic h_known,v_known,h_last,v_last;
always_comb begin
 h_limit=0;v_limit=0;h_known=1;v_known=1;
 case(h_state)
 H_ACTIVE_STATE:h_limit=H_ACTIVE-10'd1;
 H_FRONT_STATE:h_limit=H_FRONT-10'd1;
 H_PULSE_STATE:h_limit=H_PULSE-10'd1;
 H_BACK_STATE:h_limit=H_BACK-10'd1;
 default:h_known=0;
 endcase
 case(v_state)
 V_ACTIVE_STATE:v_limit=V_ACTIVE-10'd1;
 V_FRONT_STATE:v_limit=V_FRONT-10'd1;
 V_PULSE_STATE:v_limit=V_PULSE-10'd1;
 V_BACK_STATE:v_limit=V_BACK-10'd1;
 default:v_known=0;
 endcase
end
assign h_last=h_counter==h_limit;
assign v_last=v_counter==v_limit;
always_ff @(posedge clock or posedge reset)begin
 if(reset)begin h_counter<=0;v_counter<=0;h_state<=H_ACTIVE_STATE;v_state<=V_ACTIVE_STATE;line_done<=LOW;end
 else begin
 if(h_known)begin
 h_counter<=h_last ? 10'd0 : h_counter+10'd1;
 hsync<=(h_state==H_PULSE_STATE)?LOW:HIGH;
 case(h_state)
 H_ACTIVE_STATE:begin line_done<=LOW;if(h_last)h_state<=H_FRONT_STATE;end
 H_FRONT_STATE:if(h_last)h_state<=H_PULSE_STATE;
 H_PULSE_STATE:if(h_last)h_state<=H_BACK_STATE;
 H_BACK_STATE:begin line_done<=h_last?HIGH:LOW;if(h_last)h_state<=H_ACTIVE_STATE;end
 endcase
 end
 if(v_known)begin
 vsync<=(v_state==V_PULSE_STATE)?LOW:HIGH;
 if(line_done==HIGH)begin
 v_counter<=v_last ? 10'd0 : v_counter+10'd1;
 if(v_last)case(v_state)
 V_ACTIVE_STATE:v_state<=V_FRONT_STATE;
 V_FRONT_STATE:v_state<=V_PULSE_STATE;
 V_PULSE_STATE:v_state<=V_BACK_STATE;
 V_BACK_STATE:v_state<=V_ACTIVE_STATE;
 endcase
 end
 end
 if(h_state==H_ACTIVE_STATE && v_state==V_ACTIVE_STATE)begin
 red<={color_in[7:5],5'd0};green<={color_in[4:2],5'd0};blue<={color_in[1:0],6'd0};end
 else begin red<=0;green<=0;blue<=0;end
 end
end

    assign clk = clock;
    assign sync = 1'b0;
    assign blank = hsync & vsync;

    assign next_x = (h_state == H_ACTIVE_STATE) ? h_counter : 10'd0;
    assign next_y = (v_state == V_ACTIVE_STATE) ? v_counter : 10'd0;

endmodule