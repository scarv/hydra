/* Copyright (C) 2019 SCARV project <info@scarv.org>
 *
 * Use of this source code is restricted per the MIT license, a copy of which 
 * can be found at https://opensource.org/licenses/MIT (or should be included 
 * as LICENSE.txt within the associated archive or repository).
 */

#ifndef __LIBSCARV_MPN_H
#define __LIBSCARV_MPN_H

#include <scarv/share/conf.h>
#include <scarv/share/util.h>

#include <scarv/mp/limb/limb.h>

extern int mpn_lop( const limb_t* x, int l_x );

#include <scarv/mp/mpn/mpn_cmp.h>

#include <scarv/mp/mpn/mpn_add.h>
#include <scarv/mp/mpn/mpn_sub.h>
#include <scarv/mp/mpn/mpn_mul.h>

#endif
