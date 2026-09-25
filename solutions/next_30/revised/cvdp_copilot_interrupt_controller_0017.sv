module interrupt_controller #(parameter STARVATION_THRESHOLD=5)(input clk,rst_n,reset_interrupts,input [9:0] interrupt_requests,input interrupt_ack,interrupt_trig,input [9:0] interrupt_mask,input [3:0] priority_override,override_interrupt_id,input priority_override_en,output reg [3:0] interrupt_id,output reg interrupt_valid,output reg [9:0] interrupt_status,missed_interrupts,output reg starvation_detected);
localparam IDLE=0,PRIORITY_CALC=1,SERVICE_PREP=2,SERVICING=3,COMPLETION=4,ERROR=7;
reg [2:0] current_state;reg [9:0] pending_interrupts;reg [3:0] wait_counters[0:9];reg [4:0] effective_priority[0:9];reg [3:0] service_timer,next_interrupt_id;integer best;integer i;
always @*begin
 best=-1;next_interrupt_id=0;
 for(integer j=0;j<10;j=j+1)begin
 effective_priority[j]=5'(10-j);
 if(priority_override_en && override_interrupt_id==j)effective_priority[j]={1'b0,priority_override};
 if(wait_counters[j]>=STARVATION_THRESHOLD)effective_priority[j]=effective_priority[j]+5'd16;
 if(pending_interrupts[j] && effective_priority[j]>best)begin best=effective_priority[j];next_interrupt_id=4'(j);end
 end
end
always @(posedge clk or negedge rst_n)begin
 if(!rst_n)begin current_state<=IDLE;pending_interrupts<=0;interrupt_id<=0;interrupt_valid<=0;interrupt_status<=0;missed_interrupts<=0;starvation_detected<=0;service_timer<=0;for(i=0;i<10;i=i+1)wait_counters[i]<=0;end
 else if(reset_interrupts)begin current_state<=IDLE;pending_interrupts<=0;interrupt_id<=0;interrupt_valid<=0;interrupt_status<=0;missed_interrupts<=0;starvation_detected<=0;service_timer<=0;for(i=0;i<10;i=i+1)wait_counters[i]<=0;end
 else begin
 if(interrupt_trig)begin pending_interrupts<=pending_interrupts|(interrupt_requests & ~interrupt_mask);missed_interrupts<=missed_interrupts|(interrupt_requests & interrupt_mask);end
 starvation_detected<=0;
 for(i=0;i<10;i=i+1)begin
 if(pending_interrupts[i] && !interrupt_status[i])begin if(wait_counters[i]!=15)wait_counters[i]<=wait_counters[i]+1'b1;if(wait_counters[i]>=STARVATION_THRESHOLD)starvation_detected<=1;end
 else wait_counters[i]<=0;
 end
 case(current_state)
 IDLE:if(|pending_interrupts)current_state<=PRIORITY_CALC;
 PRIORITY_CALC:begin interrupt_id<=next_interrupt_id;current_state<=SERVICE_PREP;end
 SERVICE_PREP:begin interrupt_valid<=1;interrupt_status<=10'b1<<interrupt_id;service_timer<=0;current_state<=SERVICING;end
 SERVICING:if(interrupt_ack)current_state<=COMPLETION;else if(service_timer==15)current_state<=ERROR;else service_timer<=service_timer+1'b1;
 COMPLETION,ERROR:begin pending_interrupts[interrupt_id]<=0;interrupt_valid<=0;interrupt_status<=0;current_state<=IDLE;end
 default:current_state<=IDLE;
 endcase
 end
end
endmodule
