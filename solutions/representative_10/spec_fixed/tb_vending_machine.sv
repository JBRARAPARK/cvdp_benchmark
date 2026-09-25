`timescale 1ns/1ps
module tb_vending_machine;
    reg clk=0;
    always #5 clk=~clk;
    reg rst=0,item_button=0,cancel=0;
    reg [2:0] item_selected=0;
    reg [3:0] coin_input=0;
    wire dispense_item,return_change,error,return_money;
    wire [4:0] item_price,change_amount;
    wire [2:0] dispense_item_id;
    vending_machine dut(.*);
    integer checks=0, cases=0;

    task check(input bit ok,input string message);
        begin checks=checks+1; if(!ok) $fatal(1,"%s at %0t",message,$time); end
    endtask
    // Drive half a cycle before sampling; inspect after nonblocking updates settle.
    task step(input bit button,input integer id,input integer coin,input bit cancel_in);
        begin
            @(negedge clk);
            item_button=button;item_selected=id;coin_input=coin;cancel=cancel_in;
            @(posedge clk); #1;
        end
    endtask
    task reset_dut;
        begin
            @(negedge clk); rst=1;item_button=0;cancel=0;coin_input=0;item_selected=0;
            #1;
            check({dispense_item,return_change,error,return_money,item_price,change_amount,dispense_item_id}==='0,"asynchronous reset clears outputs");
            @(negedge clk); rst=0;
        end
    endtask
    task select_item(input integer id);
        begin
            step(1,id,0,0);
            step(0,id,0,0);
            check(item_price==id*5 && !error,"valid selection sets price");
        end
    endtask
    task quiet;
        begin check(!dispense_item && !return_change && !return_money && !error && change_amount==0,"events clear after one cycle");end
    endtask
    integer id,invalid_id,bad_coin,extra,k;
    initial begin
        // All four products, exact payment and overpayment; back-to-back transactions.
        reset_dut();
        for(id=1;id<=4;id=id+1) begin
            for(extra=0;extra<=1;extra=extra+1) begin
                select_item(id);
                if(extra) step(0,id,1,0);
                for(k=0;k<id;k=k+1) step(0,id,5,0);
                check(!dispense_item,"payment is followed by dispense state");
                step(0,id,0,0);
                check(dispense_item && dispense_item_id==id && !return_change,"single dispense with correct ID");
                step(0,id,0,0);
                check(!dispense_item && return_change==extra && change_amount==extra,"change exactly one cycle after dispense");
                check(dispense_item_id==id,"last dispensed ID remains readable");
                step(0,id,0,0);quiet();cases=cases+1;
            end
        end
        // Invalid IDs must fail without any coin input.
        for(invalid_id=0;invalid_id<=7;invalid_id=invalid_id+1) begin
            if(invalid_id==0 || invalid_id>=5) begin
                reset_dut();step(1,invalid_id,0,0);step(0,invalid_id,0,0);
                check(error && !dispense_item,"invalid ID rejected at selection clock without coins");
                step(0,invalid_id,0,0);quiet();step(0,0,0,0);quiet();cases=cases+1;
            end
        end
        // Every unsupported nonzero coin value: error and refund together.
        for(bad_coin=1;bad_coin<=15;bad_coin=bad_coin+1) begin
            if(bad_coin!=1 && bad_coin!=2 && bad_coin!=5 && bad_coin!=10)begin
                reset_dut();select_item(4);step(0,4,2,0);step(0,4,bad_coin,0);
                check(error && return_money && change_amount==2 && !dispense_item,"invalid coin refunds accepted balance in same cycle");
                step(0,0,0,0);quiet();cases=cases+1;
            end
        end
        // Cancel before selection, during payment, and after full payment but before dispense.
        for(k=0;k<3;k=k+1)begin
            reset_dut();
            if(k==0)step(1,2,0,0);
            else begin select_item(2);step(0,2,k==1?2:10,0);end
            step(0,2,0,1);
            check(error && !dispense_item && !return_money,"cancel takes priority before dispense");
            step(0,2,0,1);
            check(!error && !dispense_item && return_money==(k!=0),"cancel refunds on following clock");
            check(change_amount==(k==0?0:(k==1?2:10)),"cancel returns full accepted balance");
            step(0,0,0,1);quiet();step(0,0,0,1);quiet();cases=cases+1;
        end
        // No selection and simultaneous button+coin cannot authorize payment.
        for(k=0;k<2;k=k+1) begin
            reset_dut();step(k,1,5,0);check(error && !dispense_item,"unselected coin rejected");
            step(0,0,0,0);check(return_money && change_amount==5 && !error,"unselected coin refunded");
            step(0,0,0,0);quiet();cases=cases+1;
        end
        // Held button must not create a second transaction after a purchase.
        reset_dut();step(1,1,0,0);step(1,1,0,0);step(1,1,5,0);
        step(1,1,0,0);check(dispense_item,"held button purchase completes");
        repeat(4)begin step(1,1,0,0);quiet();end
        step(1,1,5,0);check(error && !dispense_item,"held button cannot reselect");cases=cases+1;
        // Async reset in payment, pending dispense, and pending change.
        for(k=0;k<3;k=k+1)begin
            reset_dut();select_item(1);step(0,1,k==0?2:10,0);
            if(k==2)step(0,1,0,0);
            reset_dut();step(0,0,0,0);quiet();cases=cases+1;
        end
        $display("SPEC_TEST_PASS cases=%0d assertions=%0d",cases,checks);
        $finish;
    end
    initial begin #100000; $fatal(1,"timeout");end
endmodule
