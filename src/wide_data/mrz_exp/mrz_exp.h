#ifndef __MRZ_EXP_H
#define __MRZ_EXP_H

#include "hal/sys.h"
#include "scarv/scarv.h"
#include "share.h"

extern const unsigned int x_exp_y_mod_N[NUM_WORDS];
extern const unsigned int omega_N[4];
extern const unsigned int rho_0[NUM_WORDS];
extern const unsigned int rho_1[NUM_WORDS];
extern const unsigned int rho_2[NUM_WORDS];

void mrz_mul_com( int l_N, const mrz_t N, const limb_t *omega, mrz_t r, const mrz_t x, const mrz_t y, int n_cores );
void mrz_exp_com( const mrz_ctx_t* ctx, const limb_t* omega, mrz_t r, const mrz_t x, const limb_t* y, int l_y, int n_cores );

void test_mrz_exp();
void eval_mrz_exp(int len);
#endif
