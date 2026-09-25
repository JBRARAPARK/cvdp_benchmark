module APBGlobalHistoryRegister(input pclk,presetn,input [9:0] paddr,input pselx,penable,pwrite,input [7:0] pwdata,output reg pready,output reg [7:0] prdata,output reg pslverr,input history_shift_valid,clk_gate_en,output history_full,history_empty,output reg error_flag,output interrupt_full,interrupt_error);
reg [3:0] control_register;reg [6:0] train_history;reg [7:0] predict_history;
wire gated_clk=pclk && !clk_gate_en;
assign history_full=&predict_history;assign history_empty=~|predict_history;assign interrupt_full=history_full;assign interrupt_error=error_flag;
always @(posedge history_shift_valid or negedge presetn)if(!presetn)predict_history<=0;else if(control_register[2])predict_history<={train_history,control_register[3]};else if(control_register[0])predict_history<={predict_history[6:0],control_register[1]};
always @(posedge gated_clk or negedge presetn)if(!presetn)begin control_register<=0;train_history<=0;pready<=0;prdata<=0;pslverr<=0;error_flag<=0;end else begin pready<=1;pslverr<=0;error_flag<=0;if(pselx&&penable)begin
if(paddr>2)begin pslverr<=1;error_flag<=1;end
else if(pwrite)case(paddr)0:control_register<=pwdata[3:0];1:train_history<=pwdata[6:0];endcase
else case(paddr)0:prdata<={4'b0,control_register};1:prdata<={1'b0,train_history};2:prdata<=predict_history;endcase
end end endmodule
