// tb_time_counters.sv
// pulses tick_1hz repeatedly, checks the digits at each rollover point
// that's actually tricky - not every single second

module tb_time_counters;

    logic clk, rst, tick_1hz;
    logic [3:0] sec_ones, sec_tens, min_ones, min_tens, hour_ones, hour_tens;

    time_counters dut (
        .clk(clk), .rst(rst), .tick_1hz(tick_1hz),
        .hour_inc(1'b0), .min_inc(1'b0), .sec_clear(1'b0),
        .sec_ones(sec_ones), .sec_tens(sec_tens),
        .min_ones(min_ones), .min_tens(min_tens),
        .hour_ones(hour_ones), .hour_tens(hour_tens)
    );
    initial clk = 0;
    always #5 clk = ~clk;

    // sends one clean tick pulse - nonblocking, avoids the same race
    // we found and fixed in tb_display_mux
    task automatic do_tick;
        begin
            @(negedge clk);
            tick_1hz <= 1;
            @(negedge clk);
            tick_1hz <= 0;
        end
    endtask

    // a tick that crosses a digit boundary (like 9->0) takes a few
    // EXTRA clock cycles to ripple to the next digit - each stage only
    // sees the carry one cycle after the one before it wraps. real
    // hardware never notices (nanoseconds vs a full second between real
    // ticks) but we have to wait for it here before checking.
    task automatic settle;
        begin
            repeat (6) @(negedge clk);
        end
    endtask

    task automatic check(input string label,
                          input [3:0] exp_so, exp_st, exp_mo, exp_mt, exp_ho, exp_ht);
        begin
            if (sec_ones===exp_so && sec_tens===exp_st && min_ones===exp_mo &&
                min_tens===exp_mt && hour_ones===exp_ho && hour_tens===exp_ht)
                $display("pass %s -> %0d%0d:%0d%0d:%0d%0d", label,
                          hour_tens,hour_ones,min_tens,min_ones,sec_tens,sec_ones);
            else
                $display("FAIL %s -> got %0d%0d:%0d%0d:%0d%0d  expected %0d%0d:%0d%0d:%0d%0d",
                          label, hour_tens,hour_ones,min_tens,min_ones,sec_tens,sec_ones,
                          exp_ht,exp_ho,exp_mt,exp_mo,exp_st,exp_so);
        end
    endtask

    initial begin
        rst = 1;
        tick_1hz = 0;
        repeat (2) @(negedge clk);
        rst <= 0;
        @(negedge clk);

        check("reset",          4'd0,4'd0, 4'd0,4'd0, 4'd0,4'd0);   // 00:00:00

        do_tick; settle;
        check("1 sec",          4'd1,4'd0, 4'd0,4'd0, 4'd0,4'd0);   // 00:00:01

        repeat (8) do_tick; settle;
        check("9 sec",          4'd9,4'd0, 4'd0,4'd0, 4'd0,4'd0);   // 00:00:09

        do_tick; settle;
        check("sec ones wrap",  4'd0,4'd1, 4'd0,4'd0, 4'd0,4'd0);   // 00:00:10

        repeat (49) do_tick; settle;
        check("59 sec",         4'd9,4'd5, 4'd0,4'd0, 4'd0,4'd0);   // 00:00:59

        do_tick; settle;
        check("1 minute",       4'd0,4'd0, 4'd1,4'd0, 4'd0,4'd0);   // 00:01:00

        repeat (3539) do_tick; settle;
        check("59:59",          4'd9,4'd5, 4'd9,4'd5, 4'd0,4'd0);   // 00:59:59

        do_tick; settle;
        check("1 hour",         4'd0,4'd0, 4'd0,4'd0, 4'd1,4'd0);   // 01:00:00

        repeat (82799) do_tick; settle;
        check("23:59:59",       4'd9,4'd5, 4'd9,4'd5, 4'd3,4'd2);   // 23:59:59

        do_tick; settle;
        check("midnight wrap",  4'd0,4'd0, 4'd0,4'd0, 4'd0,4'd0);   // 00:00:00

        $display("Simulation finished.");
        $finish;
    end

endmodule