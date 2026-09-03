// bcd_digit_counter.sv
// one digit, 0 up to MAX_COUNT, then wraps back to 0 and pulses carry_out
// for exactly 1 cycle - carry_out feeds the next digit's enable, this is
// the odometer trick: each digit only moves when the one before it wraps

module bcd_digit_counter #(
    parameter int MAX_COUNT = 9   // 9 for ones places, 5 for tens-of-60
) (
    input  logic clk,
    input  logic rst,
    input  logic enable,          // pulse - "count me now"
    output logic [3:0] count,
    output logic carry_out        // 1 cycle pulse when this digit wraps
);

    always_ff @(posedge clk) begin
        if (rst) begin
            count     <= 4'd0;
            carry_out <= 1'b0;
        end else if (enable) begin
            if (count == MAX_COUNT) begin
                count     <= 4'd0;
                carry_out <= 1'b1;   // tell the next digit to move
            end else begin
                count     <= count + 1'b1;
                carry_out <= 1'b0;
            end
        end else begin
            carry_out <= 1'b0;      // no enable = stay put, carry stays low
        end
    end

endmodule