# HYDRA
HYDRA: multi-core RISC-V with cryptographically interesting modes of operation

Multi-core processor designs often represent an efficient, flexible solution for general-purpose workloads.
Based on the premise that multi-core processors are generally viable as an implementation platform for cryptography, 
this work investigates specific instances dubbed HYDRA which harness the concept of Composable Lightweight Processors to support
three cryptographically useful composition modes, namely, Redundant, Simd, and Widen data-path.
So, HYDRA can also operate in the modes specifically designed to address domain-specific challenges relating to efficiency and security.

The Repo. contains the source code of a framework to implement and evaluate the supporting modes in a RISC-V based proof-of-concept 
while retaining characteristics which stem from a generic multi-core design.


## Organisation

```
├── bin                - scripts (e.g., environment configuration)
├── board              - the flows to implement the SoC system on specific supported boards: sakura-x, arty, iceFUN
├── build              - working directory for build
├── docs               - consists of figures and other documents
├── rtl                - Verilog rtl code of HYDRA SoC system
└── src                - ASM/C code of software to test and evaluate the HYDRA system
    ├── hal                - source code for SoC hardware abstract layer
    ├── redundant          - source code for AES encryption run in the HYDRA redundant mode
    ├── simd               - source code for ChaCha20 encryption run in the HYDRA Simd mode
    └── wide_data          - source code for multi-precision algorithms run in the HYDRA widen data-path mode
```

<!--- -------------------------------------------------------------------- --->

## Quickstart

- For seting up the repository

  - Clone the repository and setup environment 
  
    ```sh
    git clone https://github.com/scarv/hydra ./hydra
    cd ./hydra
    source bin/conf.sh
    ```

  - Fix paths for the RV32IM RISCV toolchains, Iverilog root and Vivado Tool, e.g.,
  
    ```sh
    export RISCV=/opt/riscv
    export PATH=/opt/iverilog/build/bin:$PATH
    export VIVADO_TOOL_DIR=/opt/Xilinx/Vivado/2018.2
    source $VIVADO_TOOL_DIR/settings64.sh    ```

- Run a software, e.g., multi-precision algorithms (in the wide_data mode), or ChaCha20 (in the SIMD mode) on HYDRA to evaluate the performance on a FPGA platform:

  - 
  ```sh
  SW=[wide_data/simd] make firmware
  ```
 
  - Build the system on FPGA using Sakura-x, and generate bitstream

  ```sh
  make sakura-x
  ```

  - Program the bitstream on Sakura-x

  ```sh
  make program-sakura-x
  ```

  - Open another terminal to observe the result

  ```sh
  microcom -p /dev/ttyUSB0 -s 9600
  ```

- For software development and debug avoiding FPGA re-implementation process, compile and update firmware for FPGA as belows:

  ```sh
  SW=[wide_data/simd] make -B firmware
  make bit-update
  make update-program
  ```

- Evaluate the fault detection in the redundant mode of HYDRA using the iverilog simulation.

  - Compile and run unprotected AES encryption under the PC-fault injection attack
  ```sh
  SW=redundant ACT="-DPC_FAULT_INJ" make -B simulate
  ```

  Or compile and run unprotected AES encryption under the data-fault injection attack 
  ```sh
  SW=redundant ACT="-DREG_FAULT_INJ" make -B simulate
  ```

  - Compile and run protected AES encryption on the HYDRA, configured with the redundant mode, under the PC/data-fault injection attacks 
  ```sh
  SW=redundant MODE=PROTECTED ACT="-D[PC_FAULT_INJ/REG_FAULT_INJ]" make -B simulate
  ```

## References


## Acknowledgements

This work has been supported in part
by EPSRC via grant
[EP/R012288/1](https://gow.epsrc.ukri.org/NGBOViewGrant.aspx?GrantRef=EP/R012288/1) (under the [RISE](http://www.ukrise.org) programme).
