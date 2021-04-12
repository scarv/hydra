/* Copyright (C) 2019 SCARV project <info@scarv.org>
 *
 * Use of this source code is restricted per the MIT license, a copy of which 
 * can be found at https://opensource.org/licenses/MIT (or should be included 
 * as LICENSE.txt within the associated archive or repository).
 */

#include <scarv/share/conf.h>

// ============================================================================	

.section .text

.func    mrz_precomp_omega
.global  mrz_precomp_omega

// void mrz_precomp_omega( limb_t* omega, const limb_t* N );

mrz_precomp_omega:
  li   t1, 1
  lw   t2, 0(a1)
  li   t0, 31
.omega_loop:
  beqz t0, .omega_loop_end

  mul  t1, t1, t1
  mul  t1, t1, t2

  addi t0, t0, -1
  j    .omega_loop
.omega_loop_end:

  neg  t1, t1
  sw   t1, 0(a0)

  ret

.endfunc


.func    mrz_precomp_rho
.global  mrz_precomp_rho

// void mrz_precomp_rho( limb_t* rho_0, limb_t* rho_1, limb_t* rho_2, const limb_t* N, int l_N );

mrz_precomp_rho:
  addi sp, sp, -24
  sw   s0, 0(sp)
  sw   s1, 4(sp)
  sw   s2, 8(sp)
  sw   s3, 12(sp)
  sw   s4, 16(sp)
  sw   s5, 20(sp)

  mv   s0, ra
  mv   s1, a1
  mv   s2, a2
  mv   s3, a3
  mv   s4, a4

  li   t0, 1
  sw   t0, 0(a0)
  sw   t0, 0(a1)
  slli s4, s4, 2
  add  t0, a0, s4
  add  t1, a1, 4
  addi a0, a0, 4
.rho_0_loop:
  beq  a0, t0, .rho_0_loop_end
  sw   zero, 0(a0)
  sw   zero, 0(t1)
  addi a0, a0, 4
  addi t1, t1, 4
  j    .rho_0_loop
.rho_0_loop_end:

  slli s5, s4, 3
.rho_1_loop:
  beqz s5, .rho_1_loop_end

  mv   a0, s3
  mv   a1, s1
  mv   a2, s1
  mv   a3, s1
  srli a4, s4, 2
  jal  mrz_add_asm

  addi s5, s5, -1
  j    .rho_1_loop
.rho_1_loop_end:

  mv   t1, s2
  add  t2, s2, s4
.copy_rho:
  beq  t2, t1, .copy_rho_end
  lw   t3, 0(s1)
  sw   t3, 0(t1)
  addi t1, t1, 4
  addi s1, s1, 4
  j    .copy_rho
.copy_rho_end:

  slli s5, s4, 3
.rho_2_loop:
  beqz s5, .rho_2_loop_end

  mv   a0, s3
  mv   a1, s2
  mv   a2, s2
  mv   a3, s2
  srli a4, s4, 2
  jal  mrz_add_asm

  addi s5, s5, -1
  j    .rho_2_loop
.rho_2_loop_end:

  mv   ra, s0

  lw   s0, 0(sp)
  lw   s1, 4(sp)
  lw   s2, 8(sp)
  lw   s3, 12(sp)
  lw   s4, 16(sp)
  lw   s5, 20(sp)
  addi sp, sp, 24
  ret

.endfunc
	
// ============================================================================	
