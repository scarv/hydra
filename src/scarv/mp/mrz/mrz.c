/* Copyright (C) 2019 SCARV project <info@scarv.org>
 *
 * Use of this source code is restricted per the MIT license, a copy of which 
 * can be found at https://opensource.org/licenses/MIT (or should be included 
 * as LICENSE.txt within the associated archive or repository).
 */

#include <scarv/mp/mrz/mrz.h>

void mrz_precomp( mrz_ctx_t* ctx, const limb_t* N, int l_N ) {
  memset( ctx, 0, SIZEOF( mrz_ctx_t ) );

  // initialise N, and l_N = |N|

  memcpy( ctx->N, N, ( ctx->l_N = l_N ) * SIZEOF( limb_t ) );

  // compute \rho^i \pmod{N}, for i \in { 0, 1, 2, 3 }

  ctx->rho_0[ 0 ] = 1;
  ctx->rho_1[ 0 ] = 1;

  for( int i = 0; i < ( ctx->l_N * BITSOF( limb_t ) ); i++ ) {
    mrz_add( ctx, ctx->rho_1, ctx->rho_1, ctx->rho_1 );
  }

  memcpy( ctx->rho_2, ctx->rho_1, SIZEOF( mrz_t ) );

  for( int i = 0; i < ( ctx->l_N * BITSOF( limb_t ) ); i++ ) {
    mrz_add( ctx, ctx->rho_2, ctx->rho_2, ctx->rho_2 );
  }

  // compute \omega = -N^{-1} \pmod{b}

  ctx->omega =           1;

  for( int i = 1; i < (            BITSOF( limb_t ) ); i++ ) {
    ctx->omega = ctx->omega * ctx->omega * ctx->N[ 0 ];
  }

  ctx->omega = -ctx->omega;

  return;
}
