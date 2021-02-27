#include <stdlib.h>
#include "Vsimple_fifo.h"
#include "verilated.h"

uint32_t cyc_count;
uint32_t data=0xffffffff;

// Test Status
bool reset_done = false;

bool is_empty(Vsimple_fifo* dut) {return bool(dut->empty);}
bool is_full(Vsimple_fifo* dut) {return bool(dut->full);}

void tick(Vsimple_fifo* dut, uint64_t cyc_count) {
    // Clock tick
    dut->clk = 1;
	dut->eval();
	dut->clk = 0;
	dut->eval();
    // Reset
    if (cyc_count == 0x1fe) {
        dut->reset_n = 0;
        printf("\nRESET :0x%x", dut->reset_n);
    }  
    if (cyc_count == 0x1ff) {
        dut->reset_n = 1;
        printf("\nRESET :0x%x", dut->reset_n);
        reset_done = true;
    }
}

void push(Vsimple_fifo* dut) {
    if(!is_full(dut)){
        data        = data << 1;
        dut->push   = 1;
        dut->data_i = data; 
    }
}

void pop(Vsimple_fifo* dut) {
    if (!is_empty(dut)) {
        dut->pop = 1;
    }
}

void print_vars(Vsimple_fifo* dut) {
    printf("\n");
    printf("EMPTY:0x%x, FULL:0x%x, PUSH:0x%x, POP:0x%x, RD_PTR:0x%x, WR_PTR:0x%x", 
    dut->empty,
    dut->full,
    dut->push,
    dut->pop,
    dut->rd_ptr_,
    dut->wr_ptr_);
    // printf("DATA_I  :0x%x\n", dut->data_i);
    // printf("DATA_O  :0x%x\n", dut->data_o);
}

void reset(Vsimple_fifo* dut) {
    dut->push   = 0;
    dut->pop    = 0;
    dut->data_i = 0;
}

int main(int argc, char **argv) {
	// Initialize Verilators variables
	Verilated::commandArgs(argc, argv);

	// Create an instance of our module under test
	Vsimple_fifo *dut = new Vsimple_fifo;

	// Tick the clock until we are done
    cyc_count = 0;

	while(!Verilated::gotFinish()) {
        cyc_count++;
        print_vars(dut);
        tick(dut, cyc_count);
        //reset(dut);
        if (reset_done & cyc_count == 0x200) {push(dut);}
        if (reset_done & cyc_count == 0x201) {push(dut);}
        if (reset_done & cyc_count == 0x202) {pop(dut);} 
        if (reset_done & cyc_count == 0x203) {break;}
    } exit(EXIT_SUCCESS);
}