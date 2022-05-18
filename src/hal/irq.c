#include "irq.h"

uint32_t *irq(uint32_t *regs, uint32_t irqs)
{
    if ((irqs & 0x1) == 1) {
        print_string("Fault is detected\n");
        outputled(1,0); //set led[0] to complete an evaluation
    }
    if ((irqs & 0x2) == 2) {
        print_string("Watchdog timeout!\n");
    }

	return regs;
}
