void print_char(char c);

void print_string(const char *s);

void print_int(unsigned int x);

void print_hex(unsigned int x);

void *memcpy(void *s1, const void *s2, unsigned int n);

void *memset(void *str, int c, unsigned int n);

unsigned int get_hart_id();

void wait_for_compose();

void delay_cycles(unsigned int n_cycles);

#define MCOMPOSE_MODE_WIDE 0
#define MCOMPOSE_MODE_REDUNDANT 1
#define set_mcompose_mode(mode) asm volatile ("csrwi 0x7c1, %0" : : "i" (mode))
#define set_mcompose(n) asm volatile ("csrwi 0x7c0, %0" : : "i" (n))
#define get_mcompose() ({unsigned int mcompose; \
                         asm ("csrr %0, 0x7c0" : "=r"(mcompose) : : ); \
                         mcompose; })

#define get_hart_id()  ({unsigned int id; \
                         asm ("csrr %0, 0xf14" : "=r"(id)       : : ); \
                         id;})

#define save_regs(addr) { \
    asm ("sw x1, 0(%0) \n \
          sw x2, 4(%0) \n \
          sw x3, 8(%0) \n \
          sw x4, 12(%0) \n \
          sw x5, 16(%0) \n \
          sw x6, 20(%0) \n \
          sw x7, 24(%0) \n \
          sw x8, 28(%0) \n \
          sw x9, 32(%0) \n \
          sw x10, 36(%0) \n \
          sw x11, 40(%0) \n \
          sw x12, 44(%0) \n \
          sw x13, 48(%0) \n \
          sw x14, 52(%0) \n \
          sw x15, 56(%0) \n \
          sw x16, 60(%0) \n \
          sw x17, 64(%0) \n \
          sw x18, 68(%0) \n \
          sw x19, 72(%0) \n \
          sw x20, 76(%0) \n \
          sw x21, 80(%0) \n \
          sw x22, 84(%0) \n \
          sw x23, 88(%0) \n \
          sw x24, 92(%0) \n \
          sw x25, 96(%0) \n \
          sw x26, 100(%0) \n \
          sw x27, 104(%0) \n \
          sw x28, 108(%0) \n \
          sw x29, 112(%0) \n \
          sw x30, 116(%0) \n \
          sw x31, 120(%0) " \
        : \
        : "r"(addr) ); \
}

#define load_regs(addr) { \
    asm ("lw x1, 0(%0) \n \
          lw x2, 4(%0) \n \
          lw x3, 8(%0) \n \
          lw x4, 12(%0) \n \
          lw x5, 16(%0) \n \
          lw x6, 20(%0) \n \
          lw x7, 24(%0) \n \
          lw x8, 28(%0) \n \
          lw x9, 32(%0) \n \
          lw x10, 36(%0) \n \
          lw x11, 40(%0) \n \
          lw x12, 44(%0) \n \
          lw x13, 48(%0) \n \
          lw x14, 52(%0) \n \
          lw x15, 56(%0) \n \
          lw x16, 60(%0) \n \
          lw x17, 64(%0) \n \
          lw x18, 68(%0) \n \
          lw x19, 72(%0) \n \
          lw x20, 76(%0) \n \
          lw x21, 80(%0) \n \
          lw x22, 84(%0) \n \
          lw x23, 88(%0) \n \
          lw x24, 92(%0) \n \
          lw x25, 96(%0) \n \
          lw x26, 100(%0) \n \
          lw x27, 104(%0) \n \
          lw x28, 108(%0) \n \
          lw x29, 112(%0) \n \
          lw x30, 116(%0) \n \
          lw x31, 120(%0) " \
        : \
        : "r"(addr) ); \
}

#define restore_regs(addr) { \
    asm ("la   x31, %0 \n \
          csrr x30, 0xf14 \n \
          addi x29, zero, 124 \n \
          mul  x29, x29, x30 \n \
          add  x31, x31, x29 \n \
          lw x1, 0(x31) \n \
          lw x2, 4(x31) \n \
          lw x3, 8(x31) \n \
          lw x4, 12(x31) \n \
          lw x5, 16(x31) \n \
          lw x6, 20(x31) \n \
          lw x7, 24(x31) \n \
          lw x8, 28(x31) \n \
          lw x9, 32(x31) \n \
          lw x10, 36(x31) \n \
          lw x11, 40(x31) \n \
          lw x12, 44(x31) \n \
          lw x13, 48(x31) \n \
          lw x14, 52(x31) \n \
          lw x15, 56(x31) \n \
          lw x16, 60(x31) \n \
          lw x17, 64(x31) \n \
          lw x18, 68(x31) \n \
          lw x19, 72(x31) \n \
          lw x20, 76(x31) \n \
          lw x21, 80(x31) \n \
          lw x22, 84(x31) \n \
          lw x23, 88(x31) \n \
          lw x24, 92(x31) \n \
          lw x25, 96(x31) \n \
          lw x26, 100(x31) \n \
          lw x27, 104(x31) \n \
          lw x28, 108(x31) \n \
          lw x29, 112(x31) \n \
          lw x30, 116(x31) \n \
          lw x31, 120(x31) " \
        : \
        : "i"(addr) ); \
}
