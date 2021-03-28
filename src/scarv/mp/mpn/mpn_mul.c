/* Copyright (C) 2019 SCARV project <info@scarv.org>
 *
 * Use of this source code is restricted per the MIT license, a copy of which 
 * can be found at https://opensource.org/licenses/MIT (or should be included 
 * as LICENSE.txt within the associated archive or repository).
 */

#include <scarv/mp/mpn/mpn_mul.h>

void mpn_mul_1( limb_t* r, const limb_t* x, int l_x,  const limb_t  y        ) {
  mpn_mul( r, x, l_x, &y, 1 );
}

void mpn_mul_n( limb_t* r, const limb_t* x,           const limb_t* y, int l ) {
  mpn_mul( r, x, l,    y, l );
}
