/* Copyright (C) 2019 SCARV project <info@scarv.org>
 *
 * Use of this source code is restricted per the MIT license, a copy of which 
 * can be found at https://opensource.org/licenses/MIT (or should be included 
 * as LICENSE.txt within the associated archive or repository).
 */

#ifndef __LIBSCARV_MPN_ADD_H
#define __LIBSCARV_MPN_ADD_H

#include <scarv/share/conf.h>
#include <scarv/share/util.h>

#include <scarv/mp/mpn/mpn.h>

extern limb_t mpn_add  ( limb_t* r, const limb_t* x, int l_x, const limb_t* y, int l_y );

extern limb_t mpn_add_1( limb_t* r, const limb_t* x, int l_x, const limb_t  y          );
extern limb_t mpn_add_n( limb_t* r, const limb_t* x,          const limb_t* y, int l   );

#endif
