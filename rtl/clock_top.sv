// clock_top.sv
// full clock: displays HH:MM:SS, btn0=reset, btn1=mode, btn2=increment
// buttons go through sync+debounce+edge before touching any logic

module clock_top (
    input  logic clk,
    input  logic [3:0] btn,   // btn[0]=reset, btn[1]=mode, btn[2]=inc

    output logic [3:0] D0_AN,
    output logic [7:0] D0_SEG,
    output logic [3:0] D1_AN,
    output logic [7:0] D1_SEG
);

    logic rst;
    assign rst = 1'b0;   // power-on reset only - btn0 handles user reset

    // --- clock enables ---
    logic tick_1hz, tick_refresh, tick_debounce;

    clk_en #(.DIVISOR(100_000_000)) one_second (
        .clk(clk), .rst(rst), .tick(tick_1hz)
    );

    clk_en #(.DIVISOR(100_000)) refresh (
        .clk(clk), .rst(rst), .tick(tick_refresh)
    );

    // ~200Hz debounce sample rate - slow enough to ride out real bounce,
    // fast enough that button presses still feel instant
    clk_en #(.DIVISOR(500_000)) debounce_sample (
        .clk(clk), .rst(rst), .tick(tick_debounce)
    );

    // --- button chain, one per button ---
    logic [3:0] btn_sync, btn_clean;
    logic reset_pulse, mode_pulse, inc_pulse;

    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : btn_chain
            synchronizer u_sync (
                .clk(clk), .async_in(btn[i]), .sync_out(btn_sync[i])
            );
            debouncer #(.STABLE_COUNT(20)) u_debounce (
                .clk(clk), .rst(rst), .tick(tick_debounce),
                .noisy_in(btn_sync[i]), .clean_out(btn_clean[i])
            );
        end
    endgenerate

    edge_detector u_edge0 (
        .clk(clk), .rst(rst), .level_in(btn_clean[0]), .pulse_out(reset_pulse)
    );
    edge_detector u_edge1 (
        .clk(clk), .rst(rst), .level_in(btn_clean[1]), .pulse_out(mode_pulse)
    );
    edge_detector u_edge2 (
        .clk(clk), .rst(rst), .level_in(btn_clean[2]), .pulse_out(inc_pulse)
    );

    // --- control FSM ---
    logic run_en, hour_inc, min_inc, full_clear, sec_clear;

    clock_control ctrl (
        .clk(clk), .rst(rst),
        .reset_pulse(reset_pulse), .mode_pulse(mode_pulse), .inc_pulse(inc_pulse),
        .run_en(run_en), .hour_inc(hour_inc), .min_inc(min_inc),
        .full_clear(full_clear), .sec_clear(sec_clear)
    );

    // --- time counters ---
    logic [3:0] sec_ones, sec_tens, min_ones, min_tens, hour_ones, hour_tens;

    time_counters clock_core (
        .clk(clk), .rst(rst | full_clear),
        .tick_1hz(tick_1hz & run_en),   // only actually count while in RUN
        .hour_inc(hour_inc), .min_inc(min_inc), .sec_clear(sec_clear),
        .sec_ones(sec_ones), .sec_tens(sec_tens),
        .min_ones(min_ones), .min_tens(min_tens),
        .hour_ones(hour_ones), .hour_tens(hour_tens)
    );

    // --- display ---
    display_mux screen (
        .clk(clk), .rst(rst), .tick(tick_refresh),
        .digit0(hour_ones), .digit1(hour_tens),
        .digit2(4'd15), .digit3(4'd15),
        .digit4(sec_ones), .digit5(sec_tens),
        .digit6(min_ones), .digit7(min_tens),
        .d0_an(D0_AN), .d0_seg(D0_SEG),
        .d1_an(D1_AN), .d1_seg(D1_SEG)
    );

endmodule