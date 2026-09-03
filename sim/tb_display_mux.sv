// tb_display_mux.sv
// feeds 8 known digit values in, steps through a full scan cycle,
// checks the anode pattern and both segment outputs at each step

module tb_display_mux;

    logic clk, rst, tick;
    logic [3:0] digit0, digit1, digit2, digit3;
    logic [3:0] digit4, digit5, digit6, digit7;
    logic [3:0] d0_an, d1_an;
    logic [7:0] d0_seg, d1_seg;

    // expected patterns for the digits we're using below
    // (same table we already confirmed correct in tb_seg_decoder)
    localparam [7:0] SEG_0 = 8'b1100_0000;
    localparam [7:0] SEG_1 = 8'b1111_1001;
    localparam [7:0] SEG_2 = 8'b1010_0100;
    localparam [7:0] SEG_3 = 8'b1011_0000;
    localparam [7:0] SEG_4 = 8'b1001_1001;
    localparam [7:0] SEG_5 = 8'b1001_0010;
    localparam [7:0] SEG_6 = 8'b1000_0010;
    localparam [7:0] SEG_7 = 8'b1111_1000;

    display_mux dut (
        .clk (clk), .rst (rst), .tick (tick),
        .digit0 (digit0), .digit1 (digit1), .digit2 (digit2), .digit3 (digit3),
        .digit4 (digit4), .digit5 (digit5), .digit6 (digit6), .digit7 (digit7),
        .d0_an (d0_an), .d0_seg (d0_seg),
        .d1_an (d1_an), .d1_seg (d1_seg)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        // D0 shows 1,2,3,4 - D1 shows 5,6,7,0 - all different so mixups show up
        digit0 = 4'd1; digit1 = 4'd2; digit2 = 4'd3; digit3 = 4'd4;
        digit4 = 4'd5; digit5 = 4'd6; digit6 = 4'd7; digit7 = 4'd0;

        rst  = 1;
        tick = 0;
        repeat (2) @(posedge clk);
        rst <= 0;               // <= here too - releasing reset right on an edge is the same race
        @(negedge clk);

        // pos 0 - right after reset, no tick needed
        if (d0_an === 4'b1110 && d1_an === 4'b1110 && d0_seg === SEG_1 && d1_seg === SEG_5)
            $display("pass pos=0 an=%b d0_seg=%b d1_seg=%b", d0_an, d0_seg, d1_seg);
        else
            $display("FAIL pos=0 an=%b d0_seg=%b d1_seg=%b", d0_an, d0_seg, d1_seg);

        tick <= 1; @(posedge clk); tick <= 0; @(negedge clk);
        if (d0_an === 4'b1101 && d1_an === 4'b1101 && d0_seg === SEG_2 && d1_seg === SEG_6)
            $display("pass pos=1 an=%b d0_seg=%b d1_seg=%b", d0_an, d0_seg, d1_seg);
        else
            $display("FAIL pos=1 an=%b d0_seg=%b d1_seg=%b", d0_an, d0_seg, d1_seg);

        tick <= 1; @(posedge clk); tick <= 0; @(negedge clk);
        if (d0_an === 4'b1011 && d1_an === 4'b1011 && d0_seg === SEG_3 && d1_seg === SEG_7)
            $display("pass pos=2 an=%b d0_seg=%b d1_seg=%b", d0_an, d0_seg, d1_seg);
        else
            $display("FAIL pos=2 an=%b d0_seg=%b d1_seg=%b", d0_an, d0_seg, d1_seg);

        tick <= 1; @(posedge clk); tick <= 0; @(negedge clk);
        if (d0_an === 4'b0111 && d1_an === 4'b0111 && d0_seg === SEG_4 && d1_seg === SEG_0)
            $display("pass pos=3 an=%b d0_seg=%b d1_seg=%b", d0_an, d0_seg, d1_seg);
        else
            $display("FAIL pos=3 an=%b d0_seg=%b d1_seg=%b", d0_an, d0_seg, d1_seg);

        // one more tick should wrap back to position 0
        tick <= 1; @(posedge clk); tick <= 0; @(negedge clk);
        if (d0_an === 4'b1110 && d1_an === 4'b1110 && d0_seg === SEG_1 && d1_seg === SEG_5)
            $display("pass pos=0 wrapped an=%b d0_seg=%b d1_seg=%b", d0_an, d0_seg, d1_seg);
        else
            $display("FAIL pos=0 wrapped an=%b d0_seg=%b d1_seg=%b", d0_an, d0_seg, d1_seg);

        $display("Simulation finished.");
        $finish;
    end

endmodule