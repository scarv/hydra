/* Copyright (C) 2019 SCARV project <info@scarv.org>
 *
 * Use of this source code is restricted per the MIT license, a copy of which 
 * can be found at https://opensource.org/licenses/MIT (or should be included 
 * as LICENSE.txt within the associated archive or repository).
 */

#ifndef __LIBSCARV_MRZ_ADD_H
#define __LIBSCARV_MRZ_ADD_H

#include <scarv/share/conf.h>
#include <scarv/share/util.h>

#include <scarv/mp/mrz/mrz.h>

// r = x + y \pmod{N}
extern void mrz_add( const mrz_ctx_t* ctx, mrz_t r, const mrz_t x, const mrz_t y );

extern void mrz_add_asm( const limb_t *N, mrz_t r, const mrz_t x, const mrz_t y, int l_N );

#endif
