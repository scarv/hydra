.section .text
.balign 4

.global mp_xor_ref

#define a_value        t0
#define b_value        t1
#define res_value      t2
#define a_addr         a0
#define a_addr_end     t4
#define b_addr         a1
#define res_addr       a2
#define n_words        a3
#define n_bytes        a6

// extern void mp_xor_ref(const void *a, const void *b, void *res, int n_words);
mp_xor_ref:
    slli n_bytes, n_words, 2
    add  a_addr_end, n_bytes, a_addr
mp_xor_loop:
    beq  a_addr, a_addr_end, mp_xor_end
    lw   a_value, 0(a_addr)
    lw   b_value, 0(b_addr)
    xor  res_value, a_value, b_value
    sw   res_value, 0(res_addr)
    addi a_addr, a_addr, 4
    addi b_addr, b_addr, 4
    addi res_addr, res_addr, 4
    j    mp_xor_loop
mp_xor_end:
    ret


