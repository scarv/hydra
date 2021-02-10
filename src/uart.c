#include "uart.h"

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
    while (x >= base) {
        base *= 10;
        length++;
    }
    for (int i = 0; i < length; i++) {
        base /= 10;
        unsigned int digit = x / base;
        x -= digit * base;
        print_char('0' + (char)digit);
    }
}
