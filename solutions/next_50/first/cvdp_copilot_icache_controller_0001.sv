module updates its internal states and outputs on the rising edge of this signal.
- **rst**: A 1-bit active-high asynchronous reset signal that initializes the module to its default state when asserted.
- **write_enable**: A 1-bit input signal that enables writing new tag and validity information into the tag memory when asserted.
- **[8:0] write_addr**: A 9-bit input address specifying the location in the tag memory where new tag and validity data should be written.
- **[7:0] read_addr_0**: An 8-bit input address that specifies the location in the first tag memory block to retrieve tag and validity information.
- **[7:0] read_addr_1**: An 8-bit input address that specifies the location in the second tag memory block to retrieve tag and validity information.
- **[7:0] data_in_0**: An 8-bit input signal providing tag or validity information from the first tag memory block for validation purposes.
- **[7:0] data_in_1**: An 8-bit input signal providing tag or validity information from the second tag memory block for validation purposes.

#### **Outputs**
- **[8:0] data_out_0**: A 9-bit output signal combining the tag and validity bit retrieved from the first tag memory block.
- **[8:0] data_out_1**: A 9-bit output signal combining the tag and validity bit retrieved from the second tag memory block.
- **write_enable_0**: A 1-bit output signal that enables writing tag and validity information into the first tag memory block.
- **write_enable_1**: A 1-bit output signal that enables writing tag and validity information into the second tag memory block.
- **[7:0] addr_out_0**: An 8-bit output signal specifying the address in the first tag memory block to read or write data.
- **[7:0] addr_out_1**: An 8-bit output signal specifying the address in the second tag memory block to read or write data.

## Design Overview

### `instruction_cache_controller`
1. **State Machine**:
    - The FSM operates in multiple states to handle cache hits and misses:
      - **IDLE**: The controller is ready to process new L1 cache requests.
      - **READMEM0**: Initiates a memory fetch for the first part of a cache line on a miss.
      - **READMEM1**: Fetches the second part of the cache line from memory.
      - **READCACHE**: Processes fetched data and checks for validity.
    - State transitions occur based on memory readiness and cache lookup results.

2. **Cache Line Management**:
    - The controller interacts with the tag controller to validate cache lines.
    - On a cache miss, it updates tags and validity bits and fetches the required cache line from memory.

3. **Data Handling**:
    - Data from memory or the cache is returned to the L1 cache.
    - Unaligned accesses are supported by swapping data parts based on the least significant bit (LSB) of the input address.

### `tag_controller`
1. **Tag Validation**:
    - The module retrieves tag and validity information from two separate tag memory blocks using the input addresses. The output signals combine the retrieved tag and validity information for validation purposes.

2. **Tag Updates**:
    - When a cache miss occurs, the module updates the tag memory with new tag and validity data. The input address and enable signals determine the location and whether the write operation occurs.

3. **Memory Interaction**:
    - The module controls address selection and write enable signals for the tag memory blocks to perform read or write operations as required.

## Implementation Instructions

### `instruction_cache_controller`
1. **State Machine Logic**:
    - Implement state transitions for handling cache hits, misses, and fetching data from memory. Ensure smooth transitions between IDLE, memory fetch, and data validation states.

2. **Unaligned Access Handling**:
    - Add logic to handle unaligned memory accesses by rearranging data appropriately before output.

3. **Memory Operations**:
    - Enable memory read/write signals during fetch operations and ensure fetched data is stored in the cache memory.

### `tag_controller`
1. **Address Decoding**:
    - Implement address decoding for reading and writing tag data from/to the SRAM.

2. **Tag and Valid Bit Output**:
    - Combine tag and valid bits during read operations for cache validation checks.

3. **Write Logic**:
    - Ensure correct writing of tag and valid bits during updates or cache line replacements.

## Assumptions
1. The module assumes all input signals are valid and synchronized to the clock.
2. Cache size and associativity are fixed, with tags and data stored in dedicated RAM blocks.
3. Unaligned data handling is required, and correctness is verified based on input address alignment.

```
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
