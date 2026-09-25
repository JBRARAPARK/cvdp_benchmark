`define NOTCONNECTED_PIN(x)   /* verilator lint_off PINCONNECTEMPTY */ \
                        . x () \
                        /* verilator lint_on PINCONNECTEMPTY */

module cache_mshr #(
    parameter INSTANCE_ID                   = "mo_mshr"             ,
    parameter MSHR_SIZE                     = 32                    ,
    parameter CS_LINE_ADDR_WIDTH            = 10                    ,
    parameter WORD_SEL_WIDTH                = 4                     ,
    parameter WORD_SIZE                     = 4                     ,
    // Derived parameters
    parameter MSHR_ADDR_WIDTH               = $clog2(MSHR_SIZE)     , // default = 5
    parameter TAG_WIDTH                     = 32 - (CS_LINE_ADDR_WIDTH+ $clog2(WORD_SIZE) + WORD_SEL_WIDTH), // default = 16
    parameter CS_WORD_WIDTH                 = WORD_SIZE * 8 ,// default = 32 
    parameter DATA_WIDTH                    = WORD_SEL_WIDTH + WORD_SIZE + CS_WORD_WIDTH + TAG_WIDTH // default =  4 + 4 + 32 + 16 = 56

    ) (
    input wire clk,
    input wire reset,

    // allocate
    input wire                          allocate_valid,
    output wire                         allocate_ready,
    input wire [CS_LINE_ADDR_WIDTH-1:0] allocate_addr,
    input wire                          allocate_rw,
    input wire [DATA_WIDTH-1:0]         allocate_data,
    output wire [MSHR_ADDR_WIDTH-1:0]   allocate_id,
    output wire                         allocate_pending,
    output wire [MSHR_ADDR_WIDTH-1:0]   allocate_previd,

    // finalize
    input wire                          finalize_valid,
    input wire [MSHR_ADDR_WIDTH-1:0]    finalize_id
);

    
   
reg [MSHR_SIZE-1:0] valid_q,next_valid;
reg [CS_LINE_ADDR_WIDTH-1:0] addresses [0:MSHR_SIZE-1];
reg [DATA_WIDTH-1:0] data_mem [0:MSHR_SIZE-1];
reg [MSHR_ADDR_WIDTH-1:0] next_id [0:MSHR_SIZE-1];
reg [MSHR_SIZE-1:0] writes;
reg [MSHR_ADDR_WIDTH-1:0] free_id,prev_id;
reg free_found,match_found;
reg [MSHR_ADDR_WIDTH-1:0] allocated_q,previous_q;
reg pending_q;
integer i,j;
always @* begin
 free_id=0;prev_id=0;free_found=0;match_found=0;
 for(integer k=0;k<MSHR_SIZE;k=k+1)begin
 if(!valid_q[k] && !free_found)begin free_id=k;free_found=1;end
 if(valid_q[k] && addresses[k]==allocate_addr && !next_valid[k] && !match_found)begin prev_id=k;match_found=1;end
 end
end
assign allocate_ready=free_found;
assign allocate_id=allocated_q;
assign allocate_pending=pending_q;
assign allocate_previd=previous_q;
always @(posedge clk) begin
 if(reset)begin valid_q<=0;next_valid<=0;writes<=0;allocated_q<=0;previous_q<=0;pending_q<=0;
 for(i=0;i<MSHR_SIZE;i=i+1)begin addresses[i]<=0;data_mem[i]<=0;next_id[i]<=0;end
 end else begin
 pending_q<=0;
 if(finalize_valid)begin
 valid_q[finalize_id]<=0;next_valid[finalize_id]<=0;
 for(j=0;j<MSHR_SIZE;j=j+1)if(valid_q[j] && next_valid[j] && next_id[j]==finalize_id)begin
 next_valid[j]<=next_valid[finalize_id];next_id[j]<=next_id[finalize_id];end
 end
 if(allocate_valid && allocate_ready)begin
 valid_q[free_id]<=1;next_valid[free_id]<=0;addresses[free_id]<=allocate_addr;
 data_mem[free_id]<=allocate_data;writes[free_id]<=allocate_rw;allocated_q<=free_id;
 pending_q<=match_found;previous_q<=prev_id;
 if(match_found && !(finalize_valid && finalize_id==prev_id))begin next_valid[prev_id]<=1;next_id[prev_id]<=free_id;end
 end
 end
end
endmodule
module leading_zero_cnt #(
    parameter DATA_WIDTH = 32,
    parameter REVERSE = 0 
)(
    input  [DATA_WIDTH -1:0] data,
    output  [$clog2(DATA_WIDTH)-1:0] leading_zeros,
    output all_zeros 
);
    localparam NIBBLES_NUM = DATA_WIDTH/4 ; 
    reg [NIBBLES_NUM-1 :0] all_zeros_flag ;
    reg [1:0]  zeros_cnt_per_nibble [NIBBLES_NUM-1 :0]  ;

    genvar i;
    integer k ;
    // Assign data/nibble 
    reg [3:0]  data_per_nibble [NIBBLES_NUM-1 :0]  ;
    generate
        for (i=0; i < NIBBLES_NUM ; i=i+1) begin
            always @* begin
                data_per_nibble[i] = data[(i*4)+3: (i*4)] ;
            end
        end
    endgenerate
   
    generate
        for (i=0; i < NIBBLES_NUM ; i=i+1) begin : g_nibble
            if (REVERSE) begin : g_trailing
                always @* begin
                        zeros_cnt_per_nibble[i] [1] = ~(data_per_nibble[i][1] | data_per_nibble[i][0]); 
                        zeros_cnt_per_nibble[i] [0] = (~data_per_nibble[i][0]) &
                                                      ((~data_per_nibble[i][2]) | data_per_nibble[i][1]);
                        all_zeros_flag[i] = (data_per_nibble[i] == 4'b0000);
                end
            end else begin :g_leading
                always @* begin
                    zeros_cnt_per_nibble[NIBBLES_NUM-1-i][1] = ~(data_per_nibble[i][3] | data_per_nibble[i][2]); 
                    zeros_cnt_per_nibble[NIBBLES_NUM-1-i][0] = (~data_per_nibble[i][3]) &
                                     ((~data_per_nibble[i][1]) | data_per_nibble[i][2]);
                    
                    all_zeros_flag[NIBBLES_NUM-1-i] = (data_per_nibble[i] == 4'b0000);
                end
            end
        end
    endgenerate

    
    
    reg [$clog2(NIBBLES_NUM)-1:0] index ; 
    reg [1:0]    choosen_nibbles_zeros_count ;
    reg [ $clog2(NIBBLES_NUM*4)-1:0] zeros_count_result ;
    wire [NIBBLES_NUM-1:0]         all_zeros_flag_decoded;
    
    assign all_zeros_flag_decoded[0] = all_zeros_flag[0] ;
    genvar j;
        generate
            for (j=1; j < NIBBLES_NUM; j=j+1) begin
                assign all_zeros_flag_decoded[j] = all_zeros_flag_decoded[j-1] & all_zeros_flag[j];
            end
        endgenerate

    always@ * begin
        index = 0 ;
        for ( k =0 ; k< NIBBLES_NUM ; k =k +1) begin
            index = index + all_zeros_flag_decoded[k] ;
        end
    end
    
    always@* begin
        choosen_nibbles_zeros_count = zeros_cnt_per_nibble[index]  ;  
        zeros_count_result = choosen_nibbles_zeros_count + (index <<2) ; 
    end
    
    assign leading_zeros =  zeros_count_result ;
    assign all_zeros = (data ==0) ;

endmodule
