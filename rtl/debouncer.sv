// debouncer.sv
// only believes the input changed once it's held steady for
// STABLE_COUNT consecutive slow ticks - filters out mechanical bounce

module debouncer #(
    parameter int STABLE_COUNT = 20
) (
    input  logic clk,
    input  logic rst,
    input  logic tick,        // slow sample tick
    input  logic noisy_in,
    output logic clean_out
);

    localparam int WIDTH = $clog2(STABLE_COUNT + 1);

    logic [WIDTH-1:0] count;
    logic last_sample;

    always_ff @(posedge clk) begin
        if (rst) begin
            count       <= 0;
            last_sample <= 1'b0;
            clean_out   <= 1'b0;
        end else if (tick) begin
            if (noisy_in == last_sample) begin
                if (count == STABLE_COUNT)
                    clean_out <= noisy_in;   // stable long enough, believe it
                else
                    count <= count + 1'b1;
            end else begin
                // input changed since last look - start the count over
                last_sample <= noisy_in;
                count       <= 0;
            end
        end
    end

endmodule