// clock_control.sv
// small state machine: RUN -> SET_HOUR -> SET_MIN -> RUN, driven by
// mode_pulse. reset_pulse always wins and snaps straight back to RUN.

module clock_control (
    input  logic clk,
    input  logic rst,

    input  logic reset_pulse,   // btn0 edge - full clear
    input  logic mode_pulse,    // btn1 edge - cycle states
    input  logic inc_pulse,     // btn2 edge - increment selected field

    output logic run_en,        // 1 while in RUN - gates the 1Hz tick
    output logic hour_inc,      // inc_pulse routed here only in SET_HOUR
    output logic min_inc,       // inc_pulse routed here only in SET_MIN
    output logic full_clear,    // = reset_pulse, clears everything
    output logic sec_clear      // pulses leaving SET_MIN -> RUN
);

    typedef enum logic [1:0] {
        RUN      = 2'b00,
        SET_HOUR = 2'b01,
        SET_MIN  = 2'b10
    } state_t;

    state_t state, next_state;

    always_ff @(posedge clk) begin
        if (rst)
            state <= RUN;
        else
            state <= next_state;
    end

    always_comb begin
        next_state = state;
        if (reset_pulse) begin
            next_state = RUN;             // reset always wins
        end else if (mode_pulse) begin
            case (state)
                RUN:      next_state = SET_HOUR;
                SET_HOUR: next_state = SET_MIN;
                SET_MIN:  next_state = RUN;
                default:  next_state = RUN;
            endcase
        end
    end

    assign run_en     = (state == RUN);
    assign hour_inc    = inc_pulse && (state == SET_HOUR);
    assign min_inc      = inc_pulse && (state == SET_MIN);
    assign full_clear   = reset_pulse;
    assign sec_clear     = mode_pulse && (state == SET_MIN);   // about to leave SET_MIN

endmodule