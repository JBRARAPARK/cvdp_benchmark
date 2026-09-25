module thermostat(input i_clk,i_rst,input [5:0] i_temp_feedback,input i_fan_on,i_enable,i_fault,i_clr,output reg o_heater_full,o_heater_medium,o_heater_low,o_aircon_full,o_aircon_medium,o_aircon_low,o_fan,output reg [2:0] state);
reg fault_latched;reg [2:0] target;
always @*begin target=3;if(i_temp_feedback[5])target=2;else if(i_temp_feedback[4])target=1;else if(i_temp_feedback[3])target=0;else if(i_temp_feedback[0])target=6;else if(i_temp_feedback[1])target=5;else if(i_temp_feedback[2])target=4;end
always @(posedge i_clk or negedge i_rst)if(!i_rst)begin state<=3;fault_latched<=0;o_heater_full<=0;o_heater_medium<=0;o_heater_low<=0;o_aircon_full<=0;o_aircon_medium<=0;o_aircon_low<=0;o_fan<=0;end else begin
if(i_fault)fault_latched<=1;else if(i_clr)fault_latched<=0;
state<=3;o_heater_full<=0;o_heater_medium<=0;o_heater_low<=0;o_aircon_full<=0;o_aircon_medium<=0;o_aircon_low<=0;o_fan<=0;
if(i_enable&&!i_fault&&!fault_latched&&!i_clr)begin state<=target;o_heater_full<=target==2;o_heater_medium<=target==1;o_heater_low<=target==0;o_aircon_full<=target==6;o_aircon_medium<=target==5;o_aircon_low<=target==4;o_fan<=i_fan_on||(target!=3);end end endmodule
