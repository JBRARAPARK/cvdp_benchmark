module lfsr_8bit (
    input wire clock,
    input wire reset,
    input wire [7:0] lfsr_seed,
    output reg [7:0] lfsr_out
);
    // Right shift and apply the specified Galois feedback taps.
    always @(posedge clock or negedge reset) begin
        if (!reset)
            lfsr_out <= lfsr_seed;
        else
            lfsr_out <= {1'b0, lfsr_out[7:1]} ^
                        (8'hB1 & {8{lfsr_out[0]}});
    end
endmodule
