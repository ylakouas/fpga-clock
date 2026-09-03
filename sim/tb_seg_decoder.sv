// tb_seg_decoder.sv
// sweeps digit 0-15, checks seg output against the correct pattern each time
// no clock needed - decoder is combinational, updates instantly when digit changes

module tb_seg_decoder;

    logic [3:0] digit;
    logic [7:0] seg;

    // dut = device under test
    seg_decoder dut (
        .digit (digit),
        .seg   (seg)
    );

    logic [7:0] expected;   // what seg SHOULD be for the current digit

    initial begin
        for (int i = 0; i < 16; i++) begin
            digit = i[3:0];
            #10;   // small delay so seg has time to settle

            // same table as the decoder - the "answer key" to check against
            case (i)
                0:       expected = 8'b1100_0000;
                1:       expected = 8'b1111_1001;
                2:       expected = 8'b1010_0100;
                3:       expected = 8'b1011_0000;
                4:       expected = 8'b1001_1001;
                5:       expected = 8'b1001_0010;
                6:       expected = 8'b1000_0010;
                7:       expected = 8'b1111_1000;
                8:       expected = 8'b1000_0000;
                9:       expected = 8'b1001_0000;
                default: expected = 8'b1111_1111;
            endcase

            if (seg !== expected)
                $display("FAIL digit=%0d  got=%b  expected=%b", i, seg, expected);
            else
                $display("pass digit=%0d  seg=%b", i, seg);
        end

        $display("Simulation finished.");
        $finish;
    end

endmodule