// time_counters.sv
// chains the digits together: each stage's carry_out drives the next
// stage's enable, just like a car odometer.
// hour_inc/min_inc let SET mode bump a digit manually - it uses the
// exact same carry mechanism as normal ticking.
// sec_clear zeroes just the seconds when leaving SET mode.

module time_counters (
    input  logic clk,
    input  logic rst,
    input  logic tick_1hz,
    input  logic hour_inc,
    input  logic min_inc,
    input  logic sec_clear,

    output logic [3:0] sec_ones, sec_tens,
    output logic [3:0] min_ones, min_tens,
    output logic [3:0] hour_ones, hour_tens
);

    logic sec_ones_carry, sec_tens_carry;
    logic min_ones_carry, min_tens_carry;

    logic sec_rst;
    assign sec_rst = rst | sec_clear;   // seconds also clear leaving SET mode

    bcd_digit_counter #(.MAX_COUNT(9)) u_sec_ones (
        .clk(clk), .rst(sec_rst), .enable(tick_1hz),
        .count(sec_ones), .carry_out(sec_ones_carry)
    );

    bcd_digit_counter #(.MAX_COUNT(5)) u_sec_tens (
        .clk(clk), .rst(sec_rst), .enable(sec_ones_carry),
        .count(sec_tens), .carry_out(sec_tens_carry)
    );

    bcd_digit_counter #(.MAX_COUNT(9)) u_min_ones (
        .clk(clk), .rst(rst), .enable(sec_tens_carry | min_inc),
        .count(min_ones), .carry_out(min_ones_carry)
    );

    bcd_digit_counter #(.MAX_COUNT(5)) u_min_tens (
        .clk(clk), .rst(rst), .enable(min_ones_carry),
        .count(min_tens), .carry_out(min_tens_carry)
    );

    hours_counter u_hours (
        .clk(clk), .rst(rst), .enable(min_tens_carry | hour_inc),
        .hours_ones(hour_ones), .hours_tens(hour_tens),
        .carry_out()
    );

endmodule