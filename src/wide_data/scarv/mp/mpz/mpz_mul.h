/* Copyright (C) 2019 SCARV project <info@scarv.org>
 *
 * Use of this source code is restricted per the MIT license, a copy of which 
 * can be found at https://opensource.org/licenses/MIT (or should be included 
 * as LICENSE.txt within the associated archive or repository).
 */

#ifndef __LIBSCARV_MPZ_MUL_H
#define __LIBSCARV_MPZ_MUL_H

#include <scarv/share/conf.h>
#include <scarv/share/util.h>

#include <scarv/mp/mpz/mpz.h>

extern void mpz_mul( mpz_t* r, const mpz_t* x, const mpz_t* y );

#endif
