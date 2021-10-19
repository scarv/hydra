#ifndef __SHARE_H
#define __SHARE_H

#define NUM_CORES 4
#define NUM_WORDS 16
#define NUM_BYTES (NUM_WORDS << 2)
#define NUM_BITS  (NUM_WORDS << 5)

#ifndef HW_DEBUG
#define MEASURE(stmt) {                                 \
    uint32_t   cycle_pre,   cycle_post;                 \
    uint32_t instret_pre, instret_post;                 \
                                                        \
    asm volatile("rdinstret %0" : "=r" (instret_pre));  \
    asm volatile("rdcycle   %0" : "=r" (cycle_pre));    \
    stmt;                                               \
    asm volatile("rdcycle   %0" : "=r" (cycle_post));   \
    asm volatile("rdinstret %0" : "=r" (instret_post)); \
                                                        \
    print_int(cycle_post - cycle_pre - 4);              \
    print_string(" cycles and ");                       \
    print_int(instret_post - instret_pre - 3);          \
    print_string(" instructions\n");                    \
  }
#else
#define MEASURE(stmt) stmt;
#endif
int check_result(const void *a, const void *b, int n_bytes);
extern const unsigned int x[NUM_WORDS];
extern const unsigned int y[NUM_WORDS];
extern const unsigned int N[NUM_WORDS];

#endif
