
module SevenSegment (
    input [3:0] i_number, // 0000 -> 1001 (0 to 9) 
    output o_Segment_A,
    output o_Segment_B,
    output o_Segment_C,
    output o_Segment_D,
    output o_Segment_E,
    output o_Segment_F,
    output o_Segment_G
);

    reg [6:0] segments;

    always @* begin
        case(i_number)
            0: segments = 7'b0000001;
            1: segments = 7'b1001111;
            2: segments = 7'b0010010;
            3: segments = 7'b0000110;
            4: segments = 7'b1001100;
            5: segments = 7'b0100100;
            6: segments = 7'b0100000;
            7: segments = 7'b0001111;
            8: segments = 7'b0000000;
            9: segments = 7'b0001100;
            default: segments = 7'b0000000;
        endcase
    end

    assign {
        o_Segment_A,
        o_Segment_B,
        o_Segment_C,
        o_Segment_D,
        o_Segment_E,
        o_Segment_F,
        o_Segment_G
    } = segments;

endmodule
