/* Copyright (C) 2019 SCARV project <info@scarv.org>
 *
 * Use of this source code is restricted per the MIT license, a copy of which 
 * can be found at https://opensource.org/licenses/MIT (or should be included 
 * as LICENSE.txt within the associated archive or repository).
 */

#include <scarv/share/conf.h>

// ============================================================================	

.section .text

.func    mrz_mul_asm
.global  mrz_mul_asm

// register names
#define  l_N      s0
#define  N        s1
#define  omega    a2
#define  r        s2
#define  saved_ra s3
#define  x        s4
#define  y        s5
#define  Rp       sp

#define  u     t0
#define  c     t1
#define  d_0   t2
#define  d_1   t3
#define  d_2   t4

#define  i_index  a0
#define  j_index  a4

// void mrz_mul_asm( int l_N, mrz_t N, limb_t omega, mrz_t r, const mrz_t x, const mrz_t y );

mrz_mul_asm:
.save_regs:
  addi sp, sp, -24
  sw   s0,   0(sp)
  sw   s1,   4(sp)
  sw   s2,   8(sp)
  sw   s3,  12(sp)
  sw   s4,  16(sp)
  sw   s5,  20(sp)

  mv   l_N,   a0
  mv   N,     a1
  mv   r,     a3
  mv   x,     a4
  mv   y,     a5

  slli t2, l_N, 3
  addi t6, t2, 8
  sub  sp, sp, t6

  mv   a0, Rp
  add  a1, t2, Rp
  addi a1, a1, 8
  mv   saved_ra, ra

.zero_Rp:
  beq  a0, a1, .zero_Rp_end
  sw   zero, 0(a0)
  addi a0, a0, 4
  j .zero_Rp
.zero_Rp_end:

  slli t2, l_N, 3
  add  t1, Rp, t2
  sw   zero, 0(t1)
  sw   zero, 4(t1)

  mv   i_index, zero
  slli a1, l_N, 2
.loop:
  beq  i_index, a1, .loop_end

  mv   c, zero

  mv   j_index, zero
  slli a5, l_N, 2
.inner_mul_1:
  beq  j_index, a5, .mul_1_end

  add  a6, x, j_index
  lw   d_0, 0(a6)       // d_0 = x[j]
  add  a6, Rp, j_index
  lw   d_1, 0(a6)       // d_1 = Rp[j]
  add  a6, y, i_index
  lw   u, 0(a6)         //  u  = y[i]

  mulhu t5, d_0, u      // t5  = h(x[j] * y[i])
  mul d_2, d_0, u       // d_2 = x[j] * y[i]
  add d_2, d_2, c       // c, d_2 = d_2 + c
  sltu c, d_2, c        
  add c, c, t5          // c += h(x[j] * y[i])
  add d_2, d_2, d_1     // t5, d_2 = d_2 + Rp[j]
  sltu t5, d_2, d_1     
  add c, c, t5          // c += t5

  add  a6, Rp, j_index
  sw   d_2, 0(a6)

  addi j_index, j_index, 4
  j    .inner_mul_1
.mul_1_end:

  add  a6, a1, Rp
  lw   d_0, 0(a6)
  add  d_0, d_0, c
  sltu c, d_0, c
  sw   d_0, 0(a6)
  sw   c,   4(a6)

  lw   u, 0(Rp)
  mv   c, zero
  mul  u, u, omega

  mv   j_index, zero
  slli a5, l_N, 2
.inner_mul_2:
  beq  j_index, a5, .mul_2_end

  add  a6, N, j_index
  lw   d_0, 0(a6)
  add  a6, Rp, j_index
  lw   d_1, 0(a6)

  mulhu t5, d_0, u
  mul d_2, d_0, u
  add d_2, d_2, c
  sltu c, d_2, c
  add c, c, t5
  add d_2, d_2, d_1
  sltu t5, d_2, d_1
  add c, c, t5

  sw   d_2, 0(a6)

  addi j_index, j_index, 4
  j    .inner_mul_2
.mul_2_end:

  add  a6, a1, Rp
  lw   d_0, 0(a6)
  add  d_0, d_0, c
  sltu c, d_0, c
  sw   d_0, 0(a6)
  sw   c,   4(a6)

  addi i_index, i_index, 4
  addi Rp, Rp, 4

  j    .loop
.loop_end:

  slli a3, l_N, 2
  sub  t6, t6, a3
  addi a2, a3, 4
  add  a1, a2, r
  mv   a0, r
  mv   a4, Rp

.write_back:
  beq  a0, a1, .write_back_end
  lw   t0, 0(a4)
  sw   t0, 0(a0)
  addi a4, a4, 4
  addi a0, a0, 4
  j .write_back
.write_back_end:

  add  sp, sp, t6

.check_sub:
  slli a0, l_N, 2
  add  a0, a0, r
  lw   a1, 0(a0)
  bnez a1, .do_sub
  mv   a0, r
  mv   a1, N
  mv   a2, l_N
  jal  mpn_cmp_n
  bltz a0, .end

.do_sub:
  mv  a0, r
  mv  a1, r
  mv  a2, N
  add a3, l_N, 1
  jal mpn_sub_n

.end:
  mv  ra, saved_ra

.load_regs:
  lw   s0,   0(sp)
  lw   s1,   4(sp)
  lw   s2,   8(sp)
  lw   s3,  12(sp)
  lw   s4,  16(sp)
  lw   s5,  20(sp)
  addi sp, sp, 24
  ret

.endfunc
	
// ============================================================================	
