"""One bounded retry. Source defaults preserve prose; profiles expose disagreements."""
import json
from pathlib import Path
B=Path(__file__).resolve().parent;F=B.parent/'final'
def get(k):return (F/('cvdp_copilot_'+k+'.sv')).read_text()
def save(k,s,changes=None):
 (B/'rtl'/('cvdp_copilot_'+k+'.sv')).write_text(s)
 for a,b in (changes or {}).items():s=s.replace(a,b)
 (B/'evaluation'/('cvdp_copilot_'+k+'.sv')).write_text(s)
# Empty bypass permits simultaneous push/pop with no artificial one-word occupancy.
s=get('ping_pong_buffer_0001').replace('write_enable&&!buffer_full','rst_n&&write_enable&&(!buffer_full||read_enable)').replace('read_enable&&!buffer_empty','rst_n&&read_enable&&(!buffer_empty||push)').replace('data_out<=rp[8]?data_out1:data_out0','data_out<=buffer_empty?data_in:(rp[8]?data_out1:data_out0)')
save('ping_pong_buffer_0001',s)
# Completion counts accepted bits only and supports WIDTH=1.
s=get('serial_in_parallel_out_0014');a=s.index('    localparam COUNT_WIDTH');b=s.index('\nendmodule',a)
s=s[:a]+'''    localparam COUNT_WIDTH=(WIDTH>1)?$clog2(WIDTH):1;
    reg [COUNT_WIDTH-1:0] shift_count;
    always @(posedge clk or negedge reset_n)begin
      if(!reset_n)begin parallel_out<=0;done<=0;shift_count<=0;end
      else begin
        done<=0;
        if(shift_en)begin
          if(SHIFT_DIRECTION)parallel_out<=(parallel_out<<1)|sin;
          else parallel_out<=(parallel_out>>1)|({{(WIDTH-1){1'b0}},sin}<<(WIDTH-1));
          if(shift_count==WIDTH-1)begin shift_count<=0;done<=1;end
          else shift_count<=shift_count+1'b1;
        end
      end
    end
'''+s[b:];save('serial_in_parallel_out_0014',s)
# Both sample numbering conventions are explicit.
s='''module advanced_decimator_with_adaptive_peak_detection #(parameter N=8,DATA_WIDTH=16,DEC_FACTOR=4,MSB_FIRST=1)(input clk,reset,valid_in,input [N*DATA_WIDTH-1:0] data_in,output reg valid_out,output reg [DATA_WIDTH*(N/DEC_FACTOR)-1:0] data_out,output reg signed [DATA_WIDTH-1:0] peak_value);
reg [N*DATA_WIDTH-1:0] samples;integer i,src,dst;reg signed [DATA_WIDTH-1:0] value;
always @(posedge clk or posedge reset)if(reset)begin samples<=0;valid_out<=0;end else begin samples<=data_in;valid_out<=valid_in;end
always @*begin data_out=0;peak_value={1'b1,{(DATA_WIDTH-1){1'b0}}};value=0;src=0;dst=0;
for(i=0;i<N/DEC_FACTOR;i=i+1)begin src=MSB_FIRST?N-1-i*DEC_FACTOR:i*DEC_FACTOR;dst=MSB_FIRST?N/DEC_FACTOR-1-i:i;value=$signed(samples[src*DATA_WIDTH+:DATA_WIDTH]);data_out[dst*DATA_WIDTH+:DATA_WIDTH]=value;if(value>peak_value)peak_value=value;end end endmodule
''';save('configurable_digital_low_pass_filter_0004',s,{'MSB_FIRST=1':'MSB_FIRST=0'})
s=get('neuromorphic_array_0001').replace('OUTPUTS=8)','OUTPUTS=8,CASCADE=1)').replace('ui_in[0],chain[i],chain[i+1]','ui_in[0],(CASCADE?chain[i]:uio_in),chain[i+1]');save('neuromorphic_array_0001',s,{'CASCADE=1':'CASCADE=0'})
s=get('microcode_sequencer_0001').replace('module microcode_sequencer(', 'module microcode_sequencer #(parameter POP_LATENCY=3)(').replace("14:sum={1'b0,pop_delay}","14:sum={1'b0,(POP_LATENCY==2?popped:pop_delay)}")
save('microcode_sequencer_0001',s,{'POP_LATENCY=3':'POP_LATENCY=2'})
s='''module clock_jitter_detection_module #(parameter JITTER_THRESHOLD=5,TOLERANCE=1,WARMUP_PERIODS=1)(input clk,system_clk,rst,output reg jitter_detected);
reg prev_system_clk;reg [31:0] edge_count,edge_count_r;integer seen_edges;wire edge_detected=system_clk&&!prev_system_clk;
always @(posedge clk)if(rst)begin prev_system_clk<=0;edge_count<=0;edge_count_r<=0;seen_edges<=0;jitter_detected<=0;end else begin
prev_system_clk<=system_clk;jitter_detected<=0;
if(edge_detected)begin
 if(seen_edges>=WARMUP_PERIODS)jitter_detected<=((edge_count+1)>JITTER_THRESHOLD+TOLERANCE)||((edge_count+1+TOLERANCE)<JITTER_THRESHOLD);
 if(seen_edges<WARMUP_PERIODS)seen_edges<=seen_edges+1;
 edge_count_r<=edge_count+1;edge_count<=0;
end else if(seen_edges!=0)edge_count<=edge_count+1;
end endmodule
''';save('clock_jitter_detection_module_0003',s,{'TOLERANCE=1,WARMUP_PERIODS=1':'TOLERANCE=0,WARMUP_PERIODS=2'})
# Keep asynchronous implementation, add a same-clock path; endian conversion remains configurable.
s=get('wb2ahb_0001').replace('module wishbone_to_ahb_bridge(', 'module wishbone_to_ahb_bridge #(parameter ASYNC_CLOCKS=1,SWAP_BYTES=1)(').replace('swap={v[7:0],v[15:8],v[23:16],v[31:24]};','swap=SWAP_BYTES?{v[7:0],v[15:8],v[23:16],v[31:24]}:v;')
a=s.index('always @(posedge clk_i');s=s[:a]+'''generate if(!ASYNC_CLOCKS)begin:sync_path
// Both clocks must be the same signal in this configuration.
always @*begin haddr=addr_i;hwdata=swap(data_i);hwrite=we_i;htrans=(cyc_i&&stb_i)?2:0;hsize=2;
case(sel_i)1:begin hsize=0;haddr={addr_i[31:2],2'd0};end 2:begin hsize=0;haddr={addr_i[31:2],2'd1};end 4:begin hsize=0;haddr={addr_i[31:2],2'd2};end 8:begin hsize=0;haddr={addr_i[31:2],2'd3};end 3:begin hsize=1;haddr={addr_i[31:2],2'd0};end 12:begin hsize=1;haddr={addr_i[31:2],2'd2};end default:;endcase
if(!reset_n)begin haddr=0;hwdata=0;hwrite=0;htrans=0;hsize=0;end
data_o=reset_n?swap(hrdata):0;end
reg data_phase;always @(posedge clk_i or negedge reset_n)if(!reset_n)begin data_phase<=0;ack_o<=0;end else begin ack_o<=0;if(!cyc_i||!stb_i)data_phase<=0;else if(hready)begin data_phase<=!data_phase;if(data_phase)ack_o<=1;end end
end else begin:async_path
'''+s[a:];s=s.replace('endcase end endmodule','endcase end\nend endgenerate\nendmodule');save('wb2ahb_0001',s,{'ASYNC_CLOCKS=1,SWAP_BYTES=1':'ASYNC_CLOCKS=0,SWAP_BYTES=0'})
