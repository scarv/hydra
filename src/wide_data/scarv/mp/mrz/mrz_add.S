/* Copyright (C) 2019 SCARV project <info@scarv.org>
 *
 * Use of this source code is restricted per the MIT license, a copy of which 
 * can be found at https://opensource.org/licenses/MIT (or should be included 
 * as LICENSE.txt within the associated archive or repository).
 */

#include <scarv/share/conf.h>

// ============================================================================	

.section .text

.func    mrz_add_asm
.global  mrz_add_asm

// void mrz_add_asm( const limb_t *N, mrz_t r, const mrz_t x, const mrz_t y, int l_N );

mrz_add_asm:
  
  mv   t1, a1
  slli a4, a4, 2
  add  t6, a1, a4
  li   t2, 0
.add:
  beq  t1, t6, .add_end
  lw   t3, 0(a2)
  lw   t0, 0(a3)
  add  t4, t3, t2
  sltu t2, t4, t3
  add  t4, t4, t0
  sltu t5, t4, t0
  or   t2, t2, t5
  sw   t4, 0(t1)
  addi a2, a2, 4
  addi a3, a3, 4
  addi t1, t1, 4
  j    .add
.add_end:

  sw   t2, 0(t1)
  bnez t2, .do_sub

  li   t2, 1
  add  t3, a0, a4
.cmp:
  addi t6, t6, -4
  addi t3, t3, -4
  beq  t6, a1, .cmp_end
  lw   t4, 0(t6)
  lw   t5, 0(t3)
  beq  t4, t5, .cmp
  sltu t2, t5, t4
.cmp_end:

  beqz t2, .sub_end

.do_sub:
  li   t2, 0
  add  a5, a0, a4
  addi a5, a5, 4
.sub:
  beq  a0, a5, .sub_end
  lw   t0, 0(a1)
  lw   t3, 0(a0)
  sub  t4, t0, t3
  sltu t0, t0, t4
  sub  t5, t4, t2
  sltu t2, t4, t5
  or   t2, t2, t0
  sw   t5, 0(a1)
  addi a1, a1, 4
  addi a0, a0, 4
  j    .sub
.sub_end:

  ret

.endfunc
	
// ============================================================================	
