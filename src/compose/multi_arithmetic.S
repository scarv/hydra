.section .text
.balign 4

.global multi_add
.global multi_sub
.global multi_mult
.global multi_xor

.global multi_add_comp
.global multi_xor_comp
.global multi_mult_comp

#define mhartid 0xf14
#define mcompose 0x7c0

#define a_value        t0
#define hart_id        a7
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
#define temp_carry     a7
#define bytes_per_word a3
#define n_words        a3
#define n_cores        a4
#define n_bytes        a6
#define carry_out      a0

// extern int multi_add(const void *a, const void *b, void *res, int n_words);
multi_add:
    li   carry, 0
    slli n_bytes, n_words, 2
    add  a_addr_end, n_bytes, a_addr
multi_add_loop:
    beq  a_addr, a_addr_end, multi_add_end
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
    j    multi_add_loop
multi_add_end:
    mv   carry_out, carry
    ret

// extern int multi_add_comp(const void *a, const void *b, void *res, int n_words, int n_cores);
multi_add_comp:
    csrw mcompose, n_cores
    slli bytes_per_word, n_cores, 2
    li   carry, 0
    slli n_bytes, n_words, 2
    add  a_addr_end, n_bytes, a_addr
multi_add_comp_loop:
    beq  a_addr, a_addr_end, multi_add_comp_end
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
    j    multi_add_comp_loop
multi_add_comp_end:
    csrw mcompose, zero
    mv   carry_out, carry
    ret


// extern int multi_sub(const void *a, const void *b, void *res, int n_words);
multi_sub:
    li   carry, 1
    slli n_bytes, n_words, 2
    add  a_addr_end, n_bytes, a_addr
multi_sub_loop:
    beq  a_addr, a_addr_end, multi_add_end
    lw   a_value, (a_addr)
    lw   b_value, (b_addr)
    not  b_value, b_value
    add  res_value, a_value, carry
    sltu carry, res_value, a_value
    add  res_value, res_value, b_value
    sltu temp_carry, res_value, b_value
    or   carry, carry, temp_carry
    sw   res_value, (res_addr)
    addi a_addr, a_addr, 4
    addi b_addr, b_addr, 4
    addi res_addr, res_addr, 4
    j    multi_sub_loop
multi_sub_end:
    mv   carry_out, carry
    ret

// extern void multi_mult(const void *a, const void *b, void *res, int n_words);
multi_mult:
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

// extern void multi_mult_comp(const void *a, const void *b, void *res, int n_words, int n_cores);
multi_mult_comp:
    csrw mcompose, n_cores
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
    csrw mcompose, zero
    ret


// extern void multi_xor(const void *a, const void *b, void *res, int n_words);
multi_xor:
    slli n_bytes, n_words, 2
    add  a_addr_end, n_bytes, a_addr
multi_xor_loop:
    beq  a_addr, a_addr_end, multi_xor_end
    lw   a_value, 0(a_addr)
    lw   b_value, 0(b_addr)
    xor  res_value, a_value, b_value
    sw   res_value, 0(res_addr)
    addi a_addr, a_addr, 4
    addi b_addr, b_addr, 4
    addi res_addr, res_addr, 4
    j    multi_xor_loop
multi_xor_end:
    ret

// extern void multi_xor_comp(const void *a, const void *b, void *res, int n_words, int n_cores);
multi_xor_comp:
    csrw mcompose, n_cores
    slli n_bytes, n_words, 2
    slli bytes_per_word, n_cores, 2
    add  a_addr_end, n_bytes, a_addr
multi_xor_comp_loop:
    beq  a_addr, a_addr_end, multi_xor_comp_end
    lw   a_value, 0(a_addr)
    lw   b_value, 0(b_addr)
    xor  res_value, a_value, b_value
    sw   res_value, 0(res_addr)
    add a_addr, a_addr, bytes_per_word
    add b_addr, b_addr, bytes_per_word
    add res_addr, res_addr, bytes_per_word
    j    multi_xor_comp_loop
multi_xor_comp_end:
    csrw mcompose, zero
    ret
