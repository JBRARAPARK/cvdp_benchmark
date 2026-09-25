# 4탭 FIR 필터

ID: `cvdp_copilot_FIR_0001`

원본 분류: ['cid002', 'easy']

## 원문

Complete the fir_filter module in SystemVerilog, designed to perform finite impulse response (FIR) filtering, the module uses an asynchronous, active-high reset and should handle signal processing.

---

Module Interface:

Inputs:

- clk: System clock (logic).
- reset: Asynchronous, active-high reset signal (logic).
- input_sample [15:0]: Signed 16-bit current input sample (logic signed [15:0]).
- coeff0 [15:0]: Coefficient for the current input sample (logic signed [15:0]).
- coeff1 [15:0]: Coefficient for the first delay element (logic signed [15:0]).
- coeff2 [15:0]: Coefficient for the second delay element (logic signed [15:0]).
- coeff3 [15:0]: Coefficient for the third delay element (logic signed [15:0]).

Output:

- output_sample [15:0]: Output filtered sample, signed 16-bit (logic signed [15:0]).
---
Internal Registers and Signals:

Registers:

- sample_delay1 [15:0]: First delayed sample register (logic signed [15:0]).
- sample_delay2 [15:0]: Second delayed sample register (logic signed [15:0]).
- sample_delay3 [15:0]: Third delayed sample register (logic signed [15:0]).
- accumulator [31:0]: 32-bit accumulator for summing the products of coefficients and samples (logic signed [31:0]).
---

Functionality:

Reset Logic:

- Implement logic to zero all registers (sample_delay1, sample_delay2, sample_delay3, accumulator) and output_sample when the reset is asserted.

Data Propagation:

- Handle the shifting of input samples into delay registers on each clock edge

Accumulation Logic:

- Perform the multiplication of samples by their respective coefficients and accumulate the results in the accumulator.

Output Assignment and Latency Specification:

- Assign the accumulated result to output_sample, ensuring that the output is exactly 4 clock cycles after the input sample is first registered, thereby defining the latency of the FIR filter.

---

```

module fir_filter (
    input logic clk,                 // Clock signal
    input logic reset,               // Reset signal
    input logic signed [15:0] input_sample,  // Input data sample
    output logic signed [15:0] output_sample, // Output filtered sample
    input logic signed [15:0] coeff0, // Coefficient for current input sample
    input logic signed [15:0] coeff1, // Coefficient for first delay
    input logic signed [15:0] coeff2, // Coefficient for second delay
    input logic signed [15:0] coeff3  // Coefficient for third delay
);

    // Declare internal storage for delay elements and accumulation
    logic signed [15:0] sample_delay1, sample_delay2, sample_delay3;
    logic signed [31:0] accumulator;

    // Sequential block to handle operations on clock or reset
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset state: Clear all registers and output
        end else begin
            // Regular operation: Shift samples, compute filtered output
        end
    end

endmodule

```

## 제공 코드
