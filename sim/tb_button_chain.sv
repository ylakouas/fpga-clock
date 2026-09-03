// tb_button_chain.sv
// drives a simulated bouncy button press/release through
// synchronizer -> debouncer -> edge_detector, checks the bounce
// gets filtered and exactly one pulse comes out per real press

module tb_button_chain;

    logic clk, rst;
    logic raw_btn;
    logic sync_out, clean_out, pulse_out;
    logic tick;

    synchronizer u_sync (
        .clk      (clk),
        .async_in (raw_btn),
        .sync_out (sync_out)
    );

    // small STABLE_COUNT so sim doesn't take forever - real design
    // uses a much bigger number for a real ~20ms filter
    debouncer #(
        .STABLE_COUNT(3)
    ) u_debounce (
        .clk       (clk),
        .rst       (rst),
        .tick      (tick),
        .noisy_in  (sync_out),
        .clean_out (clean_out)
    );

    edge_detector u_edge (
        .clk       (clk),
        .rst       (rst),
        .level_in  (clean_out),
        .pulse_out (pulse_out)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    task automatic do_tick;
        begin
            @(negedge clk);
            tick <= 1;
            @(negedge clk);
            tick <= 0;
        end
    endtask

    // synchronizer (2 cycles) + debounce threshold stack up - give this
    // plenty of ticks rather than hand-counting the exact minimum
    task automatic wait_for_debounce;
        begin
            repeat (10) do_tick;
        end
    endtask

    integer pulse_count;

    always @(posedge clk) begin
        if (pulse_out) pulse_count <= pulse_count + 1;
    end

    initial begin
        rst = 1;
        raw_btn = 0;
        tick = 0;
        pulse_count = 0;
        repeat (2) @(negedge clk);
        rst <= 0;
        @(negedge clk);

        // --- simulate a bouncy PRESS ---
        raw_btn = 1; #7;
        raw_btn = 0; #4;
        raw_btn = 1; #6;
        raw_btn = 0; #3;
        raw_btn = 1;   // settles high from here on

        do_tick;
        if (clean_out !== 1'b0)
            $display("FAIL clean_out went high too early");
        else
            $display("pass clean_out still low right after bounce settles");

        wait_for_debounce;

        if (clean_out === 1'b1)
            $display("pass clean_out went high after stable ticks");
        else
            $display("FAIL clean_out did not go high");

        if (pulse_count === 1)
            $display("pass exactly 1 pulse fired for the press");
        else
            $display("FAIL pulse_count = %0d, expected 1", pulse_count);

        repeat (5) do_tick;   // hold the button
        if (pulse_count === 1)
            $display("pass no extra pulses while button held");
        else
            $display("FAIL pulse_count = %0d while holding", pulse_count);

        // --- simulate a bouncy RELEASE ---
        raw_btn = 0; #5;
        raw_btn = 1; #3;
        raw_btn = 0;   // settles low

        wait_for_debounce;
        if (clean_out === 1'b0)
            $display("pass clean_out went low after release settled");
        else
            $display("FAIL clean_out still high after release");

        if (pulse_count === 1)
            $display("pass still only 1 pulse total - release triggers none");
        else
            $display("FAIL pulse_count = %0d after release", pulse_count);

        $display("Simulation finished.");
        $finish;
    end

endmodule