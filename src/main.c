#include "sys.h"
#include "multi_arithmetic.h"
#include "stats.h"
#include "blink.h"
#include "aes.h"
#include "test.h"
#include <stdint.h>
#include <stdio.h>
#include <scarv/scarv.h>

#define NUM_CORES 4

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
    MEASURE(multi_xor(x, y, r, NUM_WORDS));

    if (!check_result(r, x_xor_y, NUM_BYTES)) {
        print_string("multi_xor failed!\n");
    }

    memset(r, 0x55, NUM_BYTES);

    print_int(NUM_BITS);
    print_string("-bit composed XOR: ");
    MEASURE(multi_xor_comp(x, y, r, NUM_WORDS, NUM_CORES));

    if (!check_result(r, x_xor_y, NUM_BYTES)) {
        print_string("composed multi_xor failed!\n");
    }
}

void test_add() {
    print_int(NUM_BITS);
    print_string("-bit addition: ");
    MEASURE(r[NUM_WORDS] = multi_add(x, y, r, NUM_WORDS));

    if (!check_result(r, x_plus_y, NUM_BYTES + 4)) {
        print_string("multi_add failed!\n");
    }

    memset(r, 0x55, NUM_BYTES);

    print_int(NUM_BITS);
    print_string("-bit composed addition: ");
    MEASURE(r[NUM_WORDS] = multi_add_comp(x, y, r, NUM_WORDS, NUM_CORES));

    if (!check_result(r, x_plus_y, NUM_BYTES + 4)) {
        print_string("composed multi_add failed!\n");
    }
}

void test_subtract() {
    print_int(NUM_BITS);
    print_string("-bit subtraction: ");
    MEASURE(multi_sub(y, x, r, NUM_WORDS));

    if (!check_result(r, y_minus_x, NUM_BYTES)) {
        print_string("multi_sub failed!\n");
    }
}

void test_multiply() {
    print_int(NUM_BITS);
    print_string("-bit multiplication: ");
    MEASURE(multi_mult(x, y, r, NUM_WORDS));

    if (!check_result(r, x_times_y, NUM_BYTES * 2)) {
        print_string("multi_mult failed!\n");
    }

    memset(r, 0x55, NUM_BYTES * 2);

    print_int(NUM_BITS);
    print_string("-bit composed multiplication: ");
    MEASURE(multi_mult_comp(x, y, r, NUM_WORDS, NUM_CORES));

    if (!check_result(r, x_times_y, NUM_BYTES * 2)) {
        print_string("composed multi_mult failed!\n");
    }
}

void test_exp() {
    mrz_ctx_t ctx;
    mrz_precomp(&ctx, N, NUM_WORDS);

    print_int(NUM_BITS);
    print_string("-bit modular exponentiation: ");

    mrz_mul(&ctx, r, x, ctx.rho_2);
    MEASURE(mrz_exp(&ctx, r, r, y, NUM_WORDS));
    mrz_mul(&ctx, r, r, ctx.rho_0);

    if (!check_result(r, x_exp_y_mod_N, NUM_BYTES)) {
        print_string("mrz_exp failed!\n");
    }
}

void test_aes() {
    struct AES_ctx ctx;

    //print_string("AES key expansion: ");
    AES_init_ctx(&ctx, aes_key);
    
    //print_string("AES encrypting one block: ");
    AES_ECB_encrypt(&ctx, aes_in);

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
        test_exp();

        save_regs(regs_context[0]);
        set_mcompose(NUM_CORES);
        set_mcompose(0);

        print_string("\nEntering redundant mode\n");
        set_mcompose_mode(MCOMPOSE_MODE_REDUNDANT);
        set_mcompose(NUM_CORES);
        test_aes();
        set_mcompose(0);
        set_mcompose_mode(MCOMPOSE_MODE_WIDE);
        print_string("Exited redundant mode\n");

    } else {
        wait_for_compose();
        wait_for_compose();
        wait_for_compose();

        wait_for_compose();
        for (int i = NUM_WORDS - 1; i >= 0; i--) {
            for (int j = (BITSOF(limb_t) - 1); j >= 0; j--) {
                wait_for_compose();

                if ((y[i] >> j) & 1) {
                    wait_for_compose();
                }
            }
        }
        wait_for_compose();

        save_regs(regs_context[hart_id]);
        set_mcompose(NUM_CORES);
        load_regs(regs_context[0]);
        set_mcompose(NUM_CORES);
        restore_regs(regs_context);
    }

    blink(hart_id);
    return 0;
}
