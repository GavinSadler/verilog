
module Counter #(
    parameter OUT_WIDTH = 8
) (
    input i_clk,
    input i_reset,
    output [OUT_WIDTH-1:0] o_out
);

    reg [OUT_WIDTH-1:0] r_out = {OUT_WIDTH{1'b0}};
    
    always @(posedge i_clk or posedge i_reset)
        if(i_reset)
            r_out = {OUT_WIDTH{1'b0}};
        else
            r_out <= o_out + 1;

    assign o_out = r_out;

endmodule

module tb_Counter;

    initial begin
        $dumpfile("tb_Counter.vcd");
        $dumpvars(0, tb_Counter);
    end


    reg reset;

    initial begin
        # 17 reset = 1;
        # 11 reset = 0;
        # 29 reset = 1;
        # 11 reset = 0;
        # 100 $stop;
    end

    // Regular pulsing clock
    reg clk;
    always #5 clk = ~clk;

    wire [7:0] val;
    Counter c1 (clk, reset, val);

    initial
        $monitor("At time %t, value = %h (%0d)", $time, val, val);
    
endmodule
