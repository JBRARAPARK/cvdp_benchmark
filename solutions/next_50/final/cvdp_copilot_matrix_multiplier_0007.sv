module matrix_multiplier #(parameter ROW_A=4,COL_A=4,ROW_B=4,COL_B=4,INPUT_DATA_WIDTH=8,OUTPUT_DATA_WIDTH=2*INPUT_DATA_WIDTH+$clog2(COL_A))(
input clk,srst,valid_in,input [ROW_A*COL_A*INPUT_DATA_WIDTH-1:0] matrix_a,input [ROW_B*COL_B*INPUT_DATA_WIDTH-1:0] matrix_b,output reg [ROW_A*COL_B*OUTPUT_DATA_WIDTH-1:0] matrix_c,output reg valid_out);
reg [OUTPUT_DATA_WIDTH-1:0] prod[0:ROW_A-1][0:COL_B-1][0:COL_A-1];
reg [OUTPUT_DATA_WIDTH-1:0] acc[0:ROW_A-1][0:COL_B-1];integer count,i,j,k;reg busy;
always @(posedge clk)begin
 if(srst)begin busy<=0;count<=0;matrix_c<=0;valid_out<=0;for(i=0;i<ROW_A;i=i+1)for(j=0;j<COL_B;j=j+1)begin acc[i][j]<=0;for(k=0;k<COL_A;k=k+1)prod[i][j][k]<=0;end end
 else begin valid_out<=0;
 if(!busy && valid_in)begin busy<=1;count<=0;for(i=0;i<ROW_A;i=i+1)for(j=0;j<COL_B;j=j+1)begin acc[i][j]<=0;for(k=0;k<COL_A;k=k+1)prod[i][j][k]<=matrix_a[(i*COL_A+k)*INPUT_DATA_WIDTH+:INPUT_DATA_WIDTH]*matrix_b[(k*COL_B+j)*INPUT_DATA_WIDTH+:INPUT_DATA_WIDTH];end end
 else if(busy)begin
 if(count<COL_A)begin for(i=0;i<ROW_A;i=i+1)for(j=0;j<COL_B;j=j+1)acc[i][j]<=acc[i][j]+prod[i][j][count];count<=count+1;end
 else begin for(i=0;i<ROW_A;i=i+1)for(j=0;j<COL_B;j=j+1)matrix_c[(i*COL_B+j)*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH]<=acc[i][j];valid_out<=1;busy<=0;end
 end end end
endmodule
