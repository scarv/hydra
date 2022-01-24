// Copyright (C) 2019 SCARV project <info@scarv.org>
//
// Use of this source code is restricted per the MIT license, a copy of which 
// can be found at https://opensource.org/licenses/MIT (or should be included 
// as LICENSE.txt within the associated archive or repository).

#include "scarv/mp/mpn/mpn_mul_imp.h"

// ============================================================================	

.section .text

.func    mpn_mul
.global  mpn_mul

// void mpn_mul( limb_t* r, const limb_t* x, int l_x, const limb_t* y, int l_y );
//	
// a0 = limb_t *   r
// a1 = limb_t *   x
// a2 = int      l_x
// a3 = limb_t *   y
// a4 = int      l_y

mpn_mul:
    # Auxilliary storage on the stack.
    addi        sp, sp, -4          # sp = end of aux array R

    # How long will the result be?
    add     t0, a2, a4              # t0 = l_x + l_y
    beqz    t0, .mpn_mul_finish     # if len=0, finish
    
    # Clear the auxiliary result array
    slli    t1, t0, 2               # t1 = size in bytes of R
    sub     t2, sp, t1              # t2 = start of R
    .clear_r:
        sw      zero, 0(t2)         # r[t2] = 0
        addi    t2, t2, 4           # r ++
        blt     t2, sp, .clear_r
    sub     t2, sp, t1              # t2 = start of aux array R

    # Start computation loop
    beqz    a4, .mpn_mul_finish
    mv      t0, zero                # t0 = outer loop counter

    slli    t5, a4, 2               # Word aligned l_y
    slli    t6, a2, 2               # Word aligned l_x

    .mpn_mul_outer:
        
        beqz t6, .mpn_mul_outer_finish
        mv          t1, zero                # t1 = inner loop counter
        mv          a7, zero                # a7 = 0
            
        # Load inputs to MUL function
        add     t3, t0, a3              #          
        lw      a2, 0(t3)               # a2 = y[j]
        
        .mpn_mul_inner:

            # Load inputs to MUL function
            add     t3, t1, a1              #
            lw      a4, 0(t3)               # a4 = x[i]

            # a6, a5 = a4*a2 = x[i] * y[i]
            mulhu   a6, a4, a2
            mul     a5, a4, a2
            
            # a6, a5 = a4*a2 = (x[i] * y[i]) + C
            add     a5, a5, a7
            sltu    a7, a5, a7
            add     a6, a6, a7

            add     t3, t0, t1              # t3 = i+j = t0+t1
            add     t3, t3, t2              # t3 = addr of R[i+j]
            lw      a7, 0(t3)               # a7 = R[j+i]
            
            # a6, a5 = a4*a2 = (x[i] * y[i]) + C + R[j+i]
            add     a5, a5, a7
            sltu    a7, a5, a7
            add     a6, a6, a7

            mv      a7, a6

            # Store results back to carry and aux Result array
            sw      a5, 0(t3)               # R[j+i] = low word 

            addi    t1, t1, 4
            blt     t1, t6, .mpn_mul_inner  # if(i(t1) < l_x) goto inner loop

        .mpn_mul_outer_finish:

        # R[j+l_x] = c
        add     t3, t0, t6
        add     t3, t3, t2                  # t3 = addr of R[j+l_x]
        sw      a7, 0(t3)                   # R[j+l_x] = C

        addi    t0, t0, 4
        blt     t0, t5, .mpn_mul_outer      # if(j(t0) < l_y) goto outer loop

    .mpn_mul_finish:

    # Copy aux R array into result array
    mv  t0, t2          # src
    mv  t1, a0          # dst
    add t3, t5, t6
    add t4, t0, t3

    .mpn_cpy_back:

        lw       a7, 0(t0)
        sw       a7, 0(t1)
        
        addi t0, t0, 4
        addi t1, t1, 4

        blt  t0, t4, .mpn_cpy_back
    
    addi        sp, sp, 4
    ret
	
.endfunc 
	
// ============================================================================	
