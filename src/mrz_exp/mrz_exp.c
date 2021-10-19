#include <stdint.h>
#include <stdio.h>
#include "mrz_exp.h"

mrz_ctx_t    ctx;
limb_t       omega[NUM_CORES];
unsigned int r[NUM_WORDS * 2];

void mrz_exp_com( const mrz_ctx_t* ctx, const limb_t* omega, mrz_t r, const mrz_t x, const limb_t* y, int l_y, int n_cores ) {
  mrz_t t;

  memcpy( t, ctx->rho_1, SIZEOF( mrz_t ) );

  for( int i = l_y - 1; i >= 0; i-- ) {
    for( int j = ( BITSOF( limb_t ) - 1 ); j >= 0; j-- ) {
      mrz_mul_com( ctx->l_N, ctx->N, omega, t, t, t, n_cores );

      if( ( y[ i ] >> j ) & 1 ) {
        mrz_mul_com( ctx->l_N, ctx->N, omega, t, t, x, n_cores );
      }
    }
  }
  memcpy( r,          t, SIZEOF( mrz_t ) );
}

void mrz_init(){
    ctx.l_N   = NUM_WORDS;
    ctx.omega = omega_N[0];
    memcpy(ctx.N, N, NUM_BYTES);
    memcpy(ctx.rho_0, rho_0, NUM_BYTES);
    memcpy(ctx.rho_1, rho_1, NUM_BYTES);
    memcpy(ctx.rho_2, rho_2, NUM_BYTES);
    memcpy(omega, omega_N, NUM_CORES << 2);

/*    
    print_string("Computing omega...\n");
    mrz_precomp_omega_comp(omega, (limb_t*)N, NUM_CORES);

    if (!check_result(omega, omega_N, NUM_CORES << 2)) {
        print_string("omega doesn't match!\n");
    }

    print_string("Computing rho...\n");
    mrz_precomp_rho_comp(ctx.rho_0, ctx.rho_1, ctx.rho_2, (limb_t*)N, NUM_WORDS, NUM_CORES);

    if (!check_result(ctx.rho_0, rho_0, NUM_BYTES)) {
        print_string("rho_0 doesn't match!\n");
    }

    if (!check_result(ctx.rho_1, rho_1, NUM_BYTES)) {
        print_string("rho_1 doesn't match!\n");
    }

    if (!check_result(ctx.rho_2, rho_2, NUM_BYTES)) {
        print_string("rho_2 doesn't match!\n");
    }
*/
}

void test_mrz_exp(){

    print_string("Computing exponentiation...\n");
    set_mcompose_mode(MCOMPOSE_MODE_WIDE);
	mrz_init();

    mrz_mul_com(NUM_WORDS, ctx.N, omega, (limb_t*)r, (limb_t*)x, ctx.rho_2, NUM_CORES);

    MEASURE(mrz_exp_com(&ctx, omega, (limb_t*)r, (limb_t*)r, (limb_t*)y, NUM_WORDS, NUM_CORES));

    mrz_mul_com(NUM_WORDS, ctx.N, omega, (limb_t*)r, (limb_t*)r, ctx.rho_0, NUM_CORES);

    if (!check_result(r, x_exp_y_mod_N, NUM_BYTES)) {
        print_string("mrz_exp failed!\n");
    }
}


