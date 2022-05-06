#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include "mrz_exp.h"

unsigned int initialVal = 0x12345678;

mrz_ctx_t    ctx, ctx_eval;
limb_t       omega[NUM_CORES];
long unsigned int r[NUM_WORDS * 2];

long unsigned int x_eval[NUM_WORDS * 4];
long unsigned int y_eval[NUM_WORDS * 4];
long unsigned int r_norm[NUM_WORDS * 8];
long unsigned int r_comp[NUM_WORDS * 8];

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

void mrz_init_eval(){
    ctx_eval.l_N   = NUM_WORDS;
    ctx_eval.omega = omega_N[0];
    memcpy(ctx_eval.N, N, NUM_BYTES);
    memcpy(ctx_eval.rho_0, rho_0, NUM_BYTES);
    memcpy(ctx_eval.rho_1, rho_1, NUM_BYTES);
    memcpy(ctx_eval.rho_2, rho_2, NUM_BYTES);
    memcpy(omega, omega_N, NUM_CORES << 2);
}

void test_mrz_exp(){
    print_int(NUM_BITS);
    print_string("-bit ModExp: ");

	mrz_init();

    mrz_mul( &ctx, (limb_t*)r, (limb_t*)x, ctx.rho_2);
//void mrz_exp( const mrz_ctx_t* ctx, mrz_t r, const mrz_t x, const limb_t* y, int l_y ) 
    MEASURE(mrz_exp(&ctx, (limb_t*)r, (limb_t*)r, (limb_t*)y, NUM_WORDS));

    mrz_mul( &ctx, (limb_t*)r, (limb_t*)r, ctx.rho_0);

    if (!check_result(r, x_exp_y_mod_N, NUM_BYTES)) {
        print_string("mrz_exp failed!\n");
    }

    memset(r, 0x55, NUM_BYTES);


    set_mcompose_mode(MCOMPOSE_MODE_WIDE);
    print_int(NUM_BITS);
    print_string("-bit composed ModExp: ");
	//mrz_init();

    mrz_mul_com(NUM_WORDS, ctx.N, omega, (limb_t*)r, (limb_t*)x, ctx.rho_2, NUM_CORES);

    MEASURE(mrz_exp_com(&ctx, omega, (limb_t*)r, (limb_t*)r, (limb_t*)y, NUM_WORDS, NUM_CORES));

    mrz_mul_com(NUM_WORDS, ctx.N, omega, (limb_t*)r, (limb_t*)r, ctx.rho_0, NUM_CORES);

    if (!check_result(r, x_exp_y_mod_N, NUM_BYTES)) {
        print_string("composed mrz_exp failed!\n");
    }
}

void rand_words( uint32_t* x, int len) {
  uint32_t t;
  for( int i = 0; i < len; i++ ) {
     t = ((initialVal * 214013L + 2531011L) >> 16) & 0xffff;
     initialVal = t;
     x[ i ] = (t<<16) | (((initialVal * 214013L + 2531011L) >> 16) & 0xffff);
     initialVal = x[ i ];
  }
}

void eval_mrz_exp(int len){

    mrz_t N; int l_N=len;
    int n_bits = len << 5;

    ctx_eval.l_N   = len;

    rand_words(N, l_N);
    rand_words(x_eval, len);
    rand_words(y_eval, len);

    mrz_precomp( &ctx_eval, N, l_N );

    mrz_precomp_omega_comp(omega, (limb_t*)N, NUM_CORES);

//    print_int(n_bits);
//    print_string("-bit ModExp: ");

    mrz_mul( &ctx_eval, (limb_t*)r_norm, (limb_t*)x_eval, ctx_eval.rho_2);
    mrz_exp( &ctx_eval, (limb_t*)r_norm, (limb_t*)r_norm, (limb_t*)y_eval, len);
    mrz_mul( &ctx_eval, (limb_t*)r_norm, (limb_t*)r_norm, ctx_eval.rho_0);


    set_mcompose_mode(MCOMPOSE_MODE_WIDE);
    print_int(n_bits);
    print_string("-bit composed ModExp: ");

    mrz_mul_com(len, ctx_eval.N, omega, (limb_t*)r_comp, (limb_t*)x_eval, ctx_eval.rho_2, NUM_CORES);

    MEASURE(mrz_exp_com(&ctx_eval, omega, (limb_t*)r_comp, (limb_t*)r_comp, (limb_t*)y_eval, len, NUM_CORES));

    mrz_mul_com(len, ctx_eval.N, omega, (limb_t*)r_comp, (limb_t*)r_comp, ctx_eval.rho_0, NUM_CORES);

    if (!check_result(r_comp, r_norm, len*4)) {
        print_string("mrz_exp computations are not matched!\n");
    }
}


