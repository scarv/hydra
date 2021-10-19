# Copyright (C) 2021 SCARV project <info@scarv.org>
#
# Use of this source code is restricted per the MIT license, a copy of which 
# can be found at https://opensource.org/licenses/MIT (or should be included 
# as LICENSE.txt within the associated archive or repository).

.section .text

#define X0  s0  
#define X1  s1
#define X2  s2  
#define X3  s3
#define X4  s4
#define X5  s5
#define X6  s6
#define X7  s7
#define X8  s8
#define X9  s9
#define X10 s10
#define X11 t1
#define X12 t2
#define X13 t3
#define X14 t4 
#define X15 t5 

#define C0  a6  
#define C1  a7
#define C2  t6  
#define C3  s11

.macro ADDK a k
    lw  t0,  \k(a3)
	add \a, \a, t0
.endm

.macro ADDN a n
    lw  t0,  \n(a4)
	add \a, \a, t0
.endm

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

.macro XORDATA X0,X1, a1, a0, n
	lw   t0,  \n(\a1)
	xor  t0,  \X0, t0
	sw   t0,  \n(\a0)
	lw   t0,  \n+4(\a1)
	xor  t0,  \X1, t0
	sw   t0,  \n+4(\a0)

.endm

# Using the same order as the boring chacha arguments:
# a0 = uint8_t *out
# a1 = uint8_t *in
# a2 = size_t in_len
# a3 = uint8_t key[32]
# a4 = uint8_t nonce[12]
# a5 = uint32_t counter
.global chacha20_ref
chacha20_ref:
    addi    sp, sp, -128                   // Allocate stack space.

    sw      s0 , 0(sp)
    sw      s1 , 8(sp)
    sw      s2 ,16(sp)
    sw      s3 ,24(sp)
    sw      s4 ,32(sp)
    sw      s5 ,40(sp)
    sw      s6 ,48(sp)
    sw      s7 ,56(sp)
    sw      s8 ,64(sp)
    sw      s9 ,72(sp)
    sw      s10,80(sp)
    sw      s11,88(sp)
    sw      a0 ,96(sp)
    sw      a1 ,104(sp)
    sw      a4 ,112(sp)

	# initialize vector state
	# Load 4*32 bit constant        
	la    t0, ChaChaConstant
	lw C0, 0(t0)
	lw C1, 4(t0)
	lw C2, 8(t0)
	lw C3,12(t0)

encrypt_blocks:

	mv X0, C0
	mv X1, C1
	mv X2, C2
	mv X3, C3

	# Load 8* 32 key
    lw X4,   0(a3)
	lw X5,   4(a3)
	lw X6,   8(a3)
	lw X7,  12(a3)
    lw X8,  16(a3)
	lw X9,  20(a3)
	lw X10, 24(a3)
	lw X11, 28(a3)

	# Load nonce & counter=0
    mv X12,  a5
	lw X13,  0(a4)
	lw X14,  4(a4)
	lw X15,  8(a4)

	li a4, 10 # loop counter
round_loop:
         
        CHACHA_QR X0,X4, X8,X12    
        CHACHA_QR X1,X5, X9,X13
        CHACHA_QR X2,X6,X10,X14
        CHACHA_QR X3,X7,X11,X15

        CHACHA_QR X0,X5,X10,X15    
        CHACHA_QR X1,X6,X11,X12
        CHACHA_QR X2,X7, X8,X13
        CHACHA_QR X3,X4, X9,X14

	addi a4, a4, -1
	bnez a4, round_loop

	lw      a4 ,112(sp)

	# Add in initial block values.
	add X0, X0, C0
	add X1, X1, C1
	add X2, X2, C2
	add X3, X3, C3
	# add 8* 32 key
	ADDK X4,  0
	ADDK X5,  4
	ADDK X6,  8
	ADDK X7, 12
	ADDK X8, 16
	ADDK X9, 20
	ADDK X10,24
	ADDK X11,28
	# add counter & nonce 

	add X12,X12, a5
	ADDN X13, 0
	ADDN X14, 4
	ADDN X15, 8


	# xor in state
	XORDATA X0, X1, a1, a0, 0
	XORDATA X2, X3, a1, a0, 8
	XORDATA X4, X5, a1, a0,16
	XORDATA X6, X7, a1, a0,24
	XORDATA X8, X9, a1, a0,32
	XORDATA X10,X11,a1, a0,40
	XORDATA X12,X13,a1, a0,48
	XORDATA X14,X15,a1, a0,56

	# update counters/pointers
	addi a0, a0, 64 # advance output pointer
	addi a1, a1, 64 # advance input pointer
	addi a5, a5, 1 # increment counter; crash if counter overflows
	addi a2, a2, -64 # decrement remaining bytes

	# loop again if we have remaining blocks
	bgt a2, x0, encrypt_blocks

    lw      s0 , 0(sp)
    lw      s1 , 8(sp)
    lw      s2 ,16(sp)
    lw      s3 ,24(sp)
    lw      s4 ,32(sp)
    lw      s5 ,40(sp)
    lw      s6 ,48(sp)
    lw      s7 ,56(sp)
    lw      s8 ,64(sp)
    lw      s9 ,72(sp)
    lw      s10,80(sp)
    lw      s11,88(sp)
    lw      a0 ,96(sp)
    lw      a1 ,104(sp)
    lw      a4 ,112(sp)
    
    addi    sp, sp, 128                    // de-Allocate stack space.
ret

.section .data
.balign 8                 # align to 4 bytes
ChaChaConstant:
.word   0x61707865, 0x3320646e, 0x79622d32, 0x6b206574




