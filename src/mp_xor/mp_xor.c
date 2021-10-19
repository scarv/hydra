#include <stdint.h>
#include <stdio.h>
#include "mp_xor.h"

unsigned int r[NUM_WORDS * 2];

void test_mp_xor() {
    #ifndef HW_DEBUG
    print_int(NUM_BITS);
    print_string("-bit XOR: ");
    #endif
    MEASURE(mp_xor_ref(x, y, r, NUM_WORDS));

    if (!check_result(r, x_xor_y, NUM_BYTES)) {
        print_string("multi_xor failed!\n");
    }

    memset(r, 0x55, NUM_BYTES);
    #ifndef HW_DEBUG
    print_int(NUM_BITS);
    print_string("-bit composed XOR: ");
	#endif
    MEASURE(mp_xor_com(x, y, r, NUM_WORDS, NUM_CORES));

    if (!check_result(r, x_xor_y, NUM_BYTES)) {
        print_string("composed multi_xor failed!\n");
    }
}


