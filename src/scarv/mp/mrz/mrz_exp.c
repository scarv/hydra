/* Copyright (C) 2019 SCARV project <info@scarv.org>
 *
 * Use of this source code is restricted per the MIT license, a copy of which 
 * can be found at https://opensource.org/licenses/MIT (or should be included 
 * as LICENSE.txt within the associated archive or repository).
 */

#include <scarv/mp/mrz/mrz_exp.h>

void mrz_exp( const mrz_ctx_t* ctx, mrz_t r, const mrz_t x, const limb_t* y, int l_y ) {
  mrz_t t;

  memcpy( t, ctx->rho_1, SIZEOF( mrz_t ) );

  for( int i = l_y - 1; i >= 0; i-- ) {
    for( int j = ( BITSOF( limb_t ) - 1 ); j >= 0; j-- ) {
      mrz_mul( ctx, t, t, t );

      if( ( y[ i ] >> j ) & 1 ) {
        mrz_mul( ctx, t, t, x );
      }
    }
  }

  memcpy( r,          t, SIZEOF( mrz_t ) );
}
