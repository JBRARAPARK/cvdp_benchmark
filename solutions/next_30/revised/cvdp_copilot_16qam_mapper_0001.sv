module qam16_mapper_interpolated #(parameter N=4,IN_WIDTH=4,OUT_WIDTH=3)(input [N*IN_WIDTH-1:0] bits,output reg [(N+N/2)*OUT_WIDTH-1:0] I,Q);
function automatic signed [OUT_WIDTH-1:0] map2(input [1:0] value);
 case(value)0:map2=-3;1:map2=-1;2:map2=1;3:map2=3;endcase
endfunction
reg signed [OUT_WIDTH-1:0] ia,ib,qa,qb;
reg signed [OUT_WIDTH:0] isum,qsum;
integer j;
always @*begin
 I=0;Q=0;ia=0;ib=0;qa=0;qb=0;isum=0;qsum=0;
 for(j=0;j<N/2;j=j+1)begin
 ia=map2(bits[(2*j)*IN_WIDTH+2+:2]);qa=map2(bits[(2*j)*IN_WIDTH+:2]);
 ib=map2(bits[(2*j+1)*IN_WIDTH+2+:2]);qb=map2(bits[(2*j+1)*IN_WIDTH+:2]);
 isum={ia[OUT_WIDTH-1],ia}+{ib[OUT_WIDTH-1],ib};qsum={qa[OUT_WIDTH-1],qa}+{qb[OUT_WIDTH-1],qb};
 I[3*j*OUT_WIDTH+:OUT_WIDTH]=ia;I[(3*j+1)*OUT_WIDTH+:OUT_WIDTH]=isum>>>1;I[(3*j+2)*OUT_WIDTH+:OUT_WIDTH]=ib;
 Q[3*j*OUT_WIDTH+:OUT_WIDTH]=qa;Q[(3*j+1)*OUT_WIDTH+:OUT_WIDTH]=qsum>>>1;Q[(3*j+2)*OUT_WIDTH+:OUT_WIDTH]=qb;
 end
end
endmodule
