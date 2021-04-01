/* Copyright (C) 2019 SCARV project <info@scarv.org>
 *
 * Use of this source code is restricted per the MIT license, a copy of which 
 * can be found at https://opensource.org/licenses/MIT (or should be included 
 * as LICENSE.txt within the associated archive or repository).
 */

#include <scarv/share/conf.h>

// ============================================================================	

.section .text

.func    mrz_precomp_asm
.global  mrz_precomp_asm

#define size_of_mrz (LIBSCARV_CONF_MRZ_MAX_LIMBS*4)
#define size_of_ctx (size_of_mrz*4+8)
#define N_offset 0
#define l_N_offset size_of_mrz
#define rho_0_offset (size_of_mrz+4)
#define rho_1_offset (size_of_mrz*2+4)
#define rho_2_offset (size_of_mrz*3+4)
#define omega_offset (size_of_mrz*4+4)

#define ctx s0
#define N   a1
#define l_N a2

// void mrz_precomp_asm( mrz_ctx_t* ctx, const limb_t* N, int l_N );

mrz_precomp_asm:
  addi sp, sp, -12
  sw   s0, 0(sp)
  sw   s1, 4(sp)
  sw   s2, 8(sp)
  mv   s0, a0
  mv   s1, ra

  slli t0, l_N, 2
  add  t0, t0, ctx
  mv   t1, ctx
.copy_N:
  beq  t1, t0, .copy_N_end
  lw   t3, 0(N)
  sw   t3, 0(t1)
  addi t1, t1, 4
  addi N, N, 4
  j    .copy_N
.copy_N_end:

  addi t0, ctx, (4*size_of_mrz+4)
.zero_struct:
  beq  t1, t0, .zero_struct_end
  sw   zero, 0(t1)
  addi t1, t1, 4
  j    .zero_struct
.zero_struct_end:

  sw   l_N, l_N_offset(ctx)

  li   t0, 1
  sw   t0, rho_0_offset(ctx)
  sw   t0, rho_1_offset(ctx)

  lw   s2, l_N_offset(ctx)
  slli s2, s2, 5
.rho_1_loop:
  beqz s2, .rho_1_loop_end

  mv   a0, ctx
  addi a1, ctx, rho_1_offset
  mv   a2, a1
  mv   a3, a1
  jal  mrz_add

  addi s2, s2, -1
  j    .rho_1_loop
.rho_1_loop_end:

  addi t0, ctx, rho_2_offset
  mv   t1, t0
  addi t2, ctx, rho_1_offset
.copy_rho:
  beq  t2, t1, .copy_rho_end
  lw   t3, 0(t2)
  sw   t3, 0(t0)
  addi t0, t0, 4
  addi t2, t2, 4
  j    .copy_rho
.copy_rho_end:

  lw   s2, l_N_offset(ctx)
  slli s2, s2, 5
.rho_2_loop:
  beqz s2, .rho_2_loop_end

  mv   a0, ctx
  addi a1, ctx, rho_2_offset
  mv   a2, a1
  mv   a3, a1
  jal  mrz_add

  addi s2, s2, -1
  j    .rho_2_loop
.rho_2_loop_end:

  li   t1, 1
  lw   t2, N_offset(ctx)
  li   t0, 31
.omega_loop:
  beqz t0, .omega_loop_end

  mul  t1, t1, t1
  mul  t1, t1, t2

  addi t0, t0, -1
  j    .omega_loop
.omega_loop_end:

  neg  t1, t1
  sw   t1, omega_offset(ctx)

  mv   ra, s1
  lw   s0, 0(sp)
  lw   s1, 4(sp)
  lw   s2, 8(sp)
  addi sp, sp, 12
  ret

.endfunc
	
// ============================================================================	
