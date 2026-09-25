module bcd_adder(                
                 input  [3:0] a,             // 4-bit BCD input
                 input  [3:0] b,             // 4-bit BCD input
                 output [3:0] sum,           // The corrected 4-bit BCD result of the addition
                 output       cout           // Carry-out to indicate overflow beyond BCD range (i.e., when the result exceeds 9)
                );
    
wire [3:0] binary_sum;         // Intermediate binary sum
wire binary_cout;              // Intermediate binary carry
wire z1, z2;                   // Intermediate wires for BCD correction
wire carry;                    // Carry for the second adder

    // Instantiate the first four-bit adder for Binary Addition
   four_bit_adder adder1(         
                      .a(a),            
                      .b(b),            
                      .cin(1'b0),       
                      .sum(binary_sum), 
                      .cout(binary_cout) 
                     );
       
    assign cout=binary_cout | (binary_sum[3] & (binary_sum[2]|binary_sum[1]));
    

    // Instantiate the second four-bit adder for BCD correction
    four_bit_adder adder2(         
                      .a(binary_sum),     
                      .b({1'b0, cout, cout, 1'b0}), 
                      .cin(1'b0),         
                      .sum(sum),          
                      .cout(carry)        
                     );
endmodule     


module four_bit_adder(input [3:0] a,b,input cin,output [3:0] sum,output cout);
wire [4:0] c;assign c[0]=cin;assign cout=c[4];
genvar i;generate for(i=0;i<4;i=i+1)begin:fa
full_adder u(a[i],b[i],c[i],sum[i],c[i+1]);end endgenerate
endmodule
module full_adder(input a,b,cin,output sum,cout);assign sum=a^b^cin;assign cout=(a&b)|(a&cin)|(b&cin);endmodule
