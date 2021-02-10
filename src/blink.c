#include <stdint.h>
#include "uart.h"

#define COUNTER_BITS 19

void output(uint8_t c, int led_num)
{
	*(volatile char*)(0x10000000 + led_num) = c;
}

void blink(int led_num)
{
	int led_state = 0;
	for (uint32_t counter = 0;; counter++) {
		asm volatile ("" : : "r"(counter));
		if ((counter & ~(~0 << COUNTER_BITS)) == 0) {
			output(led_state, led_num);
			led_state = !led_state;
		}
	}
}
