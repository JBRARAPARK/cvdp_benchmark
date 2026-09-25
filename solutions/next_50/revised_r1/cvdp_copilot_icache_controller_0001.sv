module instruction_cache_controller (
    input  wire        clk,                // Clock signal
    input  wire        rst,                // Reset signal

    output reg         io_mem_valid,       // Indicates that memory operation is valid
    input  wire        io_mem_ready,       // Indicates that memory is ready for the operation
    output reg  [16:0] io_mem_addr,        // Address for memory operation

    output reg         l1b_wait,           // Indicates if the L1 cache is still waiting for data
    output wire [31:0] l1b_data,           // Data output from the L1 cache
    input  wire [17:0] l1b_addr,           // Address of the L1 cache (18-bits)

    // RAM256_T0 (Tag Memory 0)
    output wire       ram256_t0_we,        // Write enable for the RAM256_T0 (Tag RAM 0)
    output wire [7:0] ram256_t0_addr,      // Address for the RAM256_T0 (Tag RAM 0)
    input  wire [7:0] ram256_t0_data,      // Data read from the RAM256_T0 (Tag RAM 0)

    // RAM256_T1 (Tag Memory 1)
    output wire       ram256_t1_we,        // Write enable for the RAM256_T1 (Tag RAM 1)
    output wire [7:0] ram256_t1_addr,      // Address for the RAM256_T1 (Tag RAM 1)
    input  wire [7:0] ram256_t1_data,      // Data read from the RAM256_T1 (Tag RAM 1)

    // RAM512_D0 (Data Memory 0)
    output wire        ram512_d0_we,       // Write enable for the RAM512_D0 (Data RAM 0)
    output wire [8:0]  ram512_d0_addr,     // Address for the RAM512_D0 (Data RAM 0)
    input  wire [15:0] ram512_d0_data,     // Data read from the RAM512_D0 (Data RAM 0)

    // RAM512_D1 (Data Memory 1)
    output wire        ram512_d1_we,       // Write enable for the RAM512_D1 (Data RAM 1)
    output wire [8:0]  ram512_d1_addr,     // Address for the RAM512_D1 (Data RAM 1)
    input  wire [15:0] ram512_d1_data      // Data read from the RAM512_D1 (Data RAM 1)
);
    wire [15:0] data_0;
    wire [15:0] data_1;

     assign data_0=ram512_d0_data;assign data_1=ram512_d1_data;
assign l1b_data=l1b_addr[0]?{data_0,data_1}:{data_1,data_0};
assign ram512_d0_addr=data_addr_0;assign ram512_d1_addr=data_addr_1;
assign ram512_d0_we=(state==READMEM0)&&io_mem_ready;assign ram512_d1_we=(state==READMEM1)&&io_mem_ready;

    localparam TAG_BITS = 8;
    localparam ADR_BITS = 9;

    localparam IDLE      = 3'd0,
               READMEM0  = 3'd1,
               READMEM1  = 3'd2,
               READCACHE = 3'd3;

    reg [2:0] state, next_state;
    reg [ADR_BITS-1:0] addr_0, addr_1;
    reg write_enable;

    wire [ADR_BITS-1:0] data_addr_0 = l1b_addr[17:9] + {{8{1'b0}}, l1b_addr[0]};
    wire [ADR_BITS-1:0] data_addr_1 = l1b_addr[17:9];

    wire valid_0, valid_1;
    wire [TAG_BITS-1:0] tag_0, tag_1;

    wire data_0_ready = (l1b_addr[17:9] == tag_0) && valid_0;
    wire data_1_ready = (l1b_addr[17:9] == tag_1) && valid_1;


    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            write_enable <= 1'b0;
            addr_0 <= {ADR_BITS{1'b0}};
            addr_1 <= {ADR_BITS{1'b0}};
        end else begin
            if ((state == READMEM0 || state == READMEM1) && io_mem_ready) begin
                write_enable <= 1'b1;
            end else begin 
                write_enable <= 1'b0;
            end
            state <= next_state;
            addr_0 <= data_addr_0;
            addr_1 <= data_addr_1;
        end
    end

    always @*begin next_state=state;case(state)
IDLE:if(!data_0_ready)next_state=READMEM0;else if(!data_1_ready)next_state=READMEM1;
READMEM0:if(io_mem_ready)next_state=READMEM1;
READMEM1:if(io_mem_ready)next_state=READCACHE;
READCACHE:next_state=IDLE;default:next_state=IDLE;endcase end
    always @*begin io_mem_valid=(state==READMEM0||state==READMEM1);l1b_wait=state!=IDLE||!data_0_ready||!data_1_ready;io_mem_addr=l1b_addr[17:1];if(state==READMEM1)io_mem_addr=(l1b_addr[17:1]+l1b_addr[0]);end


    tag_controller tag_ctrl (
        .clk(clk),
        .rst(rst),
        .write_enable(write_enable),
        .write_addr(io_mem_addr[ADR_BITS-1:0]),
        .data_0_out({valid_0, tag_0}),
        .read_addr_0(data_addr_0[7:0]),
        .data_1_out({valid_1, tag_1}),
        .read_addr_1(data_addr_1[7:0]),
        .ram_t0_we(ram256_t0_we),
        .ram_t0_addr(ram256_t0_addr),
        .ram_t0_data(ram256_t0_data),
        .ram_t1_we(ram256_t1_we),
        .ram_t1_addr(ram256_t1_addr),
        .ram_t1_data(ram256_t1_data)
    );

endmodule


module tag_controller (
   input wire clk,                     // Clock signal
   input wire rst,                     // Reset signal

   // Port 0: Write operation (W)
   input wire       write_enable,      // Enable write operation
   input wire [8:0] write_addr,        // Write address (9 bits)

   // Port 0: Read operation for address 0 (R)
   output reg [8:0] data_0_out,        // Data output for read operation on address 0 (9 bits)
   input  wire [7:0] read_addr_0,      // Read address for tag memory 0 (8 bits)

   // Port 1: Read operation for address 1 (R)
   output reg [8:0] data_1_out,        // Data output for read operation on address 1 (9 bits)
   input  wire [7:0] read_addr_1,      // Read address for tag memory 1 (8 bits)

   // RAM256_T0 (Tag Memory 0)
   output reg       ram_t0_we,         // Write enable for the RAM256_T0 (Tag RAM 0)
   output reg [7:0] ram_t0_addr,       // Address for the RAM256_T0 (Tag RAM 0)
   input  wire [7:0] ram_t0_data,      // Data read from the RAM256_T0 (Tag RAM 0)

   // RAM256_T1 (Tag Memory 1)
   output reg       ram_t1_we,         // Write enable for the RAM256_T1 (Tag RAM 1)
   output reg [7:0] ram_t1_addr,       // Address for the RAM256_T1 (Tag RAM 1)
   input  wire [7:0] ram_t1_data       // Data read from the RAM256_T1 (Tag RAM 1)
);
   reg [511:0] RAM;

   wire [7:0] tag_0_data;
   wire [7:0] tag_1_data;

   wire [7:0] tag_addr_0 = write_enable ? write_addr[7:0] : read_addr_0;
   wire [7:0] tag_addr_1 = write_enable ? write_addr[7:0] : read_addr_1;

   always @(posedge clk or posedge rst) begin
       if (rst) begin
           RAM <= 0;
       end else if (write_enable) begin
           RAM[write_addr] <= 1'b1;
       end
   end

   assign tag_0_data = ram_t0_data;
   assign tag_1_data = ram_t1_data;

   always @(*) begin
      ram_t0_addr=tag_addr_0;ram_t1_addr=tag_addr_1;
      data_0_out={RAM[{1'b0,read_addr_0}],tag_0_data};data_1_out={RAM[{1'b1,read_addr_1}],tag_1_data};
      ram_t0_we=write_enable&&!write_addr[8];ram_t1_we=write_enable&&write_addr[8];

   end

endmodule
