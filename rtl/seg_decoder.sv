// seg_decoder.sv
// takes a 4-bit number (0-15) and outputs which segments to light
// board is common anode, active low -> 0 = segment ON, 1 = segment OFF
// segment order: {dp, g, f, e, d, c, b, a}

module seg_decoder (
    input  logic [3:0] digit,   // number to display, 0-15
    output logic [7:0] seg      // segment lines out, active low
);

    // combinational - no clock, output just follows input instantly
    always_comb begin
        case (digit)
            4'd0:    seg = 8'b1100_0000;  // 0
            4'd1:    seg = 8'b1111_1001;  // 1
            4'd2:    seg = 8'b1010_0100;  // 2
            4'd3:    seg = 8'b1011_0000;  // 3
            4'd4:    seg = 8'b1001_1001;  // 4
            4'd5:    seg = 8'b1001_0010;  // 5
            4'd6:    seg = 8'b1000_0010;  // 6
            4'd7:    seg = 8'b1111_1000;  // 7
            4'd8:    seg = 8'b1000_0000;  // 8
            4'd9:    seg = 8'b1001_0000;  // 9
            default: seg = 8'b1111_1111;  // 10-15 unused, all off
        endcase
    end

endmodule