module round_robin_arbiter #(parameter N=4,TIMEOUT=16)(input clk,rstn,input [N-1:0] req,priority_level,output reg [N-1:0] grant,output idle);
integer pointer,next_pointer;reg [31:0] timeout_count[0:N-1];
wire [31:0] timeout_counter0=timeout_count[0],timeout_counter1=timeout_count[1],timeout_counter2=timeout_count[2],timeout_counter3=timeout_count[3];
reg [N-1:0] expired,eligible;reg found;integer i,idx;
assign idle=~|req;
always @*begin
 for(integer k=0;k<N;k=k+1)expired[k]=req[k] && timeout_count[k]>=TIMEOUT;
 eligible=(|expired)?expired:((|(req & priority_level))?(req & priority_level):req);
 grant=0;found=0;next_pointer=pointer;idx=0;
 for(i=0;i<N;i=i+1)begin idx=(pointer+i)%N;if(!found && eligible[idx])begin grant[idx]=1;next_pointer=(idx+1)%N;found=1;end end
end
always @(posedge clk or negedge rstn)begin
 if(!rstn)begin pointer<=0;for(integer k=0;k<N;k=k+1)timeout_count[k]<=0;end
 else begin pointer<=next_pointer;for(integer k=0;k<N;k=k+1)begin
 if(!req[k] || grant[k])timeout_count[k]<=0;else if(timeout_count[k]<TIMEOUT)timeout_count[k]<=timeout_count[k]+1'b1;end end
end
endmodule
