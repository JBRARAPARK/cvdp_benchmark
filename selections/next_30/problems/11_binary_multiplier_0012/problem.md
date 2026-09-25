# 11. 곱셈기 순차회로 전환

ID: `cvdp_copilot_binary_multiplier_0012`

난이도: easy / 분류: cid004

## 문제 원문

The current `binary_multiplier` is a combinational design that generates the `Product` output instantly when `valid_in` is asserted and inputs `A` and `B` are applied. The task is to convert this design to a **sequential approach** in SystemVerilog. In this new design, the `Product` output should be generated over multiple clock cycles, with a total latency of **WIDTH + 2** cycles.

### Task Details

**Parameterization**  
- `WIDTH`: Specifies the bit-width of operands `A` and `B`.
  - Default: 32
  - Minimum: 1

**Sequential Approach**  
1. **Computation, Accumulation, and Output Stage**
   - Latch `valid_in` to an internal `start` signal to initiate the operation and keep it active until the calculation is complete.
   - When `valid_in` is asserted, latch `A` and `B` to internal registers.
   - When `start` is high, perform both shift and accumulation operations over multiple clock cycles:
     - Use the same add-shift algorithm for multiplication: for each bit in the latched A, check the bit’s position. If a bit is 1, shift the latched value of B by the bit’s position and add the result to an accumulated sum.
     - Continue these shift-and-sum operations for `WIDTH` cycles until the final result is accumulated.
   - Register the accumulated result in `Product` on the `WIDTH + 2` clock cycle, making it available as the final output.

2. **Valid Signal Behavior**
   - Latch `valid_in` to the `start` signal at the beginning of the operation. `start` remains high throughout the calculation.
   - The `valid_out` signal goes high on the `WIDTH + 2` clock cycle to indicate that `Product` is fully computed and valid.

3. **Reset Behavior**
   - `rst_n`: Active-low asynchronous reset. When asserted low, it immediately clears all registers and outputs, including `Product`, `valid_out`, and internal registers.

### Inputs and Outputs

- **Inputs**:
  - `clk`: Clock signal for synchronization. The design is synchronized to the positive edge of this clock.
  - `rst_n`: Active-low asynchronous reset.
  - `valid_in`: An active high signal indicating that inputs `A` and `B` are valid and ready for multiplication.
  - `A`, `B [WIDTH-1:0]`: Operands `A`, `B`.
  
- **Outputs**:
  - `valid_out`: An active high signal that indicates when `Product` is valid.
  - `Product [2*WIDTH-1:0]`: Final multiplication result.

### Additional Details

- **Control Signal Behavior**:
  - Both `valid_in` and `valid_out` are asserted high for one cycle.
  - Once `valid_out` is asserted, new inputs will be fed to the system on the next rising edge of `clk` following this assertion. 

## 제공 코드

### rtl/binary_multiplier.sv

```systemverilog
module binary_multiplier #(
    parameter WIDTH = 32  // Set the width of inputs
)(
    input  logic [WIDTH-1:0]   A,          // Input A
    input  logic [WIDTH-1:0]   B,          // Input B
    input  logic               valid_in,   // Indicates when inputs are valid
    output logic [2*WIDTH-1:0] Product,    // Output Product
    output logic               valid_out   // Output valid
);

integer i;
logic [2*WIDTH-1:0] sum;  // Intermediate sum for unsigned multiplication

always @(*) begin
    sum = 0;  // Initialize sum to zero
    if (valid_in) begin
        for (i = 0; i < WIDTH; i = i + 1) begin
            if (A[i]) begin
                sum = sum + (B << i);  // Add shifted value of B
            end
        end
      
        Product = sum;  // Assign the final sum as the product
        valid_out = 1'b1;
    end else begin
        Product = 0;  // When valid_in is deasserted, output should be zero
        valid_out = 1'b0;
    end
end

endmodule
```
