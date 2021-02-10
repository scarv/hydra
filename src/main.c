#include "uart.h"
#include "stats.h"
#include "blink.h"

uint32_t get_hart_id() {
    uint32_t id;
    asm ("csrr %0, 0xf14" : "=r"(id) : : );
    return id;
}

uint32_t get_mcompose() {
    uint32_t mcompose;
    asm ("csrr %0, 0x7c0" : "=r"(mcompose) : : );
    return mcompose;
}

void set_mcompose(uint32_t mcompose) {
    asm volatile ("csrw 0x7c0, %0" : : "r"(mcompose) : );
}

void delay_cycles(uint32_t n_cycles) {
    uint32_t cycles;
    asm volatile ("rdcycle %0" : "=r"(cycles) : : );
    uint32_t end_cycles = cycles + n_cycles;
    while (cycles < end_cycles) {
        asm volatile ("rdcycle %0" : "=r"(cycles) : : );
    }
}

int check_result(const void *a, const void *b, int n_bytes) {
    char *a_bytes = (char*)a;
    char *b_bytes = (char*)b;
    int success = 1;
    for (int i = 0; i < n_bytes; i++) {
        if (a_bytes[i] != b_bytes[i]) success = 0;
    }
    return success;
}

int __attribute__((optimize("O0"))) main()
{
    if (get_hart_id() == 0) {

        uint32_t mcomp = get_mcompose();
        if (mcomp != 0) print_string("Reading mcompose failed!\n");
        set_mcompose(2);
        mcomp = get_mcompose();
        if (mcomp != 2) print_string("Writing mcompose failed!\n");

        delay_cycles(12000000);
        set_mcompose(0);

        #define NUM_WORDS 4
        unsigned int a[NUM_WORDS] = {0xdeadbeef, 0xab43032b, 0, 0};
        unsigned int b[NUM_WORDS] = {0xdd00d420, 0x9beeff00, 0, 0};
        unsigned int res[NUM_WORDS * 2] = {0, 0, 0, 0, 0, 0, 0, 0};

        unsigned int a_plus_b[NUM_WORDS] = {0xbbae930f, 0x4732022c, 1, 0};
        unsigned int a_minus_b[NUM_WORDS] = {0x01aceacf, 0xf54042b, 0, 0};
        unsigned int a_times_b[NUM_WORDS * 2] = {0xad5c9e0, 0xe9ec8b8, 0xd69e5297, 0x685175d0, 0, 0, 0, 0};

        print_int(NUM_WORDS << 5);
        print_string("-bit addition: ");
        multi_add_stats(a, b, res, 4);

        if (!check_result(res, a_plus_b, NUM_WORDS << 2)) {
            print_string("multi_add failed!\n");
        }

        print_int(NUM_WORDS << 5);
        print_string("-bit subtraction: ");
        multi_sub_stats(a, b, res, 4);

        if (!check_result(res, a_minus_b, NUM_WORDS << 2)) {
            print_string("multi_sub failed!\n");
        }

        // print_int(NUM_WORDS << 5);
        // print_string("-bit multiplication: ");
        // multi_mult_stats(a, b, res, 4);

        // if (check_result(res, a_times_b, NUM_WORDS << 3)) {
        //     print_string("multi_mult failed!\n");
        // }

        uint8_t key[] = { 0x2b, 0x7e, 0x15, 0x16, 0x28, 0xae, 0xd2, 0xa6, 0xab, 0xf7, 0x15, 0x88, 0x09, 0xcf, 0x4f, 0x3c };
        uint8_t out[] = { 0x3a, 0xd7, 0x7b, 0xb4, 0x0d, 0x7a, 0x36, 0x60, 0xa8, 0x9e, 0xca, 0xf3, 0x24, 0x66, 0xef, 0x97 };

        uint8_t in[]  = { 0x6b, 0xc1, 0xbe, 0xe2, 0x2e, 0x40, 0x9f, 0x96, 0xe9, 0x3d, 0x7e, 0x11, 0x73, 0x93, 0x17, 0x2a };
        struct AES_ctx ctx;

        print_string("AES key expansion: ");
        AES_init_ctx_stats(&ctx, key);
        
        print_string("AES encrypting one block: ");
        AES_ECB_encrypt_stats(&ctx, in);

        if (!check_result(in, out, 16)) {
            print_string("AES encryption failed!\n");
        }

    }

    blink(get_hart_id());
}
