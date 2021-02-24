void print_char(char c);

void print_string(const char *s);

void print_int(unsigned int x);

void print_hex(unsigned int x);

void *memcpy(void *s1, const void *s2, unsigned int n);

void *memset(void *str, int c, unsigned int n);

unsigned int get_hart_id();

unsigned int get_mcompose();

void delay_cycles(unsigned int n_cycles);

#define set_mcompose(n) asm volatile ("csrwi 0x7c0, %0" : : "i" (n))
