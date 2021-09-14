.section .text
.balign 4

.global mp_mul_ref


#define mhartid 0xf14
#define mcompose 0x7c0

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
#define n_words        a3
#define n_bytes        a6

// extern void mp_mul_ref(const void *a, const void *b, void *res, int n_words);
mp_mul_ref:
    slli n_bytes, n_words, 2
    add  a_addr_end, n_bytes, a_addr
    add  b_addr_end, n_bytes, b_addr
    mv   res_addr_temp, res_addr
    add  temp, res_addr_temp, n_bytes
zero_loop:
    beq  res_addr_temp, temp, b_loop
    sw   zero, 0(res_addr_temp)
    addi res_addr_temp, res_addr_temp, 4
    j    zero_loop
b_loop:
    beq  b_addr, b_addr_end, b_loop_end
    li   carry, 0
    lw   b_value, 0(b_addr)
    mv   res_addr_temp, res_addr
    mv   a_addr_temp, a_addr
a_loop:
    beq   a_addr_temp, a_addr_end, a_loop_end
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
    addi  res_addr_temp, res_addr_temp, 4
    addi  a_addr_temp, a_addr_temp, 4
    j     a_loop
a_loop_end:
    sw   carry, 0(res_addr_temp)
    addi res_addr, res_addr, 4
    addi b_addr, b_addr, 4
    j    b_loop
b_loop_end:
    ret


