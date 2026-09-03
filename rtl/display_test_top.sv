// display_test_top.sv
// bring-up test only - not the final design
// lights all 8 digits with a fixed pattern so we can see, on the
// real board, which physical digit is which

module display_test_top (
    input  logic clk,

    output logic [3:0] D0_AN,
    output logic [7:0] D0_SEG,
    output logic [3:0] D1_AN,
    output logic [7:0] D1_SEG
);

    logic tick;

    // 100,000,000 / 100,000 = 1,000 Hz refresh
    clk_en #(
        .DIVISOR(100_000)
    ) refresh_tick (
        .clk  (clk),
        .rst  (1'b0),
        .tick (tick)
    );

    // each position shows its own number - read them straight off the board
    display_mux mux (
        .clk    (clk),
        .rst    (1'b0),
        .tick   (tick),

        .digit0 (4'd0),
        .digit1 (4'd1),
        .digit2 (4'd2),
        .digit3 (4'd3),
        .digit4 (4'd4),
        .digit5 (4'd5),
        .digit6 (4'd6),
        .digit7 (4'd7),

        .d0_an  (D0_AN),
        .d0_seg (D0_SEG),
        .d1_an  (D1_AN),
        .d1_seg (D1_SEG)
    );

endmodule