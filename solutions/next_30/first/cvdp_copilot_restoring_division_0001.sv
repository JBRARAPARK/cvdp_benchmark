module restoring_division #(parameter WIDTH=6)(input clk,rst,start,input [WIDTH-1:0] dividend,divisor,output reg [WIDTH-1:0] quotient,remainder,output reg valid);
reg [WIDTH-1:0] q,rem,div;integer remaining;reg busy,pending;
wire [WIDTH:0] shifted={rem,q[WIDTH-1]};wire fits=shifted>={1'b0,div};
wire [WIDTH:0] reduced=fits?shifted-{1'b0,div}:shifted;
wire [WIDTH-1:0] q_next=(q<<1)|fits;
always @(posedge clk or negedge rst)begin
 if(!rst)begin quotient<=0;remainder<=0;valid<=0;q<=0;rem<=0;div<=0;remaining<=0;busy<=0;pending<=0;end
 else begin valid<=0;
 if(pending)begin quotient<=q;remainder<=rem;valid<=1;pending<=0;end
 else if(start && !busy)begin q<=dividend;div<=divisor;rem<=0;remaining<=WIDTH;busy<=1;end
 else if(busy)begin q<=q_next;rem<=reduced[WIDTH-1:0];remaining<=remaining-1;
 if(remaining==1)begin busy<=0;
 if((WIDTH & (WIDTH-1))==0)begin quotient<=q_next;remainder<=reduced[WIDTH-1:0];valid<=1;end else pending<=1;
 end end end
end
endmodule
