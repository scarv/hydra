# Copyright (C) 2021 SCARV project <info@scarv.org>
#
# Use of this source code is restricted per the MIT license, a copy of which 
# can be found at https://opensource.org/licenses/MIT (or should be included 
# as LICENSE.txt within the associated archive or repository).

.section .text

#ifndef n_cores
#define n_cores       4
#endif

#define mcompose_reg  0x7c0
#define mcompose_mode 0x7c1
#define mcompose_wide 0
#define mcompose_simd 1
#define mcompose_redu 2


#define X0  t1  
#define X4  t2
#define X8  t3
#define X12 t4

#define X2  s2
#define X6  s3
#define X10 s4
#define X14 s5
#define S2  s6
#define S6  s7
#define S10 s8
#define S14 s9

#define S0  a6  
#define S4  a7
#define S8  t5  
#define S12 t6


.macro ROL32 x, y, n 
  slli      t0,   \y,  \n
  srli      \x,   \y,  (32-\n)
  or        \x,   \x,  t0 
.endm

.macro CHACHA_QR a b c d
	add  \a, \a, \b
	xor  \d, \d, \a
        ROL32 \d, \d, 16
	add   \c, \c, \d
	xor   \b, \b, \c
        ROL32 \b, \b, 12
	add  \a, \a, \b
	xor   \d, \d, \a
        ROL32 \d, \d,  8
	add  \c, \c, \d
	xor   \b, \b, \c
        ROL32 \b, \b,  7
.endm

.macro MCOMPOSE4_ROTATE R1, R2, R3, p
    sw   \R1,  0(\p)
    sw   \R1, 16(\p)
    lw   \R1,  4(\p)

    sw   \R2,  0(\p)
    sw   \R2, 16(\p)
    lw   \R2,  8(\p)

    sw   \R3,  0(\p)
    sw   \R3, 16(\p)
    lw   \R3, 12(\p)
.endm

.macro MCOMPOSE2_ROTATE R1, R2, R3, R4, R5, R6, p
    sw   \R1,  0(\p)
    sw   \R1, 16(\p)
    sw   \R2,  8(\p)

    lw   \R1,  4(\p)
    lw   \R2, 12(\p)

    sw   \R3,  0(\p)
    sw   \R4,  8(\p)
    lw   \R3,  8(\p)
    lw   \R4,  0(\p)

    sw   \R6,  0(\p)
    sw   \R6, 16(\p)
    sw   \R5,  8(\p)
    lw   \R5,  4(\p)
    lw   \R6, 12(\p)
.endm

.macro XORDATA X0, a1, a0, n
	lw   a5,  \n(\a1)
	xor  a5,  \X0, a5
	sw   a5,  \n(\a0)
.endm

# Using the same order as the boring chacha arguments:
# a0 = uint8_t *out
# a1 = uint8_t *in
# a2 = size_t in_len
# a3 = uint8_t key[32]
# a4 = uint8_t counter[4] + nonce[12]
.global chacha20_com
chacha20_com:
	la    t0, ChaChaConstant
    la    a5, CountInc
    addi  sp, sp, -164
    csrwi mcompose_mode, mcompose_simd
    csrw  mcompose_reg,  n_cores
    
    sw   s0, 0(sp)
    sw   s1,16(sp)
#if n_cores==2
    sw   s2,32(sp)
    sw   s3,48(sp)
    sw   s4,64(sp)
    sw   s5,80(sp)
    sw   s6,96(sp)
    sw   s7,112(sp)
    sw   s8,128(sp)
    sw   s9,144(sp)
#endif
	# initialize vector state
	# Load 4*32 bit constant        
	lw X0, 0(t0)
#if n_cores==2 
	lw X2, 8(t0)
#endif
	# Load 8* 32 key
    lw X4,   0(a3)
    lw X8,  16(a3)
#if n_cores==2 
    lw X6,   8(a3)
    lw X10, 24(a3)
#endif
	# Load counter & nounce=0
    lw X12,  0(a4)
#if n_cores==2 
    lw X14,  8(a4)
#endif

	# Load counter inscrease
    lw s0,   0(a5)

encrypt_blocks:

    mv S0,  X0
    mv S4,  X4
    mv S8,  X8
    mv S12, X12
#if n_cores==2 
    mv S2,  X2
    mv S6,  X6
    mv S10, X10
    mv S14, X14
#endif


	li a5, 10 # loop counter
round_loop:
         
        CHACHA_QR        S0, S4, S8, S12   
#if n_cores==2 
        CHACHA_QR        S2, S6, S10,S14
        MCOMPOSE2_ROTATE S4, S6, S8, S10, S12, S14, a0
#endif

#if n_cores==4
        MCOMPOSE4_ROTATE S4, S8, S12, a0
#endif
         
        CHACHA_QR        S0, S4, S8, S12  
#if n_cores==2
        CHACHA_QR        S2, S6, S10,S14
        MCOMPOSE2_ROTATE S12,S14,S8, S10, S4, S6, a0
#endif  

#if n_cores==4
        MCOMPOSE4_ROTATE S12,S8, S4,  a0
#endif

	addi a5, a5, -1
	bnez a5, round_loop

	# Add in initial block values.
	add S0, S0, X0
    add S4, S4, X4
	add S8, S8, X8
	add S12,S12,X12
#if n_cores==2
	add S2, S2, X2
    add S6, S6, X6
	add S10,S10,X10
	add S14,S14,X14
#endif  

	# xor in state for encryption/description
	XORDATA S0, a1, a0, 0
	XORDATA S4, a1, a0,16
	XORDATA S8, a1, a0,32
	XORDATA S12,a1, a0,48
#if n_cores==2
	XORDATA S2, a1, a0, 8
	XORDATA S6, a1, a0,24
	XORDATA S10,a1, a0,40
	XORDATA S14,a1, a0,56
#endif  

	# update counters/pointers
	addi a0, a0, 64  # advance output pointer
	addi a1, a1, 64  # advance input pointer
	add  X12,X12,s0  # increment counter; crash if counter overflows
	addi a2, a2, -64 # decrement remaining bytes

	# loop again if we have remaining blocks
	bgt a2, x0, encrypt_blocks  

    lw   s0, 0(sp)
    lw   s1,16(sp)
#if n_cores==2
    lw   s2,32(sp)
    lw   s3,48(sp)
    lw   s4,64(sp)
    lw   s5,80(sp)
    lw   s6,96(sp)
    lw   s7,112(sp)
    lw   s8,128(sp)
    lw   s9,144(sp)
#endif
    csrw mcompose_reg, zero
    addi  sp, sp, 164
ret

.section .data
.balign 8                 # align to 4 bytes
ChaChaConstant:
.word   0x61707865, 0x3320646e, 0x79622d32, 0x6b206574
CountInc:
.word   1, 0, 0, 0



