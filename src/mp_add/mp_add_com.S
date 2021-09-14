.section .text
.balign 4

.global mp_add_com

#define mcompose 0x7c0

#define a_value        t0
#define b_value        t1
#define res_value      t2
#define a_addr         a0
#define a_addr_end     t4
#define b_addr         a1
#define res_addr       a2
#define carry          a5
#define temp_carry     a7
#define bytes_per_word a3
#define n_words        a3
#define n_cores        a4
#define n_bytes        a6
#define carry_out      a0

// extern int mp_add_com(const void *a, const void *b, void *res, int n_words, int n_cores);
mp_add_com:
    csrw mcompose, n_cores
    slli bytes_per_word, n_cores, 2
    li   carry, 0
    slli n_bytes, n_words, 2
    add  a_addr_end, n_bytes, a_addr
mp_add_comp_loop:
    beq  a_addr, a_addr_end, mp_add_comp_end
    lw   a_value, 0(a_addr)
    lw   b_value, 0(b_addr)
    add  res_value, a_value, carry
    sltu carry, res_value, a_value
    add  res_value, res_value, b_value
    sltu temp_carry, res_value, b_value
    or   carry, carry, temp_carry
    sw   res_value, 0(res_addr)
    add a_addr, a_addr, bytes_per_word
    add b_addr, b_addr, bytes_per_word
    add res_addr, res_addr, bytes_per_word
    j    mp_add_comp_loop
mp_add_comp_end:
    csrw mcompose, zero
    mv   carry_out, carry
    ret


