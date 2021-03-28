/* Copyright (C) 2019 SCARV project <info@scarv.org>
 *
 * Use of this source code is restricted per the MIT license, a copy of which 
 * can be found at https://opensource.org/licenses/MIT (or should be included 
 * as LICENSE.txt within the associated archive or repository).
 */

#ifndef __LIBSCARV_MRZ_H
#define __LIBSCARV_MRZ_H

#include <scarv/share/conf.h>
#include <scarv/share/util.h>

#include <scarv/mp/limb/limb.h>

#include <scarv/mp/mpn/mpn.h>
#include <scarv/mp/mpz/mpz.h>

typedef limb_t mrz_t[ LIBSCARV_CONF_MRZ_MAX_LIMBS ];

typedef struct{
   mrz_t     N; // modulus
   int     l_N; // modulus size, in limbs

   mrz_t rho_0; // \rho^0  \pmod{N}
   mrz_t rho_1; // \rho^1  \pmod{N}
   mrz_t rho_2; // \rho^2  \pmod{N}

  limb_t omega; // -N^{-1} \pmod{\rho}
} mrz_ctx_t;

extern void mrz_precomp( mrz_ctx_t* ctx, const limb_t* N, int l_N );

#include <scarv/mp/mrz/mrz_red.h>

#include <scarv/mp/mrz/mrz_add.h>
#include <scarv/mp/mrz/mrz_sub.h>
#include <scarv/mp/mrz/mrz_mul.h>

#include <scarv/mp/mrz/mrz_exp.h>

#endif
