/* Copyright (C) 2019 SCARV project <info@scarv.org>
 *
 * Use of this source code is restricted per the MIT license, a copy of which 
 * can be found at https://opensource.org/licenses/MIT (or should be included 
 * as LICENSE.txt within the associated archive or repository).
 */

#include <scarv/mp/mpz/mpz.h>

int mpz_size( const mpz_t* x ) {
  return x->l;
}

limb_t mpz_getlimbn( const mpz_t* x, int n ) {
  return ( ( n >= 0 ) && ( n < x->l ) ) ? x->d[ n ] : 0;
}
