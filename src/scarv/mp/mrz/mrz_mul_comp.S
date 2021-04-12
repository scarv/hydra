/* Copyright (C) 2019 SCARV project <info@scarv.org>
 *
 * Use of this source code is restricted per the MIT license, a copy of which 
 * can be found at https://opensource.org/licenses/MIT (or should be included 
 * as LICENSE.txt within the associated archive or repository).
 */

#include <scarv/share/conf.h>

// ============================================================================	

.section .text

.func    mrz_mul_comp
.global  mrz_mul_comp

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

#define  mcompose 0x7c0
#define  bytes_per_word a7

#define  i_index  a0
#define  j_index  a4

// void mrz_mul_comp( int l_N, const mrz_t N, const limb_t *omega, mrz_t r, const mrz_t x, const mrz_t y, int n_cores );

mrz_mul_comp:
.save_regs:
  csrw mcompose, a6
  slli bytes_per_word, a6, 2
  sub  sp, sp, bytes_per_word
  sw   s0, 0(sp)
  sub  sp, sp, bytes_per_word
  sw   s1, 0(sp)
  sub  sp, sp, bytes_per_word
  sw   s2, 0(sp)
  sub  sp, sp, bytes_per_word
  sw   s3, 0(sp)
  sub  sp, sp, bytes_per_word
  sw   s4, 0(sp)
  sub  sp, sp, bytes_per_word
  sw   s5, 0(sp)

  mv   l_N,   a0
  mv   N,     a1
  lw   omega, 0(a2)
  mv   r,     a3
  mv   x,     a4
  mv   y,     a5
  mv   saved_ra, ra

  slli t2, l_N, 3
  slli t6, bytes_per_word, 1
  add  t6, t6, t2
  sub  sp, sp, t6

  mv   a0, Rp
  add  a1, t6, Rp
.zero_Rp:
  beq  a0, a1, .zero_Rp_end
  sw   zero, 0(a0)
  add  a0, a0, bytes_per_word
  j    .zero_Rp
.zero_Rp_end:

  slli t2, l_N, 3
  add  t1, Rp, t2
  sw   zero, 0(t1)
  add  t1, t1, bytes_per_word
  sw   zero, 0(t1)

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
  lw   d_0, 0(a6)
  add  a6, Rp, j_index
  lw   d_1, 0(a6)
  add  a6, y, i_index
  lw   u, 0(a6)

  mulhu t5, d_0, u
  mul   d_2, d_0, u
  add   d_2, d_2, c
  sltu  c, d_2, c
  add   c, c, t5
  add   d_2, d_2, d_1
  sltu  t5, d_2, d_1     
  add   c, c, t5

  add  a6, Rp, j_index
  sw   d_2, 0(a6)

  add  j_index, j_index, bytes_per_word
  j    .inner_mul_1
.mul_1_end:

  add  a6, a1, Rp
  lw   d_0, 0(a6)
  add  d_0, d_0, c
  sltu c, d_0, c
  sw   d_0, 0(a6)

  add  a6, a6, bytes_per_word
  sw   c,   0(a6)

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
  mul   d_2, d_0, u
  add   d_2, d_2, c
  sltu  c, d_2, c
  add   c, c, t5
  add   d_2, d_2, d_1
  sltu  t5, d_2, d_1
  add   c, c, t5

  sw   d_2, 0(a6)

  add  j_index, j_index, bytes_per_word
  j    .inner_mul_2
.mul_2_end:

  add  a6, a1, Rp
  lw   d_0, 0(a6)
  add  d_0, d_0, c
  sltu c, d_0, c
  sw   d_0, 0(a6)
  
  add  a6, a6, bytes_per_word
  sw   c,   0(a6)

  add  i_index, i_index, bytes_per_word
  add  Rp, Rp, bytes_per_word

  j    .loop
.loop_end:

  slli a3, l_N, 2
  sub  t6, t6, a3
  add  a2, a3, bytes_per_word
  add  a1, a2, r
  mv   a0, r
  mv   a4, Rp

.write_back:
  beq  a0, a1, .write_back_end
  lw   t0, 0(a4)
  sw   t0, 0(a0)
  add  a4, a4, bytes_per_word
  add  a0, a0, bytes_per_word
  j    .write_back
.write_back_end:

  add  sp, sp, t6

.check_sub:
  slli a0, l_N, 2
  add  a0, a0, r
  lw   a1, 0(a0)
  bnez a1, .do_sub

  slli t0, l_N, 2
  add  t3, N, t0
  mv   t1, a6
  li   t2, 1
.cmp:
  sub  a0, a0, bytes_per_word
  sub  t3, t3, bytes_per_word
  beq  t3, N, .cmp_end
  lw   t4, 0(a0)
  lw   t5, 0(t3)
  beq  t4, t5, .cmp
  sltu t2, t5, t4
.cmp_end:
  beqz t2, .sub_end

.do_sub:
  li   t2, 0
  mv   t1, r
  mv   t6, N
  slli t0, l_N, 2
  add  a0, t0, bytes_per_word
  add  a0, a0, r
.sub:
  beq  t1, a0, .sub_end
  lw   t0, 0(t1)
  lw   t3, 0(t6)
  sub  t4, t0, t3
  sltu t0, t0, t4
  sub  t5, t4, t2
  sltu t2, t4, t5
  or   t2, t2, t0
  sw   t5, 0(t1)
  add  t1, t1, bytes_per_word
  add  t6, t6, bytes_per_word
  j    .sub
.sub_end:

.end:
  mv   ra, saved_ra

.load_regs:
  lw   s5, 0(sp)
  add  sp, sp, bytes_per_word
  lw   s4, 0(sp)
  add  sp, sp, bytes_per_word
  lw   s3, 0(sp)
  add  sp, sp, bytes_per_word
  lw   s2, 0(sp)
  add  sp, sp, bytes_per_word
  lw   s1, 0(sp)
  add  sp, sp, bytes_per_word
  lw   s0, 0(sp)
  add  sp, sp, bytes_per_word
  csrw mcompose, zero
  ret

.endfunc
	
// ============================================================================	
