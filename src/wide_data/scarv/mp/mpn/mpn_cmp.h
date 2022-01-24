/* Copyright (C) 2019 SCARV project <info@scarv.org>
 *
 * Use of this source code is restricted per the MIT license, a copy of which 
 * can be found at https://opensource.org/licenses/MIT (or should be included 
 * as LICENSE.txt within the associated archive or repository).
 */

#ifndef __LIBSCARV_MPN_CMP_H
#define __LIBSCARV_MPN_CMP_H

#include <scarv/share/conf.h>
#include <scarv/share/util.h>

#include <scarv/mp/mpn/mpn.h>

extern int mpn_cmp  ( const limb_t* x, int l_x, const limb_t* y, int l_y );

extern int mpn_cmp_1( const limb_t* x, int l_x, const limb_t  y          );
extern int mpn_cmp_n( const limb_t* x,          const limb_t* y, int l   );

#endif

