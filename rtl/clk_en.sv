// clk_en.sv
// makes a "tick" pulse every DIVISOR clocks instead of using a slower clock
// keeps everything on ONE clock (100MHz) - avoids clock domain issues

module clk_en #(
    parameter int DIVISOR = 50_000_000   // 50M @ 100MHz = ~1 sec
) (
    input  logic clk,
    input  logic rst,
    output logic tick     // high for 1 cycle only
);

    // clog2 = auto calculates bits needed to count to DIVISOR
    localparam int WIDTH = $clog2(DIVISOR);

    logic [WIDTH-1:0] count;

    always_ff @(posedge clk) begin
        if (rst) begin
            // reset -> back to 0, tick off
            count <= 0;
            tick  <= 1'b0;
        end else if (count == DIVISOR - 1) begin
            // hit the max -> pulse tick, restart count
            count <= 0;
            tick  <= 1'b1;
        end else begin
            // still counting, tick stays low
            count <= count + 1;
            tick  <= 1'b0;
        end
    end

endmodule