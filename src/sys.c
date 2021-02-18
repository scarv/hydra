#include "sys.h"

static volatile char *uart_tx = (char*)0x20000000;

void print_char(char c) {
    while (*uart_tx != 1);
    *uart_tx = c;
}

void print_string(const char *s) {
    for (int i = 0; s[i] != '\0'; i++) print_char(s[i]);
}

void print_int(unsigned int x) {
    unsigned int length = 1;
    unsigned int base = 10;
    // Explicitly deal with highest digit to avoid overflow problems
    if (x >= 1000000000) {
        unsigned int digit = x / 1000000000;
        for (int i = 0; i < digit; i++) x = x - 1000000000;
        print_char('0' + (char)digit);
        length = 9;
        base = 1000000000;
    } else {
        while (x >= base) {
            base *= 10;
            length++;
        }
    }
    for (int i = 0; i < length; i++) {
        base /= 10;
        unsigned int digit = x / base;
        x -= digit * base;
        print_char('0' + (char)digit);
    }
}

void *memcpy(void *s1, const void *s2, unsigned int n) {
    char *s1c = (char*)s1;
    char *s2c = (char*)s2;
    for (int i = 0; i < n; i++) {
        s1c[i] = s2c[i];
    }
    return s1;
}

void *memset(void *str, int c, unsigned int n) {
    unsigned char *dest = (unsigned char*)str;
    for (int i = 0; i < n; i++) {
        dest[i] = (unsigned char)c;
    }
    return str;
}

unsigned int get_hart_id() {
    unsigned int id;
    asm ("csrr %0, 0xf14" : "=r"(id) : : );
    return id;
}

unsigned int get_mcompose() {
    unsigned int mcompose;
    asm ("csrr %0, 0x7c0" : "=r"(mcompose) : : );
    return mcompose;
}

void delay_cycles(unsigned int n_cycles) {
    unsigned int cycles;
    asm volatile ("rdcycle %0" : "=r"(cycles) : : );
    unsigned int end_cycles = cycles + n_cycles;
    while (cycles < end_cycles) {
        asm volatile ("rdcycle %0" : "=r"(cycles) : : );
    }
}
