.section .text
.balign 4

.global mp_xor_com

#define mcompose_wide 0
#define mcompose_simd 1
#define mcompose_redu 2

#define mcompose_reg  0x7c0
#define mcompose_mode 0x7c1

#define a_value        t0
#define b_value        t1
#define res_value      t2
#define a_addr         a0
#define a_addr_end     t4
#define b_addr         a1
#define res_addr       a2
#define bytes_per_word a3
#define n_words        a3
#define n_cores        a4
#define n_bytes        a6

// extern void mp_xor_com(const void *a, const void *b, void *res, int n_words, int n_cores);
mp_xor_com:
    csrwi mcompose_mode, mcompose_simd
    csrw  mcompose_reg , n_cores

    slli n_bytes, n_words, 2
    slli bytes_per_word, n_cores, 2
    add  a_addr_end, n_bytes, a_addr
mp_xor_comp_loop:
    beq  a_addr, a_addr_end, mp_xor_comp_end
    lw   a_value, 0(a_addr)
    lw   b_value, 0(b_addr)
    xor  res_value, a_value, b_value
    sw   res_value, 0(res_addr)
    add a_addr, a_addr, bytes_per_word
    add b_addr, b_addr, bytes_per_word
    add res_addr, res_addr, bytes_per_word
    j    mp_xor_comp_loop
mp_xor_comp_end:
    csrw mcompose_reg, zero
    ret
