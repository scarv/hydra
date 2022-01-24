.section .text
.balign 4

.global mp_mul_com

#define mcompose_wide 0
#define mcompose_simd 1
#define mcompose_redu 2

#define mcompose_reg  0x7c0
#define mcompose_mode 0x7c1

#define a_value        t0
#define b_value        t1
#define res_value      t2
#define a_addr         a0
#define a_addr_temp    t3
#define a_addr_end     t4
#define b_addr         a1
#define b_addr_end     t5
#define res_addr       a2
#define res_addr_temp  t6
#define temp           a6
#define carry          a5
#define bytes_per_word a3
#define n_words        a3
#define n_cores        a4
#define n_bytes        a6

// extern void mp_mul_com(const void *a, const void *b, void *res, int n_words, int n_cores);
mp_mul_com:
    csrwi mcompose_mode, mcompose_wide
    csrw  mcompose_reg,  n_cores

    slli n_bytes, n_words, 2
    slli bytes_per_word, n_cores, 2
    add  a_addr_end, n_bytes, a_addr
    add  b_addr_end, n_bytes, b_addr
    mv   res_addr_temp, res_addr
    add  temp, res_addr_temp, n_bytes
zero_loop_comp:
    beq  res_addr_temp, temp, b_loop_comp
    sw   zero, 0(res_addr_temp)
    add  res_addr_temp, res_addr_temp, bytes_per_word
    j    zero_loop_comp
b_loop_comp:
    beq  b_addr, b_addr_end, b_loop_end_comp
    li   carry, 0
    lw   b_value, 0(b_addr)
    mv   res_addr_temp, res_addr
    mv   a_addr_temp, a_addr
a_loop_comp:
    beq   a_addr_temp, a_addr_end, a_loop_end_comp
    lw    a_value, 0(a_addr_temp)
    lw    res_value, 0(res_addr_temp)
    mul   temp, a_value, b_value
    add   res_value, res_value, carry
    sltu  carry, res_value, carry
    add   res_value, res_value, temp
    sltu  temp, res_value, temp
    add   carry, carry, temp
    mulhu temp, a_value, b_value
    add   carry, carry, temp
    sw    res_value, 0(res_addr_temp)
    add   res_addr_temp, res_addr_temp, bytes_per_word
    add   a_addr_temp, a_addr_temp, bytes_per_word
    j     a_loop_comp
a_loop_end_comp:
    sw   carry, 0(res_addr_temp)
    add  res_addr, res_addr, bytes_per_word
    add  b_addr, b_addr, bytes_per_word
    j    b_loop_comp
b_loop_end_comp:
    csrw mcompose_reg, zero
    ret



