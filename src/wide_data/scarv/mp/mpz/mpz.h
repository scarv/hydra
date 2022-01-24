/* Copyright (C) 2019 SCARV project <info@scarv.org>
 *
 * Use of this source code is restricted per the MIT license, a copy of which 
 * can be found at https://opensource.org/licenses/MIT (or should be included 
 * as LICENSE.txt within the associated archive or repository).
 */

#ifndef __LIBSCARV_MPZ_H
#define __LIBSCARV_MPZ_H

#include <scarv/share/conf.h>
#include <scarv/share/util.h>

#include <scarv/mp/limb/limb.h>

#include <scarv/mp/mpn/mpn.h>

#define MPZ_SIGN_POS ( +1 )
#define MPZ_SIGN_NEG ( -1 )

#define MPZ_SQR(r,x,  s_r) {                             \
  int l_r  = (x)->l + (x)->l;                            \
                                                         \
                      mpn_sqr( (r)->d, (x)->d, (x)->l ); \
                                                         \
  (r)->l            = mpn_lop( (r)->d, l_r );            \
  (r)->s            = s_r;                               \
}
#define MPZ_ADD(r,x,y,s_r) {                             \
  int l_r = MAX( (x)->l, (y)->l ) + 1;                   \
                                                         \
  (r)->d[ l_r - 1 ] = mpn_add( (r)->d, (x)->d, (x)->l,   \
                                       (y)->d, (y)->l ); \
                                                         \
  (r)->l            = mpn_lop( (r)->d, l_r );            \
  (r)->s            = s_r;                               \
}
#define MPZ_SUB(r,x,y,s_r) {                             \
  int l_r = MAX( (x)->l, (y)->l ) + 1;                   \
                                                         \
  (r)->d[ l_r - 1 ] = mpn_sub( (r)->d, (x)->d, (x)->l,   \
                                       (y)->d, (y)->l ); \
                                                         \
  (r)->l            = mpn_lop( (r)->d, l_r );            \
  (r)->s            = s_r;                               \
}
#define MPZ_MUL(r,x,y,s_r) {                             \
  int l_r = (x)->l + (y)->l;                             \
                                                         \
                      mpn_mul( (r)->d, (x)->d, (x)->l,   \
                                       (y)->d, (y)->l ); \
                                                         \
  (r)->l            = mpn_lop( (r)->d, l_r );            \
  (r)->s            = s_r;                               \
}

typedef struct __mpz_t {
  limb_t d[ LIBSCARV_CONF_MPZ_MAX_LIMBS ];

  int    l;
  int    s;
} mpz_t;

// get      limbs in x
extern int    mpz_size( const mpz_t* x );
// get n-th limb  in x
extern limb_t mpz_getlimbn( const mpz_t* x, int n );

#include <scarv/mp/mpz/mpz_cmp.h>

#include <scarv/mp/mpz/mpz_add.h>
#include <scarv/mp/mpz/mpz_sub.h>
#include <scarv/mp/mpz/mpz_mul.h>

#endif
