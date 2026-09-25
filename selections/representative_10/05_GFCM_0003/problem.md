# 비동기 클록 전환

ID: `cvdp_copilot_GFCM_0003`

원본 분류: ['cid004', 'easy']

## 원문

In the provided RTL, the clocks (clk1 and clk2) are assumed to be synchronous when performing glitch-free clock muxing. Modify the design for glitch-free clock switching to support asynchronous clocks. Retain the original `sel` signal functionality (when sel = 0, the output clock should be clk1, and when sel = 1, the output clock should be clk2.)

### Requirements:
* The clocks can be asynchronous. To prevent metastability, modify the RTL to use a two-flop clock synchronizer(s) for safe clock domain crossing between `clk1` and `clk2` .

Clock Domain Crossings:

The following table describes the clock domain crossings in the design for the internal `clk1_enable` and `clk2_enable` signals:

| Signal        | Launching Clock | Capturing Clock |
|---------------|-----------------|-----------------|
| `clk1_enable` | `clk1`          | `clk2`          |
| `clk2_enable` | `clk2`          | `clk1`          |

* `sel` signal:
    * In the provided RTL, `sel` signal is assumed to be driven by any of the two source clocks (`clk1` or `clk2`) So it's synchronous to both of them because clocks were synchronous.
    * Given `clk1` and `clk2` will be asynchronous, assume that `sel` will always be synchronous to one of the clocks, but asynchronous with respect to the other.

* When sel changes from 0 to 1, clk1 is disabled on the **second** positive edge of clk1 after the sel change. Subsequently, clk2 is enabled on the second positive edge of clk2 after clk1 is disabled.
* When sel changes from 1 to 0, clk2 is disabled on the **second** positive edge of clk2 after the sel change. Subsequently, clk1 is enabled on the second positive edge of clk1 after clk2 is disabled.
* Glitch-free switching from clk1 to clk2 example waveform is shown below
---
```wavedrom
{
    signal:[
        {name: "clk1", wave: "0.1.0.1.0.1.0.1.0.1.0.1.0.1.", period: 0.5, phase:0, },
        {name: "clk2", wave: "0..1.0..1.0..1.0..1.0..1.0..", period: 0.5, phase:0},
        {name: "sel", wave: "0..1........................", period: 0.5},
        { },
        {name: "clk1_en", wave: "1.........0.................", period: 0.5},
        {name: "clk2_en", wave: "0.................1.........", period: 0.5},
        { },
         {"name":"clkout", "wave" :"0.1.0.1.0.........1.0..1.0..", period:0.5, },
        
        ],
}
```

## 제공 코드

### rtl/glitch_free_mux.sv

```systemverilog
module glitch_free_mux
(
    input clk1,		//input clk1
    input clk2,		// input clk2
    input rst_n,	// async reset
    input sel,		// selection line
    output  clkout	// clock output
);

reg clkout_reg ;
reg clk1_enable, clk2_enable;
reg clk1_out, clk2_out ;


// CLK1 ENABLE LOGIC
always@(posedge clk1 or negedge rst_n  ) begin
        if (~rst_n) begin
            clk1_enable <= 0 ; 
        end else begin
            clk1_enable <= ~ clk2_enable & ~sel  ;
        end 
end

// CLK2 ENABLE LOGIC
always@(posedge clk2 or negedge rst_n  ) begin
       if (~rst_n) begin
           clk2_enable <= 0 ; 
       end else begin
           clk2_enable <= ~ clk1_enable & sel  ;
       end 
end

// OUTPUT LOGIC
assign clkout = (clk1 & clk1_enable) | (clk2 & clk2_enable) ;

endmodule

```
