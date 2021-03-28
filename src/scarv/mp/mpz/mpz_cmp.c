/* Copyright (C) 2019 SCARV project <info@scarv.org>
 *
 * Use of this source code is restricted per the MIT license, a copy of which 
 * can be found at https://opensource.org/licenses/MIT (or should be included 
 * as LICENSE.txt within the associated archive or repository).
 */

#include <scarv/mp/mpz/mpz_cmp.h>

int mpz_cmp( const mpz_t* x, const mpz_t* y ) {
  if     ( ( x->s <  0 ) && ( y->s >= 0 ) ) {
    return -1;
  }
  else if( ( x->s >= 0 ) && ( y->s <  0 ) ) {
    return +1;
  }
  else if( ( x->s >= 0 ) && ( y->s >= 0 ) ) {
    return +mpn_cmp( x->d, x->l, y->d, y->l );
  }
  else if( ( x->s <  0 ) && ( y->s <  0 ) ) {
    return -mpn_cmp( x->d, x->l, y->d, y->l );
  }

  return 0;
}
