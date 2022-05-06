#include <stdint.h>
#include <stdio.h>
#include <stdint.h>
#include <stdio.h>
#include "mp_add.h"

unsigned int r[NUM_WORDS * 2];

unsigned int x_eval[NUM_WORDS * 4];
unsigned int y_eval[NUM_WORDS * 4];
unsigned int r_norm[NUM_WORDS * 8];
unsigned int r_comp[NUM_WORDS * 8];

void test_mp_add() {
    print_int(NUM_BITS);
    print_string("-bit addition: ");
    MEASURE(r[NUM_WORDS] = mp_add_ref(x, y, r, NUM_WORDS));

    if (!check_result(r, x_add_y, NUM_BYTES + 4)) {
        print_string("multi_add failed!\n");
    }

    memset(r, 0x55, NUM_BYTES);

    print_int(NUM_BITS);
    print_string("-bit composed addition: ");
    MEASURE(r[NUM_WORDS] = mp_add_com(x, y, r, NUM_WORDS, NUM_CORES));

    if (!check_result(r, x_add_y, NUM_BYTES + 4)) {
        print_string("composed multi_add failed!\n");
    }
}


void eval_mp_add(int len) {
    int n_bits = len << 5;

    print_int(n_bits);
    memset(x_eval, 0x55, len*4);
    memset(y_eval, 0xAA, len*4);

    print_string("-bit addition: ");
    MEASURE(r_norm[len] = mp_add_ref(x_eval, y_eval, r_norm, len));

    print_int(n_bits);
    print_string("-bit composed addition: ");
    MEASURE(r_comp[len] = mp_add_com(x_eval, y_eval, r_comp, len, NUM_CORES));

    if (!check_result(r_norm, r_comp, (len+1)*4)) {
        print_string("multi_adds are not matched!\n");
    }
}

