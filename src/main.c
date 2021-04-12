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
    ctx.l_N = NUM_WORDS;
    ctx.omega = omega_N[0];
    memcpy(ctx.N, N, NUM_BYTES);
    memcpy(ctx.rho_0, rho_0, NUM_BYTES);
    memcpy(ctx.rho_1, rho_1, NUM_BYTES);
    memcpy(ctx.rho_2, rho_2, NUM_BYTES);
    limb_t omega[NUM_CORES];
    memcpy(omega, omega_N, NUM_CORES << 2);
    
    print_string("Computing omega...\n");
    //mrz_precomp_omega_comp(omega, (limb_t*)N, NUM_CORES);

    if (!check_result(omega, omega_N, NUM_CORES << 2)) {
        print_string("omega doesn't match!\n");
    }

    print_string("Computing rho...\n");
    //mrz_precomp_rho_comp(ctx.rho_0, ctx.rho_1, ctx.rho_2, (limb_t*)N, NUM_WORDS, NUM_CORES);

    if (!check_result(ctx.rho_0, rho_0, NUM_BYTES)) {
        print_string("rho_0 doesn't match!\n");
    }

    if (!check_result(ctx.rho_1, rho_1, NUM_BYTES)) {
        print_string("rho_1 doesn't match!\n");
    }

    if (!check_result(ctx.rho_2, rho_2, NUM_BYTES)) {
        print_string("rho_2 doesn't match!\n");
    }

    print_string("Computing exponentiation...\n");

    mrz_mul_asm(NUM_WORDS, ctx.N, ctx.omega, r, x, ctx.rho_2);
    MEASURE(mrz_exp(&ctx, (limb_t*)r, (limb_t*)r, (limb_t*)y, NUM_WORDS));
    mrz_mul_asm(NUM_WORDS, ctx.N, ctx.omega, r, r, ctx.rho_0);

    if (!check_result(r, x_exp_y_mod_N, NUM_BYTES)) {
        print_string("mrz_exp failed!\n");
        print_hex(r[15]); print_char(' ');
        print_hex(r[14]); print_char(' ');
        print_hex(r[13]); print_char(' ');
        print_hex(r[12]); print_char(' ');
        print_hex(r[11]); print_char(' ');
        print_hex(r[10]); print_char(' ');
        print_hex(r[9]); print_char(' ');
        print_hex(r[8]); print_char(' ');
        print_hex(r[7]); print_char(' ');
        print_hex(r[6]); print_char(' ');
        print_hex(r[5]); print_char(' ');
        print_hex(r[4]); print_char(' ');
        print_hex(r[3]); print_char(' ');
        print_hex(r[2]); print_char(' ');
        print_hex(r[1]); print_char(' ');
        print_hex(r[0]); print_char('\n');

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

        //test_xor();
        //test_add();
        //test_subtract();
        //test_multiply();
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
        wait_for_compose(); // xor
        wait_for_compose(); // add
        wait_for_compose(); // multiply

        wait_for_compose(); // mrz_precomp_omega
        wait_for_compose(); // mrz_precomp_rho

        save_regs(regs_context[hart_id]);
        set_mcompose(NUM_CORES);
        load_regs(regs_context[0]);
        set_mcompose(NUM_CORES);
        restore_regs(regs_context);
    }

    blink(hart_id);
    return 0;
}
