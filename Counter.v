
module Counter #(
    parameter OUT_WIDTH = 8
) (
    input                  i_clk,
    input                  i_reset,
    output reg [OUT_WIDTH-1:0] o_out = {OUT_WIDTH{1'b0}}
);

    always @(posedge i_clk or posedge i_reset)
        if(i_reset)
            o_out <= {OUT_WIDTH{1'b0}};
        else
            o_out <= o_out + 1;

endmodule

module tb_Counter;

    // === Hardware definitions ===

    reg reset = 0;

    task pulse_reset(input integer cycles);
        begin
            reset = 1;
            #(cycles);
            reset = 0;
        end
    endtask

    // Regular pulsing clock
    reg clk = 0;
    always #1 clk = ~clk;

    wire [7:0] val_c1;

    Counter c1 (
        .i_clk(clk),
        .i_reset(reset),
        .o_out(val_c1)
    );

    // === Value expectation ===

    reg [7:0] expected = 0;

    always @(posedge clk) begin
        if (reset)
            expected <= 0;
        else
            expected <= expected + 1;

        if (val_c1 !== expected) begin
            $display("ERROR at time %t: val_c1 = %0d, expected = %0d", $time, val_c1, expected);
        end
    end


    // === Test sequence ===
    
    initial begin
        $dumpfile("tb_Counter.vcd");
        $dumpvars(0, tb_Counter);
        // $monitor("At time %t, value = %h (%0d)", $time, val_c1, val_c1);

        # 17;
        pulse_reset(11);
        # 29;
        pulse_reset(5);
        # 513;
        
        $display("Simulation complete");
        $finish;
    end

endmodule
