#include <stdint.h>
#include <stdio.h>

#include "hal/sys.h"
#include "hal/blink.h"
#include "mp_xor/mp_xor.h"
#include "mp_add/mp_add.h"
#include "mp_mul/mp_mul.h"
#include "mrz_exp/mrz_exp.h"
#include "share.h"
#include "test.h"

int check_result(const void *a, const void *b, int n_bytes) {
    char *a_bytes = (char*)a;
    char *b_bytes = (char*)b;
    int success = 1;
    for (int i = 0; i < n_bytes; i++) {
        if (a_bytes[i] != b_bytes[i]) success = 0;
    }
    return success;
}

int main()
{
    unsigned int hart_id = get_hart_id();

    if (hart_id == 0) {
        print_string("Hello from core #0\n");

        test_mp_xor();
        test_mp_add();
        test_mp_mul();
        test_mrz_exp();

        print_string("Performance evaluation:\n");

        eval_mp_add( 32); //run 32-word-wide values (1024-bit numbers)
        eval_mp_mul( 32); //run 32-word-wide values (1024-bit numbers)
        eval_mrz_exp(32); //run 32-word-wide values (1024-bit numbers)
    } else {
        while(1){
        wait_for_compose(); 
		}
    }

    //blink(hart_id);
    return 0;
}
