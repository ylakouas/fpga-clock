// tb_clock_control.sv
// checks state cycles RUN -> SET_HOUR -> SET_MIN -> RUN on mode_pulse,
// hour_inc/min_inc only pass through in the right state, reset_pulse
// always forces back to RUN, and set_hour/set_min correctly flag
// which mode we're in

module tb_clock_control;

    logic clk, rst;
    logic reset_pulse, mode_pulse, inc_pulse;
    logic run_en, hour_inc, min_inc, full_clear, sec_clear, set_hour, set_min;

    clock_control dut (
        .clk(clk), .rst(rst),
        .reset_pulse(reset_pulse), .mode_pulse(mode_pulse), .inc_pulse(inc_pulse),
        .run_en(run_en), .hour_inc(hour_inc), .min_inc(min_inc),
        .full_clear(full_clear), .sec_clear(sec_clear),
        .set_hour(set_hour), .set_min(set_min)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    task automatic press_mode;
        begin
            @(negedge clk); mode_pulse <= 1;
            @(negedge clk); mode_pulse <= 0;
        end
    endtask

    initial begin
        rst = 1;
        reset_pulse = 0; mode_pulse = 0; inc_pulse = 0;
        repeat (2) @(negedge clk);
        rst <= 0;
        @(negedge clk);

        if (run_en === 1'b1 && set_hour === 1'b0 && set_min === 1'b0)
            $display("pass starts in RUN, both LEDs off");
        else
            $display("FAIL did not start in RUN with LEDs off");

        @(negedge clk); inc_pulse <= 1;
        @(negedge clk);
        if (hour_inc === 1'b0 && min_inc === 1'b0)
            $display("pass inc ignored while in RUN");
        else
            $display("FAIL inc leaked through while in RUN");
        inc_pulse <= 0;
        @(negedge clk);

        press_mode;   // RUN -> SET_HOUR
        if (run_en === 1'b0 && set_hour === 1'b1 && set_min === 1'b0)
            $display("pass left RUN, set_hour LED on");
        else
            $display("FAIL set_hour LED wrong after mode press");

        @(negedge clk); inc_pulse <= 1;
        @(negedge clk);
        if (hour_inc === 1'b1 && min_inc === 1'b0)
            $display("pass hour_inc pulses in SET_HOUR");
        else
            $display("FAIL hour_inc did not pulse correctly in SET_HOUR");
        inc_pulse <= 0;
        @(negedge clk);

        press_mode;   // SET_HOUR -> SET_MIN
        if (set_hour === 1'b0 && set_min === 1'b1)
            $display("pass set_min LED on, set_hour LED off");
        else
            $display("FAIL LED states wrong in SET_MIN");

        @(negedge clk); inc_pulse <= 1;
        @(negedge clk);
        if (min_inc === 1'b1 && hour_inc === 1'b0)
            $display("pass min_inc pulses in SET_MIN");
        else
            $display("FAIL min_inc did not pulse correctly in SET_MIN");
        inc_pulse <= 0;
        @(negedge clk);

        press_mode;   // SET_MIN -> RUN
        if (run_en === 1'b1 && set_hour === 1'b0 && set_min === 1'b0)
            $display("pass back in RUN after full mode cycle, both LEDs off");
        else
            $display("FAIL did not return cleanly to RUN");

        press_mode;   // RUN -> SET_HOUR, to prove reset interrupts setting

        @(negedge clk); reset_pulse <= 1;
        @(posedge clk);
        if (full_clear === 1'b1)
            $display("pass full_clear asserted on reset_pulse");
        else
            $display("FAIL full_clear did not assert");
        @(negedge clk); reset_pulse <= 0;
        @(negedge clk);

        if (run_en === 1'b1 && set_hour === 1'b0 && set_min === 1'b0)
            $display("pass reset forced state back to RUN, LEDs off");
        else
            $display("FAIL reset did not clear LED state");

        $display("Simulation finished.");
        $finish;
    end

endmodule