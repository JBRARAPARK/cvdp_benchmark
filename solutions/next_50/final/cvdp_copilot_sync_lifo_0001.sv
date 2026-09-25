module sync_lifo #(parameter DATA_WIDTH=8,ADDR_WIDTH=3)(input clock,reset,write_en,read_en,input [DATA_WIDTH-1:0] data_in,output empty,full,output reg [DATA_WIDTH-1:0] data_out);
localparam DEPTH=1<<ADDR_WIDTH;reg [DATA_WIDTH-1:0] mem[0:DEPTH-1];reg [ADDR_WIDTH:0] count;integer i;
assign empty=count==0;assign full=count==DEPTH;
always @(posedge clock)if(reset)begin count<=0;data_out<=0;for(i=0;i<DEPTH;i=i+1)mem[i]<=0;end
else if(write_en&&!full)begin mem[count]<=data_in;count<=count+1'b1;end
else if(read_en&&!empty)begin data_out<=mem[count-1];count<=count-1'b1;end endmodule
