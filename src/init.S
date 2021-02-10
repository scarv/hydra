.section .init
.global main

/* set stack pointer */
li sp, MEM_SIZE

/* adjust stack pointer by hart id (STACK_SIZE bytes per hart) */
csrr t0, 0xF14
li   t1, 0
adjust_stack:
    beq  t0, t1, adjust_stack_end
    addi  sp, sp, -STACK_SIZE
    addi t1, t1, 1
    j    adjust_stack
adjust_stack_end:

/* call main */
jal ra, main

/* break */
ebreak



