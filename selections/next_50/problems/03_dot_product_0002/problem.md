# 03. 벡터 내적 계산기

ID: `cvdp_copilot_dot_product_0002`

난이도: easy / 분류: cid002 / 묶음: 1

선정 이유: 곱셈·누산과 출력 폭

## 문제 원문

Complete the given partial SystemVerilog code for a dot product computation module. The module computes the dot product of two input vectors, which support integer values only, where the length of the vectors is specified dynamically. It processes the inputs based on their validity signals, accumulates the results, and outputs the final dot product along with a valid signal.

---

#### **Design Specifications**

1. The module processes two input vectors (`vector_a_in` and `vector_b_in`) of lengths specified by `dot_length_in`.
2. A state machine controls the computation, operating in the following states:
   - **IDLE**: Waits for the `start_in` signal to begin computation.
   - **COMPUTE**: Iteratively computes the dot product by accumulating the products of corresponding elements of the input vectors.
3. **Output Behavior**:
   - In the **OUTPUT state**, the computed 32-bit dot product is assigned to the output, and a valid signal is asserted HIGH to indicate that the result is valid.
4. **Latency**:
   - Output Latency is two clock cycles.

---

#### **Example Operations**

**Example 1**: Valid Dot Product Computation  
- **Input**:  
  - `vector_a_in = [8'h02, 8'h03, 8'h04]`
  - `vector_b_in = [16'h0005, 16'h0006, 16'h0007]`  
  - `dot_length_in = 7'h03`, `start_in = 1`  
- **Expected Output**:  
  - `dot_product_out = [2*5 + 3*6 + 4*7] = 32'h00000038`, `dot_product_valid_out = 1`

**Example 2**: Active HIGH Reset Behavior  
- **Input**: `reset_in = 1`  
- **Expected Output**:  
  - `dot_product_out = 32'h00000000`, `dot_product_valid_out = 0`

---

#### **Partial Code Snippet**

```systemverilog
module dot_product (
    input               clk_in,                     // Clock signal
    input               reset_in,                   // Asynchronous Reset signal, Active HIGH
    input               start_in,                   // Start computation signal
    input       [6:0]   dot_length_in,              // Length of the dot product vectors
    input       [7:0]   vector_a_in,                // Input vector A (8-bit)
    input               vector_a_valid_in,          // Valid signal for vector A
    input       [15:0]  vector_b_in,                // Input vector B (16-bit)
    input               vector_b_valid_in,          // Valid signal for vector B
    output reg  [31:0]  dot_product_out,            // Output dot product result (32-bit)
    output reg          dot_product_valid_out       // Valid signal for dot product output
);

    typedef enum logic [1:0] {
        IDLE    = 2'b00,
        COMPUTE = 2'b01,
        OUTPUT  = 2'b10
    } state_t;

    state_t state;
    
    // Insert code here to compute the dot product
```

## 제공 코드·문서

