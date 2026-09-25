module cvdp_copilot_apb_gpio #(parameter GPIO_WIDTH=8)(input pclk,preset_n,psel,input [7:2] paddr,input penable,pwrite,input [31:0] pwdata,input [GPIO_WIDTH-1:0] gpio_in,output reg [31:0] prdata,output pready,pslverr,output reg [GPIO_WIDTH-1:0] gpio_out,gpio_enable,output [GPIO_WIDTH-1:0] gpio_int,output comb_int);
reg [GPIO_WIDTH-1:0] sync1,sync2,old,ie,itype,polarity;
assign pready=1;assign pslverr=0;
reg [GPIO_WIDTH-1:0] pending_edges;
wire [GPIO_WIDTH-1:0] edges=ie & itype & ((~polarity & sync2 & ~old)|(polarity & ~sync2 & old));
wire [GPIO_WIDTH-1:0] clear_edges=(psel && penable && pwrite && paddr==6)?GPIO_WIDTH'(pwdata):'0;
always @(posedge pclk or negedge preset_n)
 if(!preset_n)pending_edges<=0;else pending_edges<=(pending_edges & ~clear_edges)|edges;
assign gpio_int=ie & ((itype & pending_edges)|(~itype & (sync2 ^ polarity)));
assign comb_int=|gpio_int;
always @(posedge pclk or negedge preset_n)begin
 if(!preset_n)begin gpio_out<=0;gpio_enable<=0;sync1<=0;sync2<=0;old<=0;ie<=0;itype<=0;polarity<=0;end
 else begin sync1<=gpio_in;sync2<=sync1;old<=sync2;
 if(psel && penable && pwrite)case(paddr)
 1:gpio_out<=GPIO_WIDTH'(pwdata);2:gpio_enable<=GPIO_WIDTH'(pwdata);3:ie<=GPIO_WIDTH'(pwdata);4:itype<=GPIO_WIDTH'(pwdata);5:polarity<=GPIO_WIDTH'(pwdata);
 endcase
 end
end
always @*begin
 prdata=0;if(psel && !pwrite)case(paddr)
 0:prdata=32'(sync2);1:prdata=32'(gpio_out);2:prdata=32'(gpio_enable);3:prdata=32'(ie);4:prdata=32'(itype);5:prdata=32'(polarity);6:prdata=32'(gpio_int);
 endcase
end
endmodule
