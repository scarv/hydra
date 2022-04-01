#include <stdint.h>

#define COUNTER_BITS 19

void outputled(uint8_t c, int led_num)
{
	*(volatile char*)(0x10000000) = c<<led_num;
}

void blink(int led_num)
{
	int led_state = 1;
	for (uint32_t counter = 0;; counter++) {
		asm volatile ("" : : "r"(counter));
		if ((counter & ~(~0 << COUNTER_BITS)) == 0) {
			outputled(led_state, led_num);
			led_state = !led_state;
		}
	}
}
