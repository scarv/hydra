# HYDRA
HYDRA: multi-core RISC-V with cryptographically interesting modes of operation

A RISC-V toolchain installation capable of compiling for RV32IM is required. The
path to the toolchain can be configured with the `TOOLCHAIN_PREFIX` variable at
the top of the Makefile. To build for the iceFUN board using Icestorm, run
`make icefun`. To try the experimental Symbiflow target for the Arty board, run
`make arty`.

To use the Icarus Verilog simulation testbench, run `make simulate`. To lint the
Verilog code with Verilator, use `make lint`.
