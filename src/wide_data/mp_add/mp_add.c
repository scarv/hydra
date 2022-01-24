#include <stdint.h>
#include <stdio.h>
#include <stdint.h>
#include <stdio.h>
#include "mp_add.h"

unsigned int r[NUM_WORDS * 2];

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

