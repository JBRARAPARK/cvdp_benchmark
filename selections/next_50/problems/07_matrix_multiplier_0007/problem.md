# 07. 행렬 곱셈기 순차화

ID: `cvdp_copilot_matrix_multiplier_0007`

난이도: easy / 분류: cid004 / 묶음: 1

선정 이유: 행렬 인덱스와 완료 제어

## 문제 원문

Modify the existing combinational matrix multiplier, named `matrix_multiplier`, to a multi-cycle sequential design using **SystemVerilog**. In the original combinational design, the output is updated instantly when input matrices are provided. The required modification should introduce sequential stages, distributing the computation across multiple clock cycles, resulting in a total latency of **`COL_A + 2` clock cycles**. This approach is required to improve timing performance and manage larger matrices. 

---

**Conversion Requirements:**
 
**Task Details:**

1. **Computational Stages:**
   - Implement three stages in the design: multiplication, accumulation, and output.
   - In the **multiplication stage**, compute the unsigned products of all corresponding elements from `matrix_a` and `matrix_b` in 1 clock cycle. These results should be stored in intermediate registers. 
   - In the **accumulation stage**, add the unsigned products across multiple cycles (over `COL_A` clock cycles) to get the final values for each element in `matrix_c`.
   - In the **output stage**, register the accumulated result and output it, in 1 clock cycle.
   - Ensure that the output matrix `matrix_c` is valid after **`COL_A + 2` clock cycles**.

2. **Valid Signal Propagation:**
   - The valid signal `valid_in` needs to be propagated through the computational stages to ensure that `valid_out` is asserted at the end of the calculation, after **`COL_A + 2` clock cycles**. Assume that the `valid_in` will be high for 1 clock cycle for a valid input matrix combination.
   - Implement a shift register to match the latency.

3. **Reset Behavior:**
   - When the synchronous reset (`srst`) is asserted, all registers (including intermediate multiplication and accumulation registers) and the outputs should be reset to their initial state 0 on the next rising clock edge.

---
**New interface:**

**Inputs:**
- **clk:** Clock signal used to synchronize the computational stages.
- **srst:** Active-high synchronous reset. When high, it clears the internal registers and outputs.
- **valid_in:** Active high signal indicating that the input matrices are valid and ready to be processed. 
- **matrix_a[(ROW_A x COL_A x INPUT_DATA_WIDTH) -1 :0]:** Flattened input matrix A, containing unsigned elements.
- **matrix_b[(ROW_B x COL_B x INPUT_DATA_WIDTH) -1 :0]:** Flattened input matrix B, containing unsigned elements.

**Outputs:**
- **valid_out:** Active high signal indicating that the output matrix is valid and ready.
- **matrix_c[(ROW_A x COL_B x OUTPUT_DATA_WIDTH) -1 :0]:** Flattened output matrix C, containing unsigned elements, with the final results of the matrix multiplication. The output should be updated along with `valid_out` assertion.

**Timing and Synchronization:**
- **Clock Signal:** All p stages (multiplication, accumulation, and output) should be synchronized to the rising edge of the clock (`clk`).
- **Latency:** The total latency from `valid_in` to `valid_out` should be **`COL_A + 2` cycles** .

**Constraints:**
- **Input Control:** New inputs will only be applied from the next cycle following the assertion of `valid_out`, signaling that the module is ready for a new calculation.

## 제공 코드·문서

### rtl/matrix_multiplier.sv

```systemverilog
module matrix_multiplier #(
  parameter ROW_A             = 4                                                   , // Number of rows in matrix A
  parameter COL_A             = 4                                                   , // Number of columns in matrix A
  parameter ROW_B             = 4                                                   , // Number of rows in matrix B
  parameter COL_B             = 4                                                   , // Number of columns in matrix B
  parameter INPUT_DATA_WIDTH  = 8                                                   , // Bit-width of input data
  parameter OUTPUT_DATA_WIDTH = (INPUT_DATA_WIDTH * 2) + $clog2(COL_A)                // Bit-width of output data
) (
  input  logic [ (ROW_A*COL_A*INPUT_DATA_WIDTH)-1:0] matrix_a, // Input matrix A in 1D form
  input  logic [ (ROW_B*COL_B*INPUT_DATA_WIDTH)-1:0] matrix_b, // Input matrix B in 1D form
  output logic [(ROW_A*COL_B*OUTPUT_DATA_WIDTH)-1:0] matrix_c  // Output matrix C in 1D form
);
  genvar gv1;
  genvar gv2;
  genvar gv3;

  generate
      logic [(ROW_A*COL_B*COL_A*OUTPUT_DATA_WIDTH)-1:0] matrix_c_stage; // Temporary storage for intermediate results

      for (gv1 = 0 ; gv1 < ROW_A ; gv1++) begin: row_a_gb
        for (gv2 = 0 ; gv2 < COL_B ; gv2++) begin: col_b_gb
          for (gv3 = 0 ; gv3 < COL_A ; gv3++) begin: col_a_gb
            if (gv3 == 0)
              assign matrix_c_stage[((((gv1*COL_B)+gv2)*COL_A)+gv3)*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH] = matrix_a[((gv1*COL_A)+gv3)*INPUT_DATA_WIDTH+:INPUT_DATA_WIDTH] * matrix_b[((gv3*COL_B)+gv2)*INPUT_DATA_WIDTH+:INPUT_DATA_WIDTH];
            else
              assign matrix_c_stage[((((gv1*COL_B)+gv2)*COL_A)+gv3)*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH] = matrix_c_stage[((((gv1*COL_B)+gv2)*COL_A)+(gv3-1))*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH] + (matrix_a[((gv1*COL_A)+gv3)*INPUT_DATA_WIDTH+:INPUT_DATA_WIDTH] * matrix_b[((gv3*COL_B)+gv2)*INPUT_DATA_WIDTH+:INPUT_DATA_WIDTH]);
          end
          // Assign the final result for matrix_c
          assign matrix_c[((gv1*COL_B)+gv2)*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH] = matrix_c_stage[((((gv1*COL_B)+gv2)*COL_A)+(COL_A-1))*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH];
        end
      end

  endgenerate

endmodule
```

