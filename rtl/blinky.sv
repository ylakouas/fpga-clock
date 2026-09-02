// blinky.sv
// Hardware bring-up test for the Boolean Board.
// Blinks LED0 at about 1 Hz. This proves the toolchain, USB cable,
// constraints, and clock all work before we build anything real.

module blinky (
    input  logic clk,      // 100 MHz board oscillator, pin F14
    output logic led       // LED0, pin G1
);

    // The oscillator ticks 100,000,000 times per second.
    // We flip the LED every half second, so a full off-on-off
    // cycle takes one second.
    localparam int HALF_SECOND = 50_000_000;

    // Counter to hold the tick count. 50,000,000 needs 26 bits,
    // so this is numbered 25 down to 0. Starts at zero.
    logic [25:0] count = 0;

    // Whether the LED is currently on. Starts off.
    logic led_state = 0;

    // This block runs once on every rising edge of the clock,
    // 100 million times a second.
    always_ff @(posedge clk) begin
        if (count == HALF_SECOND - 1) begin
            count     <= 0;            // half a second has passed, start over
            led_state <= ~led_state;   // and flip the LED
        end else begin
            count <= count + 1;        // not there yet, just keep counting
        end
    end

    // Drive the physical pin from our internal state signal.
    assign led = led_state;

endmodule