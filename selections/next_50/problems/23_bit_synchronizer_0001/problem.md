# 23. 다단 비트 동기화기

ID: `cvdp_copilot_bit_synchronizer_0001`

난이도: easy / 분류: cid002 / 묶음: 3

선정 이유: 클록 도메인 간 제어 신호 전달

## 문제 원문

Complete the provided SystemVerilog code for the `bit_sync` module, which implements a multi-stage signal synchronizer between two clock domains (`aclk` and `bclk`). The synchronizer uses two independent synchronization chains (`a_sync_chain` and `b_sync_chain`) to handle metastability and ensure reliable signal transfer. Below are the specifications and requirements for the completion of this module.

---

## Parameters

| **Parameter** | **Description**                                | **Default Value** | **Constraint**                  |
|---------------|-----------------------------------------------|--------------------|----------------------------------|
| `STAGES`      | Number of synchronization stages              | 2                  | Must be $\geq 2$ for proper metastability handling. |

---

## Ports

| **Port**      | **Direction** | **Size**       | **Description**                                                        |
|---------------|---------------|----------------|------------------------------------------------------------------------|
| `aclk`        | Input         | 1 bit          | Clock for the `a_sync_chain`, active on the rising edge.               |
| `bclk`        | Input         | 1 bit          | Clock for the `b_sync_chain`, active on the rising edge.               |
| `rst_n`       | Input         | 1 bit          | Active-low reset, asynchronously clears all synchronization registers. |
| `adata`       | Input         | 1 bit          | Signal from the `aclk` domain to be synchronized.                      |
| `aq2_data`    | Output        | 1 bit          | Signal synchronized into the `aclk` domain.                           |
| `bq2_data`    | Output        | 1 bit          | Signal synchronized into the `bclk` domain.                           |

---

## Module Description

The `bit_sync` module synchronizes a single-bit signal (`adata`) across two different clock domains (`aclk` and `bclk`) using two independent synchronization chains:
1. **`b_sync_chain`**:
   - Operates in the `bclk` domain.
   - Synchronizes the signal `adata` into the `bclk` domain.
   - Provides output `bq2_data`.

2. **`a_sync_chain`**:
   - Operates in the `aclk` domain.
   - Synchronizes the signal `bq2_data` into the `aclk` domain.
   - Provides output `aq2_data`.

---

## Reset Behavior

The reset signal `rst_n` is active-low and asynchronously clears both synchronization chains (`a_sync_chain` and `b_sync_chain`). This ensures all internal signals are set to `0` during initialization or when the reset is triggered.

---

## Completion Requirements

1. **Synchronization for `aclk` Domain**:
   - Implement the `a_sync_chain` to synchronize the `bq2_data` signal into the `aclk` domain.
   - Ensure `aq2_data` is driven by the last stage of the `a_sync_chain`.

2. **Clock Edge Specification**:
   - The synchronization chains must operate on the **rising edge** of their respective clocks (`aclk` for `a_sync_chain` and `bclk` for `b_sync_chain`).

3. **Reset Implementation**:
   - Both `a_sync_chain` and `b_sync_chain` must be cleared when `rst_n` is deasserted (active-low).

4. **Multi-Stage Synchronization**:
   - Ensure that the `STAGES` parameter is consistently applied to both synchronization chains.
   - The length of the synchronization chains must be exactly `STAGES`.

---

The following partial code represents the current state of the `bit_sync` module. Complete the missing logic for the `a_sync_chain` synchronization and verify adherence to the above requirements.

```systemverilog
module bit_sync #(
    parameter STAGES = 2
) (
    input  logic aclk,    
    input  logic bclk,    
    input  logic rst_n,   
    input  logic adata,   
    output logic aq2_data,
    output logic bq2_data 
);

    logic [STAGES-1:0] a_sync_chain, b_sync_chain;

    // Synchronization for bclk domain
    always_ff @(posedge bclk or negedge rst_n) begin
        if (!rst_n)
            b_sync_chain <= {STAGES{1'b0}};
        else
            b_sync_chain <= {b_sync_chain[STAGES-2:0], adata};
    end

    assign bq2_data = b_sync_chain[STAGES-1];

    // Insert the synchronization logic for aclk domain here

endmodule

## 제공 코드·문서

