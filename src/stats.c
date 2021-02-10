#include "stats.h"
#include "uart.h"

void print_stats(unsigned int cycles, unsigned int instructions) {
    print_int(cycles);
    print_string(" cycles and ");
    print_int(instructions);
    print_string(" instructions\n");
}
