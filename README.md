# HYDRA
HYDRA: multi-core RISC-V with cryptographically interesting modes of operation

## Organisation

```
├── bin                - scripts (e.g., environment configuration)
├── board              - the flows to implement the SoC system on specific supported boards: sakura-x, arty, iceFUN
├── docs               - consists of figures and other documents
├── rtl                - Verilog rtl code of HYDRA SoC system
├── src                - C code of firmware to test and evaluate the system
└── build              - working directory for build

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
    source $VIVADO_TOOL_DIR/settings64.sh
    ```

- Build and simulate the evalutation firmware using iverilog testbench

  ```sh
  make simulate
  ```

  Or

  ```sh
  make simulate-hwdebug
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
  make firmware
  make bit-update
  make update-program
  ```

## References


## Acknowledgements

This work has been supported in part
by EPSRC via grant
[EP/R012288/1](https://gow.epsrc.ukri.org/NGBOViewGrant.aspx?GrantRef=EP/R012288/1) (under the [RISE](http://www.ukrise.org) programme).
