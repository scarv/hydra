/* Copyright (C) 2019 SCARV project <info@scarv.org>
 *
 * Use of this source code is restricted per the MIT license, a copy of which 
 * can be found at https://opensource.org/licenses/MIT (or should be included 
 * as LICENSE.txt within the associated archive or repository).
 */

#include <scarv/mp/mrz/mrz_red.h>

#if ( !LIBSCARV_CONF_MRZ_RED_EXTERN ) 
void mrz_red( const mrz_ctx_t* ctx, mrz_t r, const mrz_t x ) {
  limb_t u, R[ 2 * ctx->l_N + 2 ], *Rp = R, d_0 = 0, d_1 = 0, d_2 = 0, c = 0;

  memcpy( Rp, x, ( 2 * ctx->l_N     ) * SIZEOF( limb_t ) );

  Rp[ 2 * ctx->l_N + 0 ] = 0;
  Rp[ 2 * ctx->l_N + 1 ] = 0;

  for( int i = 0; i < ctx->l_N; i++ ) {
    // u = r_0 * \omega \pmod{b}
    u = Rp[ 0 ] * ctx->omega; 

    // r = r + ( u * N )
    c = 0; 

    for( int j =        0; j < ( 1 * ctx->l_N     ); j++ ) {
      d_0 = ctx->N[ j ];
      d_1 =     Rp[ j ];

      LIMB_MUL2( c, d_2, u, d_0, d_1, c );

      Rp[ j ] = d_2;
    }

    for( int j = ctx->l_N; j < ( 2 * ctx->l_N - i ); j++ ) {
      d_0 =     Rp[ j ];

      LIMB_ADD0( c, d_2,    d_0,      c );

      Rp[ j ] = d_2;
    }

    d_2 = Rp[ 2 * ctx->l_N - i ];

    LIMB_ADD0( c, d_2, c, d_2 );

    Rp[ 2 * ctx->l_N - i     ]  = d_2;
    Rp[ 2 * ctx->l_N - i + 1 ] +=   c;

    // r = r / b
    Rp++;
  }

  memcpy( r, Rp, ( 1 * ctx->l_N + 1 ) * SIZEOF( limb_t ) );

  if( r[ ctx->l_N ] || ( mpn_cmp_n( r, ctx->N, ctx->l_N ) >= 0 ) ) {
    mpn_sub_n( r, r, ctx->N, ctx->l_N + 1 );
  }
}
#endif
