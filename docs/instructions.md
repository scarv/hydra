# RV32IM instruction composability

## Trivial Instructions

`AND[I], OR[I], XOR[I]`

Implemented: `ALL`

## 'Easy' Arithmetic Instructions

`ADD[I], SLT[I], SLT[I]U, SLL[I], SRL[I], SRA[I], SUB`

Implemented: `ADD[I], SUB, SLT[I]U`

## 'Hard' Arithmetic Instructions

`MUL, MULH, MULHS, MULHSU, DIV, DIVU, REM, REMU`

Implemented: `MUL, MULHU`

## Load/Store Instructions

`LW, LH[U], LB[U], SW, SH, SB`

Implemented: `LW, SW`

## Control Flow Instructions

`JAL, JALR, BEQ, BNE, BLT[U], BGE[U]`

Implemented: `JAL, JALR, BEQ, BNE, BLTU, BGEU`

## Other Instructions

`LUI, AUIPC`

Implemented: `NONE`
