
`define uart

`ifdef uart

module top(
    // Main Clock (25M Hz)
    input i_Clk,

    input i_UART_RX,

    output o_Segment2_A,
    output o_Segment2_B,
    output o_Segment2_C,
    output o_Segment2_D,
    output o_Segment2_E,
    output o_Segment2_F,
    output o_Segment2_G,
    
    output o_Segment1_A,
    output o_Segment1_B,
    output o_Segment1_C,
    output o_Segment1_D,
    output o_Segment1_E,
    output o_Segment1_F,
    output o_Segment1_G
);

    // 256 possible vals
    wire [7:0] w_uartData;

    wire [3:0] w_uartOnes; // 0000 -> 1001 or 0 -> 9
    wire [3:0] w_uartTens; // ditto

    assign w_uartOnes = w_uartData % 10;
    assign w_uartTens = w_uartData % 100 / 10;
    
    wire w_uartError;

    // UartRx #(
    //     .BAUD_RATE(9_600),
    //     .DATA_BITS(8),
    //     .PARITY_BIT(0),
    //     .ODD_PARITY(1),
    //     .STOP_BITS(1)
    // ) urx (
    //     .i_Clk(i_Clk),
    //     .i_rx(i_UART_RX),
    //     .o_data(w_uartData),
    //     .o_error(w_uartError)
    // );

    SevenSegment sevSeg1 (
        .i_number(w_uartTens),
        .o_Segment_A(o_Segment1_A),
        .o_Segment_B(o_Segment1_B),
        .o_Segment_C(o_Segment1_C),
        .o_Segment_D(o_Segment1_D),
        .o_Segment_E(o_Segment1_E),
        .o_Segment_F(o_Segment1_F),
        .o_Segment_G(o_Segment1_G)
    );
    
    SevenSegment sevSeg2 (
        .i_number(w_uartOnes),
        .o_Segment_A(o_Segment2_A),
        .o_Segment_B(o_Segment2_B),
        .o_Segment_C(o_Segment2_C),
        .o_Segment_D(o_Segment2_D),
        .o_Segment_E(o_Segment2_E),
        .o_Segment_F(o_Segment2_F),
        .o_Segment_G(o_Segment2_G)
    );

endmodule

`endif

`ifdef PROJECT_5

module top(
    input i_Clk,
    output o_LED_1,
    output o_Segment2_A,
    output o_Segment2_B,
    output o_Segment2_C,
    output o_Segment2_D,
    output o_Segment2_E,
    output o_Segment2_F,
    output o_Segment2_G
);
    // reg r_LED_1 = 1'b0;

    // wire w_timer;

    // Timer (
    //     .i_Clk(i_Clk),
    //     .o_trigger(w_timer)
    // );

    // always @(posedge i_Clk) begin
    //     if (w_timer)
    //         r_LED_1 = ~r_LED_1;
    // end

    // assign o_LED_1 = r_LED_1;

    // === divider ===

    reg [3:0] r_counter = 0;

    wire w_timer;

    Timer tim (
        .i_Clk(i_Clk),
        .o_trigger(w_timer)
    );

    always @(posedge i_Clk) begin
        if (r_counter == 9 && w_timer)
            r_counter <= 0;
        else if (w_timer)
            r_counter <= r_counter + 1;
    end

    SevenSegment sseg (
        .i_number(r_counter),
        .o_Segment_A(o_Segment2_A),
        .o_Segment_B(o_Segment2_B),
        .o_Segment_C(o_Segment2_C),
        .o_Segment_D(o_Segment2_D),
        .o_Segment_E(o_Segment2_E),
        .o_Segment_F(o_Segment2_F),
        .o_Segment_G(o_Segment2_G)
    );

endmodule

`endif

`ifdef PROJECT_4

module top(
    input i_Clk,
    input i_Switch_1,
    output o_LED_1
);
    reg r_Switch_1 = 1'b0;
    reg r_LED_1 = 1'b0;
    wire w_Switch;

    Debounce_Switch (
        .i_Clk(i_Clk),
        .i_Switch(i_Switch_1),
        .o_Switch(w_Switch)
    );

    always @(posedge i_Clk) begin
        
        r_Switch_1 <= w_Switch;

        if (r_Switch_1 == 1'b0 && w_Switch == 1'b1) begin
            r_LED_1 <= ~r_LED_1;
        end

    end

    assign o_LED_1 = r_LED_1;

endmodule

`endif
