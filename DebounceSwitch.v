
module DebounceSwitch #(
    parameter CLOCK_FREQ_HZ = 25_000_000,
    parameter DEBOUNCE_MS = 1000.0
)(
    input i_Clk,
    input i_Switch,
    output o_Switch
);

    // Calculate the clock cycles needed to meet our debounce time
    localparam integer c_DEBOUNCE_LIMIT = CLOCK_FREQ_HZ * DEBOUNCE_MS / 1_000;
    // localparam COUNTER_WIDTH = $clog2(c_DEBOUNCE_LIMIT);
    // reg[COUNTER_WIDTH-1:0] r_Count = 0;

    reg[32:0] r_Count = 0;
    reg r_State = 1'b0;

    always @(posedge i_Clk) begin
        if (i_Switch !== r_State && r_Count < c_DEBOUNCE_LIMIT)
            r_Count <= r_Count + 1;
        else if (r_Count == c_DEBOUNCE_LIMIT) begin
            r_State <= i_Switch;
            r_Count <= 0;
        end else
            r_Count <= 0;
    end

    assign o_Switch = r_State;

endmodule
