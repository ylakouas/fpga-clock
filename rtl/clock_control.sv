// clock_control.sv
// small state machine: RUN -> SET_HOUR -> SET_MIN -> RUN, driven by
// mode_pulse. reset_pulse always wins and snaps straight back to RUN.
// set_hour/set_min tell the top module which LED to light, so setting
// the time isn't done blind.

module clock_control (
    input  logic clk,
    input  logic rst,

    input  logic reset_pulse,
    input  logic mode_pulse,
    input  logic inc_pulse,

    output logic run_en,
    output logic hour_inc,
    output logic min_inc,
    output logic full_clear,
    output logic sec_clear,
    output logic set_hour,      // 1 while in SET_HOUR - drives an LED
    output logic set_min        // 1 while in SET_MIN - drives an LED
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
            next_state = RUN;
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
    assign sec_clear      = mode_pulse && (state == SET_MIN);
    assign set_hour        = (state == SET_HOUR);
    assign set_min           = (state == SET_MIN);

endmodule