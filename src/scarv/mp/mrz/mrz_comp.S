/* Copyright (C) 2019 SCARV project <info@scarv.org>
 *
 * Use of this source code is restricted per the MIT license, a copy of which 
 * can be found at https://opensource.org/licenses/MIT (or should be included 
 * as LICENSE.txt within the associated archive or repository).
 */

#include <scarv/share/conf.h>

// ============================================================================	

.section .text

.func    mrz_precomp_asm_comp
.global  mrz_precomp_asm_comp

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

#define mcompose 0x7c0
#define n_cores  s3
#define one      s4
#define bytes_per_word t6

// void mrz_precomp_asm_comp( mrz_ctx_t* ctx, const limb_t* N, int l_N, int n_cores );

mrz_precomp_asm_comp:
  csrw mcompose, a3
  slli bytes_per_word, a3, 2
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
  mv   s0, a0
  mv   s1, ra
  mv   n_cores, a3
  li   one, 1

  slli t0, l_N, 2
  add  t0, t0, ctx
  mv   t1, ctx
.copy_N:
  beq  t1, t0, .copy_N_end
  lw   t3, 0(N)
  sw   t3, 0(t1)
  add  t1, t1, bytes_per_word
  add  N, N, bytes_per_word
  j    .copy_N
.copy_N_end:

  addi t0, zero, (4*size_of_mrz+4)
  mul  t0, t0, n_cores
  add  t0, t0, ctx
.zero_struct:
  beq  t1, t0, .zero_struct_end
  sw   zero, 0(t1)
  add  t1, t1, bytes_per_word
  j    .zero_struct
.zero_struct_end:

  addi t0, zero, l_N_offset
  mul  t0, t0, n_cores
  add  t0, t0, ctx
  sw   l_N, 0(t0)

  addi t0, zero, rho_0_offset
  mul  t0, t0, n_cores
  add  t0, t0, ctx
  sw   one, 0(t0)
  addi t0, zero, rho_1_offset
  mul  t0, t0, n_cores
  add  t0, t0, ctx
  sw   one, 0(t0)

  mv   s2, l_N
  slli s2, s2, 5
  li   a5, rho_1_offset
  mul  a5, a5, n_cores
  add  a5, a5, ctx
  slli a6, l_N, 2
  add  a6, a6, a5
  jal  .rho_loop

  li   t0, rho_2_offset
  mul  t0, t0, n_cores
  add  t0, t0, ctx
  mv   t1, t0
  li   t2, rho_1_offset
  mul  t2, t2, n_cores
  add  t2, t2, ctx
.copy_rho:
  beq  t2, t1, .copy_rho_end
  lw   t3, 0(t2)
  sw   t3, 0(t0)
  addi t0, t0, 4
  addi t2, t2, 4
  j    .copy_rho
.copy_rho_end:

  mv   s2, l_N
  slli s2, s2, 5
  li   a5, rho_2_offset
  mul  a5, a5, n_cores
  add  a5, a5, ctx
  slli a6, l_N, 2
  add  a6, a6, a5
  jal  .rho_loop

  li   t1, 1
  lw   t2, N_offset(ctx)
  li   t0, 32
  mul  t0, t0, n_cores
  sub  t0, t0, one
.omega_loop:
  beqz t0, .omega_loop_end

  mul  t1, t1, t1
  mul  t1, t1, t2

  sub  t0, t0, one
  j    .omega_loop
.omega_loop_end:

  neg  t1, t1
  addi t0, zero, omega_offset
  mul  t0, t0, n_cores
  add  t0, t0, ctx
  sw   t1, 0(t0)

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
  slli t3, l_N, 2
  add  t3, t3, ctx
  sub  t3, t3, bytes_per_word
.rho_cmp:
  sub  t1, t1, bytes_per_word
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
  mv   a7, ctx
  add  a4, a6, bytes_per_word
.rho_sub:
  beq  t1, a4, .rho_sub_end
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
	
// ============================================================================	
