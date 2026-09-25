module intra_block #(parameter ROW_COL_WIDTH=16,DATA_WIDTH=ROW_COL_WIDTH*ROW_COL_WIDTH)(input [DATA_WIDTH-1:0] in_data,output [DATA_WIDTH-1:0] out_data);
// Target: at least 66% fewer reported wires; replace variable indexing with fixed wiring.
genvar i;generate for(i=0;i<256;i=i+1)begin: permute
 localparam integer OFFSET=(i<128)?0:1;
 localparam integer ROW=(i-2*(i/16)-OFFSET)&15;
 localparam integer COL=(i-(i/16)-OFFSET)&15;
 assign out_data[i]=in_data[ROW*16+COL];
end endgenerate
endmodule
