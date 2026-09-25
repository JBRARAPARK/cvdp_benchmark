module tb;

reg clk=0,c_n_in=0,c_inc_in=0,r_en=0,cc=0,ien=0,oen=0;reg [3:0] d_in=0;reg [4:0] instr_in=0;wire [3:0] d_out;wire c_n_out,c_inc_out,full,empty;always #5 clk=~clk;
microcode_sequencer dut(.*);reg [3:0] saved;
initial begin repeat(2)@(negedge clk);instr_in=1;c_inc_in=1;repeat(6)@(negedge clk);saved=d_out;c_inc_in=0;instr_in=11;@(negedge clk);instr_in=1;@(negedge clk);instr_in=14;repeat(3)@(negedge clk);if(d_out!==saved)$fatal(1,"POP result expected %d got %d",saved,d_out);$display("PASS");$finish;end

initial begin #100000;$fatal(1,"timeout");end
endmodule
