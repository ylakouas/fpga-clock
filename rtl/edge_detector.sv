// edge_detector.sv
// turns a level signal (stays high while held) into a single
// 1-cycle pulse right when it goes low->high

module edge_detector (
    input  logic clk,
    input  logic rst,
    input  logic level_in,
    output logic pulse_out
);

    logic prev;

    always_ff @(posedge clk) begin
        if (rst) begin
            prev      <= 1'b0;
            pulse_out <= 1'b0;
        end else begin
            pulse_out <= level_in & ~prev;   // high only on the rising edge
            prev      <= level_in;
        end
    end

endmodule