module clock_jitter_detection_module #(parameter JITTER_THRESHOLD=5,TOLERANCE=0,WARMUP_PERIODS=2)(input clk,system_clk,rst,output reg jitter_detected);
reg prev_system_clk;reg [31:0] edge_count,edge_count_r;integer seen_edges;wire edge_detected=system_clk&&!prev_system_clk;
always @(posedge clk)if(rst)begin prev_system_clk<=0;edge_count<=0;edge_count_r<=0;seen_edges<=0;jitter_detected<=0;end else begin
prev_system_clk<=system_clk;jitter_detected<=0;
if(edge_detected)begin
 if(seen_edges>=WARMUP_PERIODS)jitter_detected<=((edge_count+1)>JITTER_THRESHOLD+TOLERANCE)||((edge_count+1+TOLERANCE)<JITTER_THRESHOLD);
 if(seen_edges<WARMUP_PERIODS)seen_edges<=seen_edges+1;
 edge_count_r<=edge_count+1;edge_count<=0;
end else if(seen_edges!=0)edge_count<=edge_count+1;
end endmodule
