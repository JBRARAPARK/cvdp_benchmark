module static_branch_predict(input [31:0] fetch_rdata_i,fetch_pc_i,input fetch_valid_i,output reg predict_branch_taken_o,output reg [31:0] predict_branch_pc_o);
wire [31:0] instr=fetch_rdata_i;
wire [31:0] imm_j_type={{12{instr[31]}},instr[19:12],instr[20],instr[30:21],1'b0};
wire [31:0] imm_b_type={{19{instr[31]}},instr[31],instr[7],instr[30:25],instr[11:8],1'b0};
wire [31:0] imm_i_type={{20{instr[31]}},instr[31:20]};
always @*begin predict_branch_taken_o=0;predict_branch_pc_o=fetch_pc_i;
case(instr[6:0])7'h6f:begin predict_branch_taken_o=fetch_valid_i;predict_branch_pc_o=fetch_pc_i+imm_j_type;end
7'h67:begin predict_branch_taken_o=fetch_valid_i;predict_branch_pc_o=fetch_pc_i+imm_i_type;end
7'h63:begin predict_branch_taken_o=fetch_valid_i&&instr[31];predict_branch_pc_o=fetch_pc_i+imm_b_type;end endcase end endmodule
