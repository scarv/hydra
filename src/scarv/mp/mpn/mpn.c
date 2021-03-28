/* Copyright (C) 2019 SCARV project <info@scarv.org>
 *
 * Use of this source code is restricted per the MIT license, a copy of which 
 * can be found at https://opensource.org/licenses/MIT (or should be included 
 * as LICENSE.txt within the associated archive or repository).
 */

#include <scarv/mp/mpn/mpn.h>

int mpn_lop( const limb_t* x, int l_x ) {
  while( ( l_x > 1 ) && ( x[ l_x - 1 ] == 0 ) ) {
    l_x--;
  }

  return l_x;
}
