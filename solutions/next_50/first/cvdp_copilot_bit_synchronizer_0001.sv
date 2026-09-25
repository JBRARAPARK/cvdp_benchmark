module bit_sync #(parameter STAGES=2)(input aclk,bclk,rst_n,adata,output aq2_data,bq2_data);
(* ASYNC_REG="TRUE" *)reg [STAGES-1:0] a_sync_chain,b_sync_chain;
always @(posedge bclk or negedge rst_n)if(!rst_n)b_sync_chain<=0;else b_sync_chain<={b_sync_chain[STAGES-2:0],adata};
always @(posedge aclk or negedge rst_n)if(!rst_n)a_sync_chain<=0;else a_sync_chain<={a_sync_chain[STAGES-2:0],bq2_data};
assign aq2_data=a_sync_chain[STAGES-1];assign bq2_data=b_sync_chain[STAGES-1];endmodule
