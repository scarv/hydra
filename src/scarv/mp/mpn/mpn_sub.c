/* Copyright (C) 2019 SCARV project <info@scarv.org>
 *
 * Use of this source code is restricted per the MIT license, a copy of which 
 * can be found at https://opensource.org/licenses/MIT (or should be included 
 * as LICENSE.txt within the associated archive or repository).
 */

#include <scarv/mp/mpn/mpn_sub.h>

limb_t mpn_sub_1( limb_t* r, const limb_t* x, int l_x,  const limb_t  y        ) {
  return mpn_sub( r, x, l_x, &y, 1 );
}

limb_t mpn_sub_n( limb_t* r, const limb_t* x,           const limb_t* y, int l ) {
  return mpn_sub( r, x, l,    y, l );
}
