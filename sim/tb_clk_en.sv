// tb_clk_en.sv
// Testbench for clk_en. Uses a tiny DIVISOR so the simulation finishes
// in nanoseconds instead of taking forever to reach 50 million.

module tb_clk_en;

    // No ports. This file IS the top of the simulation - there's
    // nothing above it to connect wires to.

    logic clk;
    logic rst;
    logic tick;

    // Instantiate clk_en - the module we're actually testing.
    // "dut" = device under test, a standard name for this.
    // DIVISOR(10) overrides the default 50,000,000 with 10, just
    // for this simulation. Same logic, much faster to watch.
    clk_en #(
        .DIVISOR(10)
    ) dut (
        .clk  (clk),
        .rst  (rst),
        .tick (tick)
    );

    // Fake the 100 MHz oscillator. Real hardware has a crystal;
    // here we just flip clk every 5 ns forever, which gives a
    // 10 ns period - same speed the XDC declares.
    initial clk = 0;
    always #5 clk = ~clk;

    // The actual test: hold reset briefly, release it, then just
    // let time pass and watch what tick does.
    initial begin
        rst = 1;
        repeat (2) @(posedge clk);   // hold reset for 2 clock edges
        rst = 0;

        // DIVISOR is 10, so tick should pulse once every 10 cycles.
        // Run for 50 cycles - enough to see it happen 5 times.
        repeat (50) @(posedge clk);

        $display("Simulation finished.");
        $finish;
    end

endmodule