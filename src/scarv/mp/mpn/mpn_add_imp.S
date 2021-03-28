// Copyright (C) 2019 SCARV project <info@scarv.org>
//
// Use of this source code is restricted per the MIT license, a copy of which 
// can be found at https://opensource.org/licenses/MIT (or should be included 
// as LICENSE.txt within the associated archive or repository).

#include "scarv/mp/mpn/mpn_add_imp.h"

// ============================================================================	

.section .text

.func    mpn_add
.global  mpn_add

// limb_t mpn_add( limb_t* r, const limb_t* x, int l_x, const limb_t* y, int l_y );
//
// a0 = limb_t *   r
// a1 = limb_t *   x
// a2 = int      l_x
// a3 = limb_t *   y
// a4 = int      l_y
//
// t0 =          l_r
// t1 =            i
//
// t2 =            r[ i ]  = s
// t3 =                      c	
// t4 =            x[ i ] ~= d_0
// t5 =            y[ i ] ~= d_1
// t6 =            t      ~= addr

mpn_add: slli       t0, a2, 2              // l_r = l_x scaled into number of bytes
         bltu       a4, a2, .l0            // if l_y <  l_x, goto .l0
         slli       t0, a4, 2              // l_r = l_y scaled into number of bytes

.l0:     slli       a2, a2, 2              // l_x = l_x scaled into number of bytes
         slli       a4, a4, 2              // l_y = l_y scaled into number of bytes

         mv         t3, zero               // c = 0
	
         li         t1, 0                  // i = 0
         bgeu       t1, t0, .l5            // if i   >= l_r, goto .l5

.l1:     mv         t4, zero               // d_0 = 0
         bgeu       t1, a2, .l2            // if i   >= l_x, goto .l2
         add        t6, a1, t1             // t = x + i
	     lw         t4, 0(t6)              // d_0 = *t
.l2:     mv         t5, zero               // d_1 = 0
         bgeu       t1, a4, .l3            // if i   >= l_y, goto .l3
         add        t6, a3, t1             // t = y + i
	     lw         t5, 0(t6)              // d_1 = *t
.l3:     add        t6, t4, t5             // s   =   d_0 + d_1
	     sltu       t4, t6, t4             // c_0 = ( d_0 + d_1 ) < d_0
         add        t2, t6, t3             // s   =   s   + c
	     sltu       t5, t2, t6             // c_1 = ( s   + c   ) < s
         or         t3, t4, t5             // c   =   c_0 | c_1
         add        t6, a0, t1             // t = r + i
         sw         t2, 0(t6)              // *t = s

         addi       t1, t1, 4              // i = i + 1
         bltu       t1, t0, .l1            // if i   <  l_r, goto .l1

.l5:     mv         a0, t3                 // return c
         ret

.endfunc
	
// ============================================================================	
