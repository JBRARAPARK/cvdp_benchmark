"""Independent, bounded checks of disputed requirements; these are NOT official passes."""
import json,subprocess
from pathlib import Path
BASE=Path(__file__).resolve().parent;SOL=BASE.parent
cases={}
cases['decimator_msb_example']=('configurable_digital_low_pass_filter_0004',r'''
reg clk=0,reset=1,valid_in=0;always #5 clk=~clk;reg [127:0] data_in;wire valid_out;wire [31:0] data_out;wire [15:0] peak_value;
advanced_decimator_with_adaptive_peak_detection dut(.*);
initial begin #12;reset=0;data_in={16'd10,16'd20,16'd30,16'd40,16'd50,16'd60,16'd70,16'd80};valid_in=1;@(posedge clk);#1;
if(data_out!={16'd10,16'd50}||peak_value!=50||!valid_out)$fatal(1,"MSB example");
@(negedge clk);data_in={16'hfffa,16'd0,16'd0,16'd0,16'hfffe,16'd0,16'd0,16'd0};@(posedge clk);#1;if(peak_value!=16'hfffe)$fatal(1,"signed peak");$display("PASS");$finish;end
''')
cases['neuron_cascade_and_hold']=('neuromorphic_array_0001',r'''
reg clk=0,rst_n=0;always #5 clk=~clk;reg [7:0] ui_in=0,uio_in=0;wire [7:0] uo_out;reg [7:0] expected[0:3];integer i,n;
neuromorphic_array #(.NEURONS(4)) dut(.*);
initial begin for(i=0;i<4;i=i+1)expected[i]=0;#12;rst_n=1;
for(n=0;n<40;n=n+1)begin @(negedge clk);ui_in=n%3!=0;uio_in=n*7;@(posedge clk);if(ui_in[0])begin for(i=3;i>0;i=i-1)expected[i]=expected[i-1];expected[0]=uio_in;end #1;if(uo_out!==expected[3])$fatal(1,"cascade/hold");end $display("PASS");$finish;end
''')
cases['crc_reference']=('serial_in_parallel_out_0014',r'''
reg clk=0,rst=0;always #5 clk=~clk;reg [15:0] data_in=0;wire [7:0] crc_out;reg [7:0] refcrc;integer i,n;
crc_generator #(.DATA_WIDTH(16),.CRC_WIDTH(8),.POLY(8'h07)) dut(.*);
initial begin #12;rst=1;for(n=0;n<100;n=n+1)begin @(negedge clk);data_in=$random;refcrc=0;for(i=15;i>=0;i=i-1)begin if(refcrc[7]^data_in[i])refcrc=(refcrc<<1)^8'h07;else refcrc=refcrc<<1;end @(posedge clk);#1;if(crc_out!==refcrc)$fatal(1,"CRC recurrence");end $display("PASS");$finish;end
''')
cases['jitter_tolerance_and_pulse']=('clock_jitter_detection_module_0003',r'''
reg clk=0,rst=1,system_clk=0;always #5 clk=~clk;wire jitter_detected;
clock_jitter_detection_module dut(.*);
task tick(input v,input e);begin @(negedge clk);system_clk=v;@(posedge clk);#1;if(jitter_detected!==e)$fatal(1,"jitter expected %d got %d",e,jitter_detected);end endtask
integer i;initial begin #12;rst=0;tick(1,0);for(i=0;i<4;i=i+1)tick(0,0);tick(1,0);for(i=0;i<5;i=i+1)tick(0,0);tick(1,0);for(i=0;i<7;i=i+1)tick(0,0);tick(1,1);tick(0,0);$display("PASS");$finish;end
''')
cases['wishbone_cdc_endian_wait']=('wb2ahb_0001',r'''
reg clk_i=0,hclk=0;always #5 clk_i=~clk_i;always #7 hclk=~hclk;
reg rst_i=0,hreset_n=0,cyc_i=0,stb_i=0,we_i=0,hready=0;reg [3:0] sel_i=15;reg [31:0] addr_i=0,data_i=0,hrdata=32'h78563412;reg [1:0] hresp=0;
wire [31:0] data_o,haddr,hwdata;wire ack_o,hwrite;wire [1:0] htrans;wire [2:0] hsize,hburst;
wishbone_to_ahb_bridge dut(.*);
initial begin #21;rst_i=1;hreset_n=1;@(negedge clk_i);cyc_i=1;stb_i=1;we_i=1;addr_i=32'h1000;data_i=32'h12345678;
wait(htrans==2);#1;if(hwdata!=32'h78563412||haddr!=32'h1000||!hwrite)$fatal(1,"write phase");repeat(3)begin @(posedge hclk);#1;if(ack_o||htrans!=2)$fatal(1,"wait state");end @(negedge hclk);hready=1;wait(ack_o);#1;if(data_o!=32'h12345678)$fatal(1,"read endian");@(negedge clk_i);cyc_i=0;stb_i=0;$display("PASS");$finish;end
''')

cases['ping_pong_capacity_order_reset']=('ping_pong_buffer_0001',r"""
reg clk=0,rst_n=0,write_enable=0,read_enable=0;reg [7:0] data_in=0;wire [7:0] data_out;wire buffer_full,buffer_empty,buffer_select;always #5 clk=~clk;integer i,b;
ping_pong_buffer dut(.*);
initial begin #12;rst_n=1;
for(b=0;b<2;b=b+1)begin
for(i=0;i<256;i=i+1)begin @(negedge clk);write_enable=1;data_in=i^8'hac;end
@(negedge clk);write_enable=0;if(!buffer_full)$fatal(1,"capacity");
for(i=0;i<256;i=i+1)begin read_enable=1;@(posedge clk);#1;if(data_out!==(i^8'hac))$fatal(1,"FIFO ordering %d",i);@(negedge clk);end
read_enable=0;if(!buffer_empty||buffer_select!==(b==0))$fatal(1,"bank switch");end
write_enable=0;read_enable=0;rst_n=0;#1;if(!buffer_empty||buffer_full||buffer_select)$fatal(1,"asynchronous reset");
#9;rst_n=1;repeat(2)@(posedge clk);#1;if(!buffer_empty)$fatal(1,"quiescent reset");$display("PASS");$finish;end
""")
cases['microcode_pop_three_cycles']=('microcode_sequencer_0001',r"""
reg clk=0,c_n_in=0,c_inc_in=0,r_en=0,cc=0,ien=0,oen=0;reg [3:0] d_in=0;reg [4:0] instr_in=0;wire [3:0] d_out;wire c_n_out,c_inc_out,full,empty;always #5 clk=~clk;
microcode_sequencer dut(.*);reg [3:0] saved;
initial begin repeat(2)@(negedge clk);instr_in=1;c_inc_in=1;repeat(6)@(negedge clk);saved=d_out;c_inc_in=0;instr_in=11;@(negedge clk);instr_in=1;@(negedge clk);instr_in=14;repeat(3)@(negedge clk);if(d_out!==saved)$fatal(1,"POP result expected %d got %d",saved,d_out);$display("PASS");$finish;end
""")
results=[]
for name,(key,body) in cases.items():
 tb=BASE/(name+'.sv');tb.write_text('module tb;\n'+body+'\ninitial begin #100000;$fatal(1,"timeout");end\nendmodule\n')
 exe=BASE/(name+'.vvp');rtl=SOL/({'ping_pong_buffer_0001':'revised_r5','microcode_sequencer_0001':'revised_r5'}.get(key,'first'))/('cvdp_copilot_'+key+'.sv')
 extras=[]
 if key=='ping_pong_buffer_0001':
  rows=[json.loads(x) for x in (SOL.parents[1]/'selections/next_50/input_only.jsonl').read_text().splitlines()]
  mem=next(r for r in rows if r['id']=='cvdp_copilot_'+key)['input']['context']['rtl/dual_port_memory.sv'];mp=BASE/'dual_port_memory.sv';mp.write_text(mem);extras=[str(mp)]
 a=subprocess.run(['iverilog','-g2012','-s','tb','-o',str(exe),str(rtl),str(tb)]+extras,capture_output=True,text=True,timeout=20)
 b=subprocess.run(['vvp',str(exe)],capture_output=True,text=True,timeout=20) if a.returncode==0 else a
 results.append({'check':name,'id':'cvdp_copilot_'+key,'rtl':str(rtl),'passed':b.returncode==0,'output':b.stdout+b.stderr})
 (BASE/(name+'.log')).write_text(a.stdout+a.stderr+b.stdout+b.stderr)
 print(name,'PASS' if b.returncode==0 else 'FAIL',b.stdout[:150])
 if exe.exists():exe.unlink()
(BASE/'results.json').write_text(json.dumps(results,indent=2))
