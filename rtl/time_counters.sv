// time_counters.sv
// chains the digits together: each stage's carry_out drives the next
// stage's enable, just like a car odometer

module time_counters (
    input  logic clk,
    input  logic rst,
    input  logic tick_1hz,      // 1 pulse per second

    output logic [3:0] sec_ones,
    output logic [3:0] sec_tens,
    output logic [3:0] min_ones,
    output logic [3:0] min_tens,
    output logic [3:0] hour_ones,
    output logic [3:0] hour_tens
);

    logic sec_ones_carry, sec_tens_carry;
    logic min_ones_carry, min_tens_carry;

    bcd_digit_counter #(.MAX_COUNT(9)) u_sec_ones (
        .clk(clk), .rst(rst), .enable(tick_1hz),
        .count(sec_ones), .carry_out(sec_ones_carry)
    );

    bcd_digit_counter #(.MAX_COUNT(5)) u_sec_tens (
        .clk(clk), .rst(rst), .enable(sec_ones_carry),
        .count(sec_tens), .carry_out(sec_tens_carry)
    );

    bcd_digit_counter #(.MAX_COUNT(9)) u_min_ones (
        .clk(clk), .rst(rst), .enable(sec_tens_carry),
        .count(min_ones), .carry_out(min_ones_carry)
    );

    bcd_digit_counter #(.MAX_COUNT(5)) u_min_tens (
        .clk(clk), .rst(rst), .enable(min_ones_carry),
        .count(min_tens), .carry_out(min_tens_carry)
    );

    hours_counter u_hours (
        .clk(clk), .rst(rst), .enable(min_tens_carry),
        .hours_ones(hour_ones), .hours_tens(hour_tens),
        .carry_out()             // unused for now, useful later for an alarm/midnight event
    );

endmodule