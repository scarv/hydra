# Copyright (C) 2019 SCARV project <info@scarv.org>
#
# Use of this source code is restricted per the MIT license, a copy of which
# can be found at https://opensource.org/licenses/MIT (or should be included
# as LICENSE.txt within the associated archive or repository).

BUILD_DIR = ${REPO_HOME}/build
BOARD_DIR = ${REPO_HOME}/board
FIRMWARE_DIR = ${REPO_HOME}/src
RTL_DIR = ${REPO_HOME}/rtl


MEM_SIZE = 65536
STACK_SIZE = 4096
RTL = $(wildcard ${RTL_DIR}/*.v)

include ${REPO_HOME}/src/Makefile.in
include ${REPO_HOME}/board/icefun/Makefile.in
include ${REPO_HOME}/board/arty/Makefile.in
include ${REPO_HOME}/board/sakura-x/Makefile.in
## ------------------------------
## linting: verilator
lint:
	verilator -I$(RTL_DIR) -Wall --lint-only --top-module top $(RTL_DIR)/soc.v

icefun: $(BUILD_DIR)/icefun.bin

arty: $(BUILD_DIR)/arty.bit

sakura-x: $(sakura-x-bitstream) 

simulate: $(BUILD_DIR)/firmware.mem
	iverilog -g2005-sv -I $(RTL_DIR) $(RTL) && ./a.out && rm a.out

## ------
## el fin

clean:
	@cd $(BUILD_DIR) && rm -f *.*

.PHONY: clean simulate
