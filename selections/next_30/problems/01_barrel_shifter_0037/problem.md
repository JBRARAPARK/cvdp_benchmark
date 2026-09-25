# 01. 시프트·회전 기능 확장

ID: `cvdp_copilot_barrel_shifter_0037`

난이도: easy / 분류: cid004

## 문제 원문

Modify the RTL code `barrel_shifter_8bit` to include additional functionality for **left and right rotate** operations (in addition to the standard shifts) and to support a wider range of applications through parameterization. The enhanced RTL module `barrel_shifter` should consider the following specifications.

### 1. Support for Rotate Operations:
Introduce a new control signal, `rotate_left_right`, into the design. This signal will dictate whether the operation is a standard shift (`rotate_left_right` = 0) or a rotate operation (`rotate_left_right` = 1). In the case of a rotate operation, the bits shifted out from one end of the `data_in` register should wrap around and be reinserted at the opposite end.

### 2. Dual Control for Shift/Rotate Directions:
The existing `left_right` control signal should be reused to determine the direction of the operation:
- When `left_right` is high (`1`), perform a left shift or rotate.
- When `left_right` is low (`0`), perform a right shift or rotate.

### 3. Parameterization of data and shift bits widths:
Ensure that the modified design supports parameterization of both the data width (`data_width`) and the shift bit width (`shift_bits_width`). This allows the RTL to be reused for different input sizes and shift lengths without modifying the core logic.
- The default value of the `data_width` is 16 and the minimum possible value is 1
- The default value of the `shift_bits_width` is 4 and the minimum possible value is 1
- The design has to support a minimum value of 0 for `shift_bits`, which enables no shifting of the given data

## 제공 코드

### rtl/barrel_shifter_8bit.sv

```systemverilog
module barrel_shifter_8bit(input [7:0]data_in,input [2:0] shift_bits, input left_right, output [7:0]data_out);
assign data_out = left_right ? (data_in << shift_bits) : (data_in >> shift_bits);
endmodule
  
```
