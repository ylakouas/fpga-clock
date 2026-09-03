// synchronizer.sv
// passes an async signal through 2 flip-flops before we trust it
// standard fix for metastability - button presses aren't synced to our clock

module synchronizer (
    input  logic clk,
    input  logic async_in,
    output logic sync_out
);

    logic stage1;

    always_ff @(posedge clk) begin
        stage1   <= async_in;
        sync_out <= stage1;
    end

endmodule