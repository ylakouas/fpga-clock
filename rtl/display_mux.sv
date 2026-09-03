// display_mux.sv
// scans through 4 digit positions, showing one digit at a time on each
// display (D0 and D1) - fast enough it looks like all 4 are lit at once
// digit0-3 = D0 (digit0 = rightmost), digit4-7 = D1 (digit4 = rightmost)

module display_mux (
    input  logic clk,
    input  logic rst,
    input  logic tick,           // refresh pulse, ~1kHz

    input  logic [3:0] digit0, digit1, digit2, digit3,   // D0's 4 digits
    input  logic [3:0] digit4, digit5, digit6, digit7,   // D1's 4 digits

    output logic [3:0] d0_an,
    output logic [7:0] d0_seg,
    output logic [3:0] d1_an,
    output logic [7:0] d1_seg
);

    // cycles 0,1,2,3,0,1,2,3... one step per tick
    logic [1:0] scan_pos;

    always_ff @(posedge clk) begin
        if (rst)
            scan_pos <= 2'd0;
        else if (tick)
            scan_pos <= scan_pos + 1'b1;   // wraps on its own, only 2 bits
    end

    // anode select - active low, only ONE bit low at a time
    // same pattern drives both displays since they scan together
    always_comb begin
        case (scan_pos)
            2'd0:    begin d0_an = 4'b1110; d1_an = 4'b1110; end
            2'd1:    begin d0_an = 4'b1101; d1_an = 4'b1101; end
            2'd2:    begin d0_an = 4'b1011; d1_an = 4'b1011; end
            2'd3:    begin d0_an = 4'b0111; d1_an = 4'b0111; end
            default: begin d0_an = 4'b1111; d1_an = 4'b1111; end
        endcase
    end

    // pick which of the 4 digit values is "on deck" right now
    logic [3:0] d0_pick, d1_pick;

    always_comb begin
        case (scan_pos)
            2'd0:    begin d0_pick = digit0; d1_pick = digit4; end
            2'd1:    begin d0_pick = digit1; d1_pick = digit5; end
            2'd2:    begin d0_pick = digit2; d1_pick = digit6; end
            2'd3:    begin d0_pick = digit3; d1_pick = digit7; end
            default: begin d0_pick = 4'd0;   d1_pick = 4'd0;   end
        endcase
    end

    // reuse the decoder we already built - one copy per physical display
    seg_decoder d0_decoder (
        .digit (d0_pick),
        .seg   (d0_seg)
    );

    seg_decoder d1_decoder (
        .digit (d1_pick),
        .seg   (d1_seg)
    );

endmodule