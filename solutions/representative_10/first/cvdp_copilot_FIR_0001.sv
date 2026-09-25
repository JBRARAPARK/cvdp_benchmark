module fir_filter(input logic clk,reset,input logic signed [15:0] input_sample,
output logic signed [15:0] output_sample,input logic signed [15:0] coeff0,coeff1,coeff2,coeff3);
logic signed [15:0] d1,d2,d3;
logic signed [31:0] acc,p1,p2;
always_ff @(posedge clk or posedge reset) begin
 if(reset) begin d1<=0;d2<=0;d3<=0;acc<=0;p1<=0;p2<=0;output_sample<=0;end
 else begin
 d1<=input_sample;d2<=d1;d3<=d2;
 acc<=input_sample*coeff0+d1*coeff1+d2*coeff2+d3*coeff3;
 p1<=acc;p2<=p1;output_sample<=p2[15:0];
 end
end
endmodule
