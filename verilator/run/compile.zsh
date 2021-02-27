#!/bin/zsh
# g++ -Iobj_dir 
#     -I../build/v4.108/share/verilator/include 
#     -I../build/v4.108/share/verilator/include/vltstd 
#     ../src/main/c++/simple_fifo_tb.cpp 
#     ../build/v4.108/share/verilator/include/verilated.cpp 
#     -o simple_fifo obj_dir/Vsimple_fifo__ALL.o

RUN_DIR=`pwd`
OBJ_DIR='./obj_dir'
INC_DIR='../build/v4.108/share/verilator/include'
CPP_DIR='../src/main/c++'
VER_DIR='../src/main/verilog'

# Remove existing files
#rm -rf $OBJ_DIR simple_fifo
rm -rf simple_fifo

# Verilate verilog source files
verilator -cc -Wall $VER_DIR/simple_fifo.sv --build

# Create DUT object files if not using --build switch
# cd $OBJ_DIR
# make -f Vsimple_fifo.mk
# cd $RUN_DIR

# Compile TB and link with DUT object files
g++ -I$OBJ_DIR -I$INC_DIR -I$INC_DIR/vltstd $CPP_DIR/simple_fifo_tb.cpp $INC_DIR/verilated.cpp -o simple_fifo $OBJ_DIR/Vsimple_fifo__ALL.o

