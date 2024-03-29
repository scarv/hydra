.section .init
.global main
.global irq

#include "custom_ops.S"

reset_vec:
  li sp, MEM_SIZE
  csrr t0, 0xF14
  j  setup_stack

.balign 16
irq_vec:
    picorv32_setq_insn q2, x1
	picorv32_setq_insn q3, x2

	lui x1, %hi(irq_regs)
	addi x1, x1, %lo(irq_regs)

	picorv32_getq_insn x2, q0
	sw x2,   0*4(x1)

	picorv32_getq_insn x2, q2
	sw x2,   1*4(x1)

	picorv32_getq_insn x2, q3
	sw x2,   2*4(x1)
    sw x3,   3*4(x1)
	sw x4,   4*4(x1)
	sw x5,   5*4(x1)
	sw x6,   6*4(x1)
	sw x7,   7*4(x1)
	sw x8,   8*4(x1)
	sw x9,   9*4(x1)
	sw x10, 10*4(x1)
	sw x11, 11*4(x1)
	sw x12, 12*4(x1)
	sw x13, 13*4(x1)
	sw x14, 14*4(x1)
	sw x15, 15*4(x1)
	sw x16, 16*4(x1)
	sw x17, 17*4(x1)
	sw x18, 18*4(x1)
	sw x19, 19*4(x1)
	sw x20, 20*4(x1)
	sw x21, 21*4(x1)
	sw x22, 22*4(x1)
	sw x23, 23*4(x1)
	sw x24, 24*4(x1)
	sw x25, 25*4(x1)
	sw x26, 26*4(x1)
	sw x27, 27*4(x1)
	sw x28, 28*4(x1)
	sw x29, 29*4(x1)
	sw x30, 30*4(x1)
	sw x31, 31*4(x1)

  /* call interrupt handler C function */

	lui sp, %hi(irq_stack)
	addi sp, sp, %lo(irq_stack)

	// arg0 = address of regs
	lui a0, %hi(irq_regs)
	addi a0, a0, %lo(irq_regs)

	// arg1 = interrupt type
	picorv32_getq_insn a1, q1

	// call to C function
	jal ra, irq

	/* restore registers */

	// new irq_regs address returned from C code in a0
	addi x1, a0, 0

	lw x2,   0*4(x1)
	picorv32_setq_insn q0, x2

	lw x2,   1*4(x1)
	picorv32_setq_insn q1, x2

	lw x2,   2*4(x1)
	picorv32_setq_insn q2, x2
    lw x3,   3*4(x1)
	lw x4,   4*4(x1)
	lw x5,   5*4(x1)
	lw x6,   6*4(x1)
	lw x7,   7*4(x1)
	lw x8,   8*4(x1)
	lw x9,   9*4(x1)
	lw x10, 10*4(x1)
	lw x11, 11*4(x1)
	lw x12, 12*4(x1)
	lw x13, 13*4(x1)
	lw x14, 14*4(x1)
	lw x15, 15*4(x1)
	lw x16, 16*4(x1)
	lw x17, 17*4(x1)
	lw x18, 18*4(x1)
	lw x19, 19*4(x1)
	lw x20, 20*4(x1)
	lw x21, 21*4(x1)
	lw x22, 22*4(x1)
	lw x23, 23*4(x1)
	lw x24, 24*4(x1)
	lw x25, 25*4(x1)
	lw x26, 26*4(x1)
	lw x27, 27*4(x1)
	lw x28, 28*4(x1)
	lw x29, 29*4(x1)
	lw x30, 30*4(x1)
	lw x31, 31*4(x1)

    picorv32_getq_insn x1, q1
	picorv32_getq_insn x2, q2

    picorv32_retirq_insn
  
setup_stack:
  /* adjust stack pointer by hart id (STACK_SIZE bytes per hart) */
  // Zero all of the registers
//  mv  x1 , x0
//  mv  x2 , x0
  mv  x3 , x0
  mv  x4 , x0
  mv  x8 , x0
  mv  x9 , x0
  mv  x10, x0
  mv  x11, x0
  mv  x12, x0
  mv  x13, x0
  mv  x14, x0
  mv  x15, x0
  mv  x16, x0
  mv  x17, x0
  mv  x18, x0
  mv  x19, x0
  mv  x20, x0
  mv  x21, x0
  mv  x22, x0
  mv  x23, x0
  mv  x24, x0
  mv  x25, x0
  mv  x26, x0
  mv  x27, x0
  mv  x28, x0
  mv  x29, x0
  mv  x30, x0
  mv  x31, x0
  li   t1, 0
  li   t2, STACK_SIZE
  adjust_stack:
    beq  t0, t1, adjust_stack_end
    sub  sp, sp, t2
    addi t1, t1, 1
    j    adjust_stack
  adjust_stack_end:

//checking master core to setup interupt mask
bnez t0, call_main  
li   t1, 1
not  t1, t1
picorv32_maskirq_insn zero, t1

call_main:
jal ra, main

/* break */
ebreak

irq_regs:
	// registers are saved to this memory region during interrupt handling
	// the program counter is saved as register 0
	.fill 32,4

	// stack for the interrupt handler
	.fill 128,4
irq_stack:



