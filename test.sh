#!/bin/sh

echo -e "\n=== ✅ Compiling verilog... ✅ ===\n"

# Compile our files
# iverilog -o tb_Counter.vvp -s tb_Counter Counter.v
iverilog -o tb_UartRx.vvp -s tb_UartRx UartRx.v

ret=$?

if [ $ret -ne 0 ]; then
    echo -e "\n=== ❌ Compilation failed ❌ ===\n"
    exit $ret
fi

echo -e "\n=== ✅ Compilation finished, simulating... ✅ ===\n"

# Run the simulation
# vvp tb_Counter.vvp
vvp tb_UartRx.vvp

ret=$?

if [ $ret -ne 0 ]; then
    echo -e "\n=== ❌ Simulation failed ❌ ===\n"
    exit $ret
fi

echo -e "\n=== ✅ Simulation finished ✅ ===\n"

echo -e "Execute the following to see the resulting waveforms:\n"
echo -e "\tgtkwave ./tb_UartRx.vcd\n"

gtkwave ./tb_UartRx.vcd 
