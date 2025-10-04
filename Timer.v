
module Timer #(
    parameter CLOCK_FREQ_HZ = 25_000_000,
    parameter PERIOD = 1.0 // Period in seconds (max 171 seconds)
)(
    input i_Clk,
    output o_trigger
);

    localparam integer c_TIMER_CLOCK_COUNT = CLOCK_FREQ_HZ * PERIOD;

    // 32 bit register to count clock cycles
    // 2^32 = 4_294_967_296 / 25_000_000 = 171 second max period
    reg[31:0] r_Count = 0;

    // Not supported in regular verilog, but variable register size
    // reg[$clog2(c_TIMER_CLOCK_COUNT)-1:0] r_Count = 0;

    reg r_trigger = 1'b0;

    always @(posedge i_Clk) begin
        if (r_Count == c_TIMER_CLOCK_COUNT) begin
            r_trigger <= 1'b1;
            r_Count <= 0;
        end else begin
            r_trigger <= 1'b0;
            r_Count <= r_Count + 1;
        end
    end

    assign o_trigger = r_trigger;

endmodule
