// clock_top.sv
// wires time_counters -> display_mux -> physical pins
// shows HH MM SS across the 8 digits - 2 leftmost stay blank since we
// only have 6 real time digits and no colon LEDs on this board

module clock_top (
    input  logic clk,

    output logic [3:0] D0_AN,
    output logic [7:0] D0_SEG,
    output logic [3:0] D1_AN,
    output logic [7:0] D1_SEG
);

    logic rst;
    assign rst = 1'b0;   // no reset button wired yet - comes Saturday

    logic tick_1hz, tick_refresh;

    // real 1Hz - 100,000,000 clocks per tick
    clk_en #(
        .DIVISOR(100_000_000)
    ) one_second (
        .clk  (clk),
        .rst  (rst),
        .tick (tick_1hz)
    );

    // ~1kHz display refresh, same as the bring-up test
    clk_en #(
        .DIVISOR(100_000)
    ) refresh (
        .clk  (clk),
        .rst  (rst),
        .tick (tick_refresh)
    );

    logic [3:0] sec_ones, sec_tens, min_ones, min_tens, hour_ones, hour_tens;

    time_counters clock_core (
        .clk      (clk),
        .rst      (rst),
        .tick_1hz (tick_1hz),
        .sec_ones (sec_ones), .sec_tens (sec_tens),
        .min_ones (min_ones), .min_tens (min_tens),
        .hour_ones(hour_ones), .hour_tens(hour_tens)
    );

    // digit0 = rightmost on the board, digit3 = leftmost of its half
    // (confirmed on hardware in the bring-up test)
    // left half  (D0): blank, blank, hour_tens, hour_ones
    // right half (D1): min_tens, min_ones, sec_tens, sec_ones
    // reads left to right as: [blank][blank] HH MM SS
    display_mux screen (
        .clk    (clk),
        .rst    (rst),
        .tick   (tick_refresh),

        .digit0 (hour_ones),
        .digit1 (hour_tens),
        .digit2 (4'd15),   // blank - outside 0-9, decoder turns segments off
        .digit3 (4'd15),   // blank

        .digit4 (sec_ones),
        .digit5 (sec_tens),
        .digit6 (min_ones),
        .digit7 (min_tens),

        .d0_an  (D0_AN), .d0_seg (D0_SEG),
        .d1_an  (D1_AN), .d1_seg (D1_SEG)
    );

endmodule