module interrupt_controller #(
 parameter STARVATION_THRESHOLD=5,
 parameter SERVICE_TIMEOUT=16
)(
 input wire clk,rst_n,reset_interrupts,
 input wire [9:0] interrupt_requests,
 input wire interrupt_ack,interrupt_trig,
 input wire [9:0] interrupt_mask,
 input wire [3:0] priority_override,override_interrupt_id,
 input wire priority_override_en,
 output reg [3:0] interrupt_id,
 output reg interrupt_valid,
 output reg [9:0] interrupt_status,missed_interrupts,
 output reg starvation_detected
);
 localparam IDLE=0,PRIORITY_CALC=1,SERVICE_PREP=2,SERVICING=3,COMPLETION=4,ERROR=7;
 localparam WAIT_WIDTH=(STARVATION_THRESHOLD<2)?1:$clog2(STARVATION_THRESHOLD+1);
 localparam TIMER_WIDTH=(SERVICE_TIMEOUT<2)?1:$clog2(SERVICE_TIMEOUT);
 reg [2:0] current_state;
 reg [9:0] pending_interrupts;
 // Saturating count of arbitration opportunities, not elapsed clock cycles.
 reg [WAIT_WIDTH-1:0] wait_counters[0:9];
 reg [TIMER_WIDTH-1:0] service_timer;
 reg [4:0] effective_priority[0:9];
 reg [3:0] next_interrupt_id;
 reg timeout_error;
 integer best,i,j,priority_value;
 wire [9:0] new_requests=interrupt_trig?(interrupt_requests & ~interrupt_mask):10'b0;
 wire [9:0] new_missed=interrupt_trig?(interrupt_requests & interrupt_mask):10'b0;
 wire finishing=(current_state==SERVICING) && (interrupt_ack || service_timer==SERVICE_TIMEOUT-1);
 wire [9:0] serviced_mask=finishing?(10'b1<<interrupt_id):10'b0;
 // Clear first, then add new requests: a new request concurrent with ACK is retained.
 wire [9:0] pending_next=(pending_interrupts & ~serviced_mask)|new_requests;
 always @*begin
  best=-1;next_interrupt_id=0;
  for(j=0;j<10;j=j+1)begin
   priority_value=10-j;
   if(priority_override_en && override_interrupt_id==j)priority_value=priority_override;
   if(wait_counters[j]>=STARVATION_THRESHOLD-1)begin
    priority_value=priority_value+j;
    if(priority_value>15)priority_value=15;
   end
   effective_priority[j]=priority_value;
   // Higher ID wins equal priorities, allowing aged low-priority IRQs to advance.
   if(pending_interrupts[j] && priority_value>=best)begin best=priority_value;next_interrupt_id=j;end
  end
 end
 always @(posedge clk or negedge rst_n)begin
  if(!rst_n)begin
   current_state<=IDLE;pending_interrupts<=0;interrupt_id<=0;interrupt_valid<=0;
   interrupt_status<=0;missed_interrupts<=0;starvation_detected<=0;
   service_timer<=0;timeout_error<=0;
   for(i=0;i<10;i=i+1)wait_counters[i]<=0;
  end else if(reset_interrupts)begin
   current_state<=IDLE;pending_interrupts<=0;interrupt_id<=0;interrupt_valid<=0;
   interrupt_status<=0;missed_interrupts<=0;starvation_detected<=0;
   service_timer<=0;timeout_error<=0;
   for(i=0;i<10;i=i+1)wait_counters[i]<=0;
  end else begin
   pending_interrupts<=pending_next;
   missed_interrupts<=missed_interrupts|new_missed;
   starvation_detected<=0;
   for(i=0;i<10;i=i+1)begin
    if(!pending_interrupts[i] || serviced_mask[i])wait_counters[i]<=0;
    else begin
     if(current_state==PRIORITY_CALC && wait_counters[i]<STARVATION_THRESHOLD)
      wait_counters[i]<=wait_counters[i]+1'b1;
     if(wait_counters[i]>=STARVATION_THRESHOLD)starvation_detected<=1;
    end
   end
   case(current_state)
    IDLE:if(|pending_next)current_state<=PRIORITY_CALC;
    PRIORITY_CALC:begin interrupt_id<=next_interrupt_id;current_state<=SERVICE_PREP;end
    SERVICE_PREP:begin interrupt_valid<=1;interrupt_status<=10'b1<<interrupt_id;service_timer<=0;current_state<=SERVICING;end
    SERVICING:begin
     if(finishing)begin
      interrupt_valid<=0;interrupt_status<=0;
      if(interrupt_ack)current_state<=COMPLETION;
      else begin current_state<=ERROR;timeout_error<=1;missed_interrupts<=missed_interrupts|new_missed|(10'b1<<interrupt_id);end
     end else service_timer<=service_timer+1'b1;
    end
    COMPLETION,ERROR:if(|pending_next)current_state<=PRIORITY_CALC;else current_state<=IDLE;
    default:begin current_state<=IDLE;interrupt_valid<=0;interrupt_status<=0;end
   endcase
  end
 end
endmodule
