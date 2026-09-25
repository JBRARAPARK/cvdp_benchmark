module vending_machine(input logic clk,rst,item_button,input logic [2:0] item_selected,
input logic [3:0] coin_input,input logic cancel,
output logic dispense_item,return_change,output logic [4:0] item_price,change_amount,
output logic [2:0] dispense_item_id,output logic error,return_money);
typedef enum logic [2:0] {IDLE,ITEM_SELECTION,PAYMENT_VALIDATION,DISPENSING_ITEM,RETURN_CHANGE,RETURN_MONEY,CHANGE_WAIT} state_t;
state_t state;
logic prev_button,prev_cancel;
logic [5:0] money;
logic [2:0] selected;
wire cancel_edge=cancel & ~prev_cancel;
wire valid_coin=coin_input==1 || coin_input==2 || coin_input==5 || coin_input==10;
always_ff @(posedge clk or posedge rst) begin
 if(rst) begin
 state<=IDLE; prev_button<=0;prev_cancel<=0;money<=0;selected<=0;
 dispense_item<=0;return_change<=0;item_price<=0;change_amount<=0;dispense_item_id<=0;error<=0;return_money<=0;
 end else begin
 prev_button<=item_button;prev_cancel<=cancel;
 dispense_item<=0;return_change<=0;error<=0;return_money<=0;
 if(cancel_edge && (state==ITEM_SELECTION || state==PAYMENT_VALIDATION)) begin error<=1;state<=RETURN_MONEY; end
 else case(state)
 IDLE: begin
 money<=0;item_price<=0;change_amount<=0;
 if(item_button && !prev_button) state<=ITEM_SELECTION;
 else if(coin_input!=0) begin money<=coin_input;error<=1;state<=RETURN_MONEY;end
 end
 ITEM_SELECTION: begin
 if(item_selected>=1 && item_selected<=4) begin selected<=item_selected;item_price<=item_selected*5;state<=PAYMENT_VALIDATION;end
 else if(coin_input!=0) begin money<=coin_input;error<=1;state<=RETURN_MONEY;end
 end
 PAYMENT_VALIDATION: if(coin_input!=0) begin
 if(valid_coin) begin money<=money+coin_input;if(money+coin_input>=item_price) state<=DISPENSING_ITEM;end
 else begin error<=1;return_money<=1;money<=0;state<=IDLE;end
 end
 DISPENSING_ITEM: begin dispense_item<=1;dispense_item_id<=selected;
 change_amount<=money-item_price;if(money>item_price)state<=CHANGE_WAIT;else state<=IDLE;end
 CHANGE_WAIT: state<=RETURN_CHANGE;
 RETURN_CHANGE: begin return_change<=1;state<=IDLE;end
 RETURN_MONEY: begin return_money<=money!=0;change_amount<=money;state<=IDLE;end
 default: state<=IDLE;
 endcase
 end
end
endmodule
