/* Copyright (C) 2019 SCARV project <info@scarv.org>
 *
 * Use of this source code is restricted per the MIT license, a copy of which 
 * can be found at https://opensource.org/licenses/MIT (or should be included 
 * as LICENSE.txt within the associated archive or repository).
 */

#include <scarv/mp/mpz/mpz_mul.h>

void mpz_mul( mpz_t* r, const mpz_t* x, const mpz_t* y ) {
  if( x->s == y->s ) {
    // r = +( abs(x) * abs(y) )
    MPZ_MUL( r, x, y, MPZ_SIGN_POS );
  }
  else {
    // r = -( abs(x) * abs(y) )
    MPZ_MUL( r, x, y, MPZ_SIGN_NEG );
  }
}
