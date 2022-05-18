#ifndef __IRQ_H
#define __IRQ_H

#include <stdint.h>
#include <stdbool.h>
#include "sys.h"
#include "blink.h"

uint32_t *irq(uint32_t *regs, uint32_t irqs);

#endif //__IRQ_H
