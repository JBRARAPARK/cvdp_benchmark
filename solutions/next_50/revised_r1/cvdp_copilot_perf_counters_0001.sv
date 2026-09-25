module cvdp_copilot_perf_counters #(parameter CNT_W=32)(input clk,reset,sw_req_i,cpu_trig_i,output [CNT_W-1:0] p_count_o);
reg [CNT_W-1:0] count_q;assign p_count_o=sw_req_i?count_q:0;
always @(posedge clk or posedge reset)if(reset)count_q<=0;else if(sw_req_i)count_q<=cpu_trig_i;else if(cpu_trig_i)count_q<=count_q+1'b1;endmodule
