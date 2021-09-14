.section .text
.balign 4

.global mp_add_ref

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

// extern int mp_add_ref(const void *a, const void *b, void *res, int n_words);
mp_add_ref:
    li   carry, 0
    slli n_bytes, n_words, 2
    add  a_addr_end, n_bytes, a_addr
mp_add_loop:
    beq  a_addr, a_addr_end, mp_add_end
    lw   a_value, 0(a_addr)
    lw   b_value, 0(b_addr)
    add  res_value, a_value, carry
    sltu carry, res_value, a_value
    add  res_value, res_value, b_value
    sltu temp_carry, res_value, b_value
    or   carry, carry, temp_carry
    sw   res_value, 0(res_addr)
    addi a_addr, a_addr, 4
    addi b_addr, b_addr, 4
    addi res_addr, res_addr, 4
    j    mp_add_loop
mp_add_end:
    mv   carry_out, carry
    ret


