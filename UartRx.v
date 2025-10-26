
module UartRx #(
    parameter CLOCK_FREQ_HZ = 25_000_000,    // cycles/second
    parameter BAUD_RATE = 9_600,             // bits/second
    parameter DATA_BITS = 8,                 // bits/message, [5, 9]
    parameter PARITY_BIT = 0,                // Parity bit enable, 0 or 1
    parameter ODD_PARITY = 1,                // Using odd parity? 0 or 1
    parameter STOP_BITS = 1                  // Stop bits to detect, [0, 2]
)(
    input i_Clk,
    input i_rx,
    output [DATA_BITS-1:0] o_data, // Not supported with my compiler? We'll see... 🤔
    // output [8:0] o_data,
    output o_error
);

    // delay between bit reads 
    localparam bit_delay = CLOCK_FREQ_HZ / BAUD_RATE;

    // states:
    //    0 - waiting
    //    1 - data
    //    2 - parity check
    //    3 - stop check
    //    4 - Initial state
    reg [2:0] r_state = 3'h4;
    
    // buffer for output
    reg [DATA_BITS-1:0] r_packetBuffer = {DATA_BITS{1'b0}};

    // keep track of what bit we're on
    reg [2:0] r_bitIndex = 3'h0;

    // The previous recieved bit from i_rx
    reg r_lastRx = 1'b0;

    // Error storage register
    reg r_error = 0;

    // Parity storage register
    generate
        if (PARITY_BIT)
            reg r_parity;
    endgenerate

    // we account for 1.5 * bit_delay because we should initially wait 1.5 bit
    // delay cycles so we're approximately in the middle of the bit

    // our compiler does not include $clog2(...), so manual calculation:
    //     ceil(log_2(1.5 * bit_delay))
    //     ceil(log_2(1.5 * 25_000_000 / 9_600))
    //     ceil(log_2(3_906.25))
    //     ceil(11.931...)
    //     12 bits needed for counter

    // reg[$clog2(1.5 * bit_delay)-1:0] r_clockCountdown = bit_delay;
    // reg [11:0] r_clockCountdown = 0;

    // We'll just make this a 32 bit countdown for now... 😢
    reg [31:0] r_clockCountdown = 0;

    always @(posedge i_Clk) begin

        case(r_state)
            0: begin
                // waiting
                if (r_lastRx != i_rx) begin
                    r_state <= 1;                           // Move to state 1, read data bits
                    r_error <= 0;                           // Reset the error bit
                    r_bitIndex <= 0;                        // Reset the bit index
                    r_packetBuffer <= {DATA_BITS{1'b0}};    // Reset the packet buffer
                    r_clockCountdown <= bit_delay * 1.5;
                end
            end
            1: begin
                // check data bit
                if (r_bitIndex > DATA_BITS) begin
                    r_clockCountdown <= bit_delay;  // Reset the clock
                    r_state <= 2;                   // Move to state 2, parity check
                    r_bitIndex <= 0;                // Reset bit index we're checking
                end else if (r_clockCountdown == 0) begin
                    r_clockCountdown <= bit_delay;         // Reset the clock
                    r_packetBuffer[r_bitIndex] <= i_rx;    // Set the incomming bit
                    r_bitIndex <= r_bitIndex + 1;          // Move bit index up
                end
            end
            2: begin
                // parity check
                if (r_bitIndex > PARITY_BIT) begin
                    // This will skip a clock cycle if the parity bit is not enabled
                    r_clockCountdown <= bit_delay;    // Reset the clock
                    r_state <= 3;                     // Move to state 3, stop bit checks
                    r_bitIndex <= 0;                  // Reset the bit index
                end else if (r_clockCountdown == 0) begin
                    r_clockCountdown <= bit_delay;    // Reset the clock
                    if (PARITY_BIT)
                        r_error <= ^r_packetBuffer ^ i_rx == ODD_PARITY;
                        // xor our input packet and xor i_rx, see if its equal to parity set above
                    r_bitIndex <= r_bitIndex + 1;     // Move bit index up
                end
            end
            3: begin
                // stop check
                if (r_bitIndex > STOP_BITS) begin
                    r_clockCountdown <= bit_delay;    // Reset the clock
                    // This will skip a clock cycle if no stop bits are set
                    r_state <= 0;       // Move to state 0, waiting for next input
                end else if (r_clockCountdown == 0) begin
                    r_clockCountdown <= bit_delay;     // Reset the clock
                    r_error <= r_error | i_rx != 1;    // Set error state if i_rx is not high
                    r_bitIndex <= r_bitIndex + 1;      // Move bit index up
                end
            end
            4: begin
                // Initialize the module, make sure r_lastRx is in line with i_rx 
            end
        endcase

        // count the clock down if set
        if (r_clockCountdown > 0)
            r_clockCountdown <= r_clockCountdown - 1;

        // Keep track of the last state of i_rx is
        r_lastRx <= i_rx;

    end

    // This compiler does not support variable width outputs 😢
    assign o_data = r_packetBuffer;
    
    // Comment this generate block out if your compiler supports variable width outputs
    // generate
    //     // DATA_BITS [5, 9]
    //     // o_data is always 9 bits
    //     assign o_data = {{(9 - DATA_BITS){1'b00}}, r_packetBuffer};
    // endgenerate

    assign o_error = r_error;

endmodule

module tb_UartRx;

    // === Hardware definitions ===

    // Regular pulsing clock
    reg clk = 0;
    always #1 clk = ~clk;

    // wire rx;
    // wire [7:0] data;
    // wire error;

    // UartRx uart_in #(
    //     CLOCK_FREQ_HZ(25_000_000),
    //     BAUD_RATE(9_600),
    //     DATA_BITS(8),
    //     PARITY_BIT(0),
    //     ODD_PARITY(1),
    //     STOP_BITS(1)
    // ) (
    //     .i_Clk(clk),
    //     .i_rx(i_rx),
    //     o_data(o_data),
    //     o_error()
    // );

    reg tx = 1;

    task send_uart(
        input integer baud_rate,
        input integer data,
        input integer stop_bits,
        input bool parity_bit_enabled,
        input bool odd_parity
        );
        begin
            // Start bit
            tx = 0;
            #1;

            // Loop through input 'data' and set the bits accordingly
            for (integer i = 0; i < 8; i++) begin
                tx = data[i];
                #1;
            end
            
            // Parity bit
            if (parity_bit_enabled) begin
                tx = ^data ^ odd_parity;
                #1;
            end

            // Stop bits
            tx = 1;
            #(stop_bits);

            // Back to high state
            tx = 1;
        end
    endtask

    // === Value expectation ===

    // reg [7:0] expected = 0;

    // always @(posedge clk) begin
    //     if (reset)
    //         expected <= 0;
    //     else
    //         expected <= expected + 1;

    //     if (val_c1 !== expected) begin
    //         $display("ERROR at time %t: val_c1 = %0d, expected = %0d", $time, val_c1, expected);
    //     end
    // end


    // === Test sequence ===
    
    reg [7:0] r_input = 8'hFE;

    initial begin
        $dumpfile("tb_UartRx.vcd");
        $dumpvars(0, tb_UartRx);
        // $monitor("At time %t, value = %h (%0d)", $time, val_c1, val_c1);

        #5;
        // Odd parity
        send_uart(
            8'b10010001,
            2,
            1,
            1
        );
        #5;
        // Even parity
        send_uart(
            8'b10010001,
            2,
            1,
            0
        );

        $display("Simulation complete");
        $finish;
    end

endmodule
