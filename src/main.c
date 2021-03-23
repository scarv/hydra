#include "sys.h"
#include "multi_arithmetic.h"
#include "stats.h"
#include "blink.h"

#define NUM_WORDS 16
#define NUM_BYTES (NUM_WORDS << 2)
#define NUM_BITS  (NUM_WORDS << 5)

#define NUM_CORES 4

unsigned int a[NUM_WORDS] = {0xdeadbeef, 0xab43032b};
unsigned int b[NUM_WORDS] = {0xdd00d420, 0x9beeff00};
unsigned int res[NUM_WORDS * 2] = {0};

// Pre-calculated correct results
const unsigned int a_xor_b[NUM_WORDS] = {0x3ad6acf, 0x30adfc2b, 0, 0};
const unsigned int a_plus_b[NUM_WORDS] = {0xbbae930f, 0x4732022c, 1, 0};
const unsigned int a_minus_b[NUM_WORDS] = {0x01aceacf, 0xf54042b, 0, 0};
const unsigned int a_times_b[NUM_WORDS * 2] = {0xad5c9e0, 0xe9ec8b8, 0xd69e5297, 0x685175d0};

const uint8_t aes_key[] = { 0x2b, 0x7e, 0x15, 0x16, 0x28, 0xae, 0xd2, 0xa6, 0xab, 0xf7, 0x15, 0x88, 0x09, 0xcf, 0x4f, 0x3c };
const uint8_t aes_out[] = { 0x3a, 0xd7, 0x7b, 0xb4, 0x0d, 0x7a, 0x36, 0x60, 0xa8, 0x9e, 0xca, 0xf3, 0x24, 0x66, 0xef, 0x97 };

uint8_t aes_in[]  = { 0x6b, 0xc1, 0xbe, 0xe2, 0x2e, 0x40, 0x9f, 0x96, 0xe9, 0x3d, 0x7e, 0x11, 0x73, 0x93, 0x17, 0x2a };

uint32_t regs_context[NUM_CORES][31];

int check_result(const void *a, const void *b, int n_bytes) {
    char *a_bytes = (char*)a;
    char *b_bytes = (char*)b;
    int success = 1;
    for (int i = 0; i < n_bytes; i++) {
        if (a_bytes[i] != b_bytes[i]) success = 0;
    }
    return success;
}

void test_xor() {
    print_int(NUM_BITS);
    print_string("-bit XOR: ");
    multi_xor_stats(a, b, res, NUM_WORDS);

    if (!check_result(res, a_xor_b, NUM_BYTES)) {
        print_string("multi_xor failed!\n");
    }

    memset(res, 0x55, NUM_BYTES);

    print_int(NUM_BITS);
    print_string("-bit composed XOR: ");
    multi_xor_comp_stats(a, b, res, NUM_WORDS, NUM_CORES);

    if (!check_result(res, a_xor_b, NUM_BYTES)) {
        print_string("composed multi_xor failed!\n");
    }
}

void test_add() {
    print_int(NUM_BITS);
    print_string("-bit addition: ");
    multi_add_stats(a, b, res, NUM_WORDS);

    if (!check_result(res, a_plus_b, NUM_BYTES)) {
        print_string("multi_add failed!\n");
    }

    memset(res, 0x55, NUM_BYTES);

    print_int(NUM_BITS);
    print_string("-bit composed addition: ");
    multi_add_comp_stats(a, b, res, NUM_WORDS, NUM_CORES);

    if (!check_result(res, a_plus_b, NUM_BYTES)) {
        print_string("composed multi_add failed!\n");
    }
}

void test_subtract() {
    print_int(NUM_BITS);
    print_string("-bit subtraction: ");
    multi_sub_stats(a, b, res, NUM_WORDS);

    if (!check_result(res, a_minus_b, NUM_BYTES)) {
        print_string("multi_sub failed!\n");
    }
}

void test_multiply() {
    print_int(NUM_BITS);
    print_string("-bit multiplication: ");
    multi_mult_stats(a, b, res, NUM_WORDS);

    if (!check_result(res, a_times_b, NUM_BYTES * 2)) {
        print_string("multi_mult failed!\n");
    }

    memset(res, 0x55, NUM_BYTES * 2);

    print_int(NUM_BITS);
    print_string("-bit composed multiplication: ");
    set_mcompose(NUM_CORES);
    set_mcompose(0);
    multi_mult_comp_stats(a, b, res, NUM_WORDS, NUM_CORES);

    if (!check_result(res, a_times_b, NUM_BYTES * 2)) {
        print_string("composed multi_mult failed!\n");
    }
}

void test_aes() {
    struct AES_ctx ctx;

    print_string("AES key expansion: ");
    AES_init_ctx_stats(&ctx, aes_key);
    
    print_string("AES encrypting one block: ");
    AES_ECB_encrypt_stats(&ctx, aes_in);

    if (!check_result(aes_in, aes_out, 16)) {
        print_string("AES encryption failed!\n");
    }
}

int main()
{
    unsigned int hart_id = get_hart_id();

    if (hart_id == 0) {
        print_string("Hello from core #0\n");

        test_xor();
        test_add();
        test_subtract();
        test_multiply();

        save_regs(regs_context[0]);
        set_mcompose(NUM_CORES);
        set_mcompose(0);

        print_string("\nEntering redundant mode\n");
        set_mcompose_mode(MCOMPOSE_MODE_REDUNDANT);
        set_mcompose(NUM_CORES);
        test_aes();
        print_string("Exiting redundant mode\n");
        set_mcompose(0);
        set_mcompose_mode(MCOMPOSE_MODE_WIDE);

    } else {
        multi_xor_comp(a, b, res, NUM_WORDS, NUM_CORES);
        multi_add_comp(a, b, res, NUM_WORDS, NUM_CORES);
        set_mcompose(NUM_CORES);
        set_mcompose(0);
        multi_mult_comp(a, b, res, NUM_WORDS, NUM_CORES);

        save_regs(regs_context[hart_id]);
        set_mcompose(NUM_CORES);
        load_regs(regs_context[0]);
        set_mcompose(NUM_CORES);
        restore_regs(regs_context);
    }

    blink(hart_id);
    return 0;
}
