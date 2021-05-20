/* Copyright (C) 2019 SCARV project <info@scarv.org>
 *
 * Use of this source code is restricted per the MIT license, a copy of which 
 * can be found at https://opensource.org/licenses/MIT (or should be included 
 * as LICENSE.txt within the associated archive or repository).
 */

#include <scarv/mp/mrz/mrz_mul.h>
#include <multi_arithmetic.h>
#include <sys.h>

#if LIBSCARV_CONF_MRZ_MUL_REDC
void mrz_mul( const mrz_ctx_t* ctx, mrz_t r, const mrz_t x, const mrz_t y ) {
  limb_t    R[ 2 * ctx->l_N + 2 ];

  memset( R,  0, ( 2 * ctx->l_N + 2 ) * SIZEOF( limb_t ) );

  multi_mult(x, y, R, ctx->l_N);
  mrz_red_asm( ctx->l_N, ctx->N, ctx->omega, r, R);
}
#endif

#if LIBSCARV_CONF_MRZ_MUL_CIOS
void mrz_mul( const mrz_ctx_t* ctx, mrz_t r, const mrz_t x, const mrz_t y ) {
  limb_t u, R[ 2 * ctx->l_N + 2 ], *Rp = R, c;

  memset( Rp, 0, ( 2 * ctx->l_N + 2 ) * SIZEOF( limb_t ) );

  for( int i = 0; i < ctx->l_N; i++ ) {
    // r = r + ( y_i * x )
    c = 0;

    for( int j = 0; j < ctx->l_N; j++ ) {
      LIMB_MUL2( c, Rp[ j ], y[ i ],      x[ j ], Rp[ j ], c );
    }

    LIMB_ADD0( Rp[ ctx->l_N + 1 ], Rp[ ctx->l_N ], Rp[ ctx->l_N ], c );

    // r = r + ( u   * N )
    c = 0; u = Rp[ 0 ] * ctx->omega;

    for( int j = 0; j < ctx->l_N; j++ ) {
      LIMB_MUL2( c, Rp[ j ], u,      ctx->N[ j ], Rp[ j ], c );
    }

    LIMB_ADD0( Rp[ ctx->l_N + 1 ], Rp[ ctx->l_N ], Rp[ ctx->l_N ], c );

    // r = r / b
    Rp++;
  }

  memcpy( r, Rp, ( 1 * ctx->l_N + 1 ) * SIZEOF( limb_t ) );

  if( r[ ctx->l_N ] || ( mpn_cmp_n( r, ctx->N, ctx->l_N ) >= 0 ) ) {
    mpn_sub_n( r, r, ctx->N, ctx->l_N + 1 );
  }
}
#endif
