module pseudo_lru_tree_policy #(parameter NWAYS=4,NINDEXES=32)(input clock,reset,input [$clog2(NINDEXES)-1:0] index,input [$clog2(NWAYS)-1:0] way_select,input access,hit,output [$clog2(NWAYS)-1:0] way_replace);
reg [NWAYS-2:0] recency[0:NINDEXES-1];reg [NWAYS-2:0] updated;
wire [$clog2(NWAYS)-1:0] used_way=hit?way_select:way_replace;
integer node,depth,i;
slot_select_pseudo_lru_tree #(.NWAYS(NWAYS)) choose(recency[index],way_replace);
always @*begin updated=recency[index];node=0;
 for(depth=$clog2(NWAYS)-1;depth>=0;depth=depth-1)begin
 updated[node]=used_way[depth];node=2*node+1+used_way[depth];end
end
always @(posedge clock or posedge reset)if(reset)begin for(i=0;i<NINDEXES;i=i+1)recency[i]<=0;end else if(access)recency[index]<=updated;
endmodule
module slot_select_pseudo_lru_tree #(parameter NWAYS=4)(input [NWAYS-2:0] array,output reg [$clog2(NWAYS)-1:0] index);
integer node,depth;
always @*begin node=0;index=0;for(depth=$clog2(NWAYS)-1;depth>=0;depth=depth-1)begin index[depth]=~array[node];node=2*node+1+(!array[node]);end end
endmodule
