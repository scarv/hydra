/* Copyright (C) 2019 SCARV project <info@scarv.org>
 *
 * Use of this source code is restricted per the MIT license, a copy of which 
 * can be found at https://opensource.org/licenses/MIT (or should be included 
 * as LICENSE.txt within the associated archive or repository).
 */

#include <scarv/mp/mrz/mrz_add.h>

void mrz_add( const mrz_ctx_t* ctx, mrz_t r, const mrz_t x, const mrz_t y ) {
  r[ ctx->l_N ] = mpn_add_n( r, x, y, ctx->l_N );

  if( r[ ctx->l_N ] || ( mpn_cmp_n( r, ctx->N, ctx->l_N ) >= 0 ) ) {
    mpn_sub_n( r, r, ctx->N, ctx->l_N + 1 );
  }
}

