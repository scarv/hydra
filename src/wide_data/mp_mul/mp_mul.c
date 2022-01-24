#include <stdint.h>
#include <stdio.h>
#include "mp_mul.h"

unsigned int r[NUM_WORDS * 2];

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

