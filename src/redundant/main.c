#include <stdint.h>
#include <stdio.h>

#include "hal/sys.h"
#include "hal/blink.h"
#include "aes/aes.h"
#include "share.h"
#include "test.h"

uint32_t regs_context[NUM_CORES][31];

struct AES_ctx ctx;
uint32_t  param1[7] = {0,1,2,3,4,5,6};
uint32_t  param2[7] = {10,11,12,13,14,15,16};
uint32_t  res[7];

int check_result(const void *a, const void *b, int n_bytes) {
    char *a_bytes = (char*)a;
    char *b_bytes = (char*)b;
    int success = 1;
    for (int i = 0; i < n_bytes; i++) {
        if (a_bytes[i] != b_bytes[i]) success = 0;
    }
    return success;
}

void test_aes() {

    //print_string("AES key expansion: ");
    
    print_string("AES encrypting one block: ");
    print_string("\nEntering redundant mode\n");
    set_mcompose_mode(MCOMPOSE_MODE_REDUNDANT);
    set_mcompose(NUM_CORES);
    AES_init_ctx(&ctx, aes_key);
    AES_ECB_encrypt(&ctx, aes_in);
    set_mcompose(0);
    set_mcompose_mode(MCOMPOSE_MODE_WIDE);
    print_string("Exited redundant mode\n");

    if (!check_result(aes_in, aes_out, 16)) {
        print_string("AES encryption failed!\n");
    }
    
}

void simple_func (uint32_t *res,uint32_t  *param1, uint32_t *param2,uint32_t len) {
    for (int i = 0; i < len; i++) {
        res[i] = param1[i] + param2[i];
    }
}
void test_simple_redundant() {
    uint32_t  len;
    print_string("test simple redundant mode\n");
    print_string("\nEntering redundant mode\n");
    set_mcompose_mode(MCOMPOSE_MODE_REDUNDANT);
    set_mcompose(NUM_CORES);
    len = 7;
    simple_func(res, param1, param2, len);
    set_mcompose(0);
    set_mcompose_mode(MCOMPOSE_MODE_WIDE);
    print_string("Exited redundant mode\n");
}


int main()
{
    unsigned int hart_id = get_hart_id();

    if (hart_id == 0) {
        print_string("Hello from core #0\n");

        //test_simple_redundant();
        test_aes();


    } else {
        while(1){
        wait_for_compose(); 
		}
    }

    blink(hart_id);
    return 0;
}
