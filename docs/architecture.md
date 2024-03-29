# Architecture Description

## Diagram
![Architecture Diagram](architecture.png)


## Details
* One primary core and any number of secondary cores
* `mcompose` read/write CSR at address 0x7C0
    * Primary core can read and write to this register.
    * The value of the register is outputted by the primary core on the
      `mcompose` bus, which connects to the secondary cores.
    * The default value of `mcompose` is 0. In this state, all cores behave
      normally and execute instructions independentely.
    * The primary core can write a value `n` to `mcompose`. When this happens,
      it waits for `n` cores to be ready (including itself). A secondary core
      signals it is ready by writing any value to `mcompose`.

## Example

**Core #0 (primary core)** writes the value **3** to `mcompose`.
It then waits for the ready signal from core #1 to go high.

**Core #1 (secondary core)** then writes a value to `mcompose`. It is now ready,
but since `n` is **3** it still has to wait for the ready signal from Core #2.

**Core #2 (secondary core)** finally writes a value to `mcompose`. It is now
ready, so it raises its ready signal which propagates to Core #0.

All three cores are now composed and ready to execute.

When an instruction is fetched on the primary core, it outputs the instruction
to the secondary cores so they can execute it in parallel. Specifically,
it presents the instruction on the `mcompose_instr` bus and outputs a pulse on
`mcompose_exec`, triggering the other cores to execute that instruction. The
`left_carry` and `right_carry` buses between cores allow various signals to be
sent during instructions, allowing arithmetic, bit shifts and other such
operations to function correctly across the wide datapath.

After they are done, the primary core writes **0** to `mcompose`, causing
cores #1 and #2 to resume normal execution.
