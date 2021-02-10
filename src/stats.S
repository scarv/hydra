.text
.balign 4

.global multi_add
.global multi_sub
.global print_stats

.global AES_init_ctx
.global AES_ECB_encrypt

.global multi_add_stats
.global multi_sub_stats

.global AES_init_ctx_stats
.global AES_ECB_encrypt_stats

.macro stats function_name
    addi sp, sp, -32
    sw   s0, 0(sp)
    sw   s1, 4(sp)
    sw   s2, 8(sp)
    sw   s3, 12(sp)
    sw   s4, 16(sp)
    mv   s0, ra
    rdinstret s1
    rdcycle s2
    jal \function_name
    rdcycle s3
    rdinstret s4
    sub  a0, s3, s2
    sub  a1, s4, s1
    addi a0, a0, -4
    addi a1, a1, -3
    jal  print_stats
    mv   ra, s0
    lw   s0, 0(sp)
    lw   s1, 4(sp)
    lw   s2, 8(sp)
    lw   s3, 12(sp)
    lw   s4, 16(sp)
    addi sp, sp, 32
    ret
.endm

multi_add_stats: stats multi_add
multi_sub_stats: stats multi_sub
AES_init_ctx_stats: stats AES_init_ctx
AES_ECB_encrypt_stats: stats AES_ECB_encrypt
    
