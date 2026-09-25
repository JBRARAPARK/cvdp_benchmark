module hamming_code_receiver(input [7:0] data_in,output reg [3:0] data_out);
reg [2:0] syndrome;reg [7:0] corrected;
always @*begin
 syndrome={data_in[4]^data_in[5]^data_in[6]^data_in[7],data_in[2]^data_in[3]^data_in[6]^data_in[7],data_in[1]^data_in[3]^data_in[5]^data_in[7]};
 corrected=data_in;if(syndrome!=0)corrected[syndrome]=~corrected[syndrome];
 data_out={corrected[7:5],corrected[3]};
end
endmodule
