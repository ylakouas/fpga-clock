// hours_counter.sv
// hours don't fit the generic digit pattern - they wrap at 23->00,
// not at a clean 9->0 or 5->0 boundary, so this one is hand-written
// instead of reusing bcd_digit_counter

module hours_counter (
    input  logic clk,
    input  logic rst,
    input  logic enable,
    output logic [3:0] hours_ones,
    output logic [3:0] hours_tens,
    output logic carry_out         // pulses at 23->00 (midnight)
);

    always_ff @(posedge clk) begin
        if (rst) begin
            hours_ones <= 4'd0;
            hours_tens <= 4'd0;
            carry_out  <= 1'b0;
        end else if (enable) begin
            if (hours_tens == 4'd2 && hours_ones == 4'd3) begin
                // 23 -> 00, the special wrap
                hours_ones <= 4'd0;
                hours_tens <= 4'd0;
                carry_out  <= 1'b1;
            end else if (hours_ones == 4'd9) begin
                // ones hits 9, tens bumps up (covers 09->10 and 19->20)
                hours_ones <= 4'd0;
                hours_tens <= hours_tens + 1'b1;
                carry_out  <= 1'b0;
            end else begin
                hours_ones <= hours_ones + 1'b1;
                carry_out  <= 1'b0;
            end
        end else begin
            carry_out <= 1'b0;
        end
    end

endmodule