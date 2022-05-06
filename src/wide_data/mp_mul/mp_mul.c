#include <stdint.h>
#include <stdio.h>
#include "mp_mul.h"

unsigned int r[NUM_WORDS * 2];

unsigned int x_eval[NUM_WORDS * 4];
unsigned int y_eval[NUM_WORDS * 4];
unsigned int r_norm[NUM_WORDS * 8];
unsigned int r_comp[NUM_WORDS * 8];

void test_mp_mul() {
    print_int(NUM_BITS);
    print_string("-bit multiplication: ");
    MEASURE(mp_mul_ref(x, y, r, NUM_WORDS));

    if (!check_result(r, x_times_y, NUM_BYTES * 2)) {
        print_string("multi_mult failed!\n");
    }

    memset(r, 0x55, NUM_BYTES * 2);

    print_int(NUM_BITS);
    print_string("-bit composed multiplication: ");
    MEASURE(mp_mul_com(x, y, r, NUM_WORDS, NUM_CORES));

    if (!check_result(r, x_times_y, NUM_BYTES * 2)) {
        print_string("composed multi_mult failed!\n");
    }
}

void eval_mp_mul(int len) {
    int n_bits = len << 5;

    print_int(n_bits);
    memset(x_eval, 0x55, len*4);
    memset(y_eval, 0xAA, len*4);

    print_string("-bit multiplication: ");
    MEASURE(mp_mul_ref(x_eval, y_eval, r_norm, len));

    print_int(n_bits);
    print_string("-bit composed multiplication: ");
    MEASURE(mp_mul_com(x_eval, y_eval, r_comp, len, NUM_CORES));

    if (!check_result(r_norm, r_comp, len * 8)) {
        print_string("multi_mults are not matched!\n");
    }
}

