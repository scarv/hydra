// This is free and unencumbered software released into the public domain.
//
// Anyone is free to copy, modify, publish, use, compile, sell, or
// distribute this software, either in source code form or as a compiled
// binary, for any purpose, commercial or non-commercial, and by any
// means.

#include "irq.h"

static unsigned int *gpo     = (unsigned int*)GPO_BASE;

uint32_t *irq(uint32_t *regs, uint32_t irqs)
{
    if ((irqs & 0x1) == 1) {
        print_string("Fault detected!\n");
    //recovering by redoing faulted instruction
    //regs[0] -=4;
    //reset system
    }
    if ((irqs & 0x2) == 2) {
        print_string("Watchdog timeout!\n");
    }

    *gpo = 0x10;
    set_mcompose(0);

	return regs;
}
