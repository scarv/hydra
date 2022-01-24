/* Copyright (C) 2019 SCARV project <info@scarv.org>
 *
 * Use of this source code is restricted per the MIT license, a copy of which 
 * can be found at https://opensource.org/licenses/MIT (or should be included 
 * as LICENSE.txt within the associated archive or repository).
 */

#include <scarv/share/conf.h>

// ============================================================================	

.section .text

.func    mrz_precomp_rho_comp
.global  mrz_precomp_rho_comp

#define mcompose 0x7c0
#define n_cores  s3
#define one      s4
#define bytes_per_word t6

// void mrz_precomp_rho_comp( limb_t* rho_0, limb_t* rho_1, limb_t* rho_2, const limb_t* N, int l_N, int n_cores );

mrz_precomp_rho_comp:
  csrw mcompose, a5
  slli bytes_per_word, a5, 2
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
  mv   s1, ra
  mv   n_cores, a5
  li   one, 1

  li   t0, 1
  sw   t0, 0(a0)
  sw   t0, 0(a1)
  slli a4, a4, 2
  add  t0, a0, a4
  add  t1, a1, bytes_per_word
  add  a0, a0, bytes_per_word
.rho_0_loop:
  beq  a0, t0, .rho_0_loop_end
  sw   zero, 0(a0)
  sw   zero, 0(t1)
  add  a0, a0, bytes_per_word
  add  t1, t1, bytes_per_word
  j    .rho_0_loop
.rho_0_loop_end:

  slli s2, a4, 3
  mv   a5, a1
  add  a6, a4, a5
  jal  .rho_loop

  mv   t0, a2
  mv   t2, a1
  add  t1, a1, a4
.copy_rho:
  beq  t2, t1, .copy_rho_end
  lw   t3, 0(t2)
  sw   t3, 0(t0)
  add  t0, t0, bytes_per_word
  add  t2, t2, bytes_per_word
  j    .copy_rho
.copy_rho_end:

  slli s2, a4, 3
  mv   a5, a2
  add  a6, a4, a5
  jal  .rho_loop

  mv   ra, s1
  slli bytes_per_word, n_cores, 2
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

.rho_loop:
  beqz s2, .rho_loop_end

  mv   t1, a5
  li   t2, 0
.rho_add:
  beq  t1, a6, .rho_add_end
  lw   t3, 0(t1)
  add  t4, t3, t2
  sltu t2, t4, t3
  add  t4, t4, t3
  sltu t5, t4, t3
  or   t2, t2, t5
  sw   t4, 0(t1)
  add  t1, t1, bytes_per_word
  j    .rho_add
.rho_add_end:

  sw   t2, 0(t1)
  bnez t2, .rho_do_sub

  mv   t1, a6
  li   t2, 1
  add  t3, a4, a3
.rho_cmp:
  sub  t1, t1, bytes_per_word
  sub  t3, t3, bytes_per_word
  beq  t1, a5, .rho_cmp_end
  lw   t4, 0(t1)
  lw   t5, 0(t3)
  beq  t4, t5, .rho_cmp
  sltu t2, t5, t4
.rho_cmp_end:

  beqz t2, .rho_sub_end

.rho_do_sub:
  li   t2, 0
  mv   t1, a5
  mv   a7, a3
  add  a0, a6, bytes_per_word
.rho_sub:
  beq  t1, a0, .rho_sub_end
  lw   t0, 0(t1)
  lw   t3, 0(a7)
  sub  t4, t0, t3
  sltu t0, t0, t4
  sub  t5, t4, t2
  sltu t2, t4, t5
  or   t2, t2, t0
  sw   t5, 0(t1)
  add  t1, t1, bytes_per_word
  add  a7, a7, bytes_per_word
  j    .rho_sub
.rho_sub_end:

  sub  s2, s2, one
  j    .rho_loop
.rho_loop_end:
  ret

.endfunc


.func    mrz_precomp_omega_comp
.global  mrz_precomp_omega_comp

// void mrz_precomp_omega_comp( limb_t* omega, const limb_t* N, int n_cores );

mrz_precomp_omega_comp:
  csrw mcompose, a2
  li   t3, 1
  li   t1, 1
  li   t0, 32
  lw   t2, 0(a1)
  mul  t0, t0, a2
  sub  t0, t0, t3
.omega_loop:
  beqz t0, .omega_loop_end

  mul  t1, t1, t1
  mul  t1, t1, t2

  sub  t0, t0, t3
  j    .omega_loop
.omega_loop_end:

  neg  t1, t1
  sw   t1, 0(a0)

  csrw mcompose, zero
  ret

.endfunc
	
// ============================================================================	
