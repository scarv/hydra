// This is free and unencumbered software released into the public domain.
//
// Anyone is free to copy, modify, publish, use, compile, sell, or
// distribute this software, either in source code form or as a compiled
// binary, for any purpose, commercial or non-commercial, and by any
// means.

#define q0  x0
#define q1  x1
#define q2  x2
#define q3  x3

.macro picorv32_getq_insn rd, rs1
	.insn r CUSTOM_0, 0b100, 0b0000000, \rd, \rs1, x0
.endm

.macro picorv32_setq_insn rd, rs1
	.insn r CUSTOM_0, 0b010, 0b0000001, \rd, \rs1, x0
.endm

.macro picorv32_retirq_insn 
	.insn r CUSTOM_0, 0b000, 0b0000010, x0, x0, x0
.endm

.macro picorv32_maskirq_insn rd, rs1
	.insn r CUSTOM_0, 0b110, 0b0000011, \rd, \rs1, x0
.endm

.macro picorv32_waitirq_insn rd, rs1
	.insn r CUSTOM_0, 0b100, 0b0000100, \rd, x0, x0
.endm

.macro picorv32_timer_insn rd, rs1
	.insn r CUSTOM_0, 0b110, 0b0000101, \rd, \rs1, x0
.endm


