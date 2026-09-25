module lru_counter_policy #(parameter NWAYS=4,NINDEXES=32)(input clock,reset,input [$clog2(NINDEXES)-1:0] index,input [$clog2(NWAYS)-1:0] way_select,input access,hit,output reg [$clog2(NWAYS)-1:0] way_replace);
localparam W=$clog2(NWAYS);reg [NWAYS*W-1:0] recency[0:NINDEXES-1];integer i,n;
wire [W-1:0] selected=hit?way_select:way_replace;
// Replacement: rank zero is least recently used.
always @*begin way_replace=0;for(integer j=0;j<NWAYS;j=j+1)if(recency[index][j*W+:W]==0)way_replace=j;end
// Recency update preserves unique ranks.
always @(posedge clock or posedge reset)if(reset)begin for(i=0;i<NINDEXES;i=i+1)for(n=0;n<NWAYS;n=n+1)recency[i][n*W+:W]<=n;end
else if(access)for(n=0;n<NWAYS;n=n+1)begin if(n==selected)recency[index][n*W+:W]<=NWAYS-1;else if(recency[index][n*W+:W]>recency[index][selected*W+:W])recency[index][n*W+:W]<=recency[index][n*W+:W]-1'b1;end endmodule
