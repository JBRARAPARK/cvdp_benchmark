module glitch_free_mux(input clk1,clk2,rst_n,sel,output clkout);
reg e1a,e1b,e2a,e2b;
always @(posedge clk1 or negedge rst_n)
 if(!rst_n)begin e1a<=0;e1b<=0;end
 else begin e1a<=~sel & ~e2b;e1b<=e1a;end
always @(posedge clk2 or negedge rst_n)
 if(!rst_n)begin e2a<=0;e2b<=0;end
 else begin e2a<=sel & ~e1b;e2b<=e2a;end
assign clkout=(clk1 & e1b)|(clk2 & e2b);
endmodule
