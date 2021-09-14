#include <stdint.h>
#include <stdio.h>

#include "hal/sys.h"
#include "hal/blink.h"
#include "compose/multi_arithmetic.h"
#include "mp_xor/mp_xor.h"
#include "mp_add/mp_add.h"
#include "mp_mul/mp_mul.h"
#include "mrz_exp/mrz_exp.h"
//#include "aes/aes.h"
#include "share.h"
#include "test.h"

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

/*
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
*/

int main()
{
    unsigned int hart_id = get_hart_id();

    if (hart_id == 0) {
        print_string("Hello from core #0\n");

        test_mp_xor();
        //test_mp_add();
       // test_mp_mul();
        test_mrz_exp();

        //save_regs(regs_context[0]);
        //set_mcompose(NUM_CORES);
        //set_mcompose(0);
/*
        print_string("\nEntering redundant mode\n");
        set_mcompose_mode(MCOMPOSE_MODE_REDUNDANT);
        set_mcompose(NUM_CORES);
        test_aes();
        set_mcompose(0);
        set_mcompose_mode(MCOMPOSE_MODE_WIDE);
        print_string("Exited redundant mode\n");
*/
    } else {
        while(1){
        wait_for_compose(); 
		}
        save_regs(regs_context[hart_id]);
        set_mcompose(NUM_CORES);
        load_regs(regs_context[0]);
        set_mcompose(NUM_CORES);
        restore_regs(regs_context);
    }

    blink(hart_id);
    return 0;
}
