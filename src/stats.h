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
