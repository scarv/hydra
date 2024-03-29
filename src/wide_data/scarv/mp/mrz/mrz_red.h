/* Copyright (C) 2019 SCARV project <info@scarv.org>
 *
 * Use of this source code is restricted per the MIT license, a copy of which 
 * can be found at https://opensource.org/licenses/MIT (or should be included 
 * as LICENSE.txt within the associated archive or repository).
 */

#ifndef __LIBSCARV_MRZ_RED_H
#define __LIBSCARV_MRZ_RED_H

#include <scarv/share/conf.h>
#include <scarv/share/util.h>

#include <scarv/mp/mrz/mrz.h>

// r = x * \rho^{-1} \pmod{N}
extern void mrz_red( const mrz_ctx_t* ctx, mrz_t r, const mrz_t x );

extern void mrz_red_asm( int l_N, const mrz_t N, limb_t omega, mrz_t r, const mrz_t x );

extern void mrz_red_asm_comp( int l_N, const mrz_t N, const limb_t *omega, mrz_t r, const mrz_t x, int n_cores );

#endif
