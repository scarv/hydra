TOOLCHAIN_PREFIX = riscv32-unknown-elf-

FIRMWARE_DIR = src
RTL_DIR = rtl
BUILD_DIR = build

MEM_SIZE = 8192
STACK_SIZE = 256

icefun: $(BUILD_DIR)/icefun.bin

arty: $(BUILD_DIR)/arty.bit

## -------------------
## firmware generation

$(BUILD_DIR)/firmware.elf: $(FIRMWARE_DIR)/*.c $(FIRMWARE_DIR)/*.S $(FIRMWARE_DIR)/firmware.lds
	$(TOOLCHAIN_PREFIX)gcc \
		-march=rv32i -Os -ffreestanding -nostdlib -DMEM_SIZE=$(MEM_SIZE) -DSTACK_SIZE=$(STACK_SIZE) \
		-o $@ $(filter %.c, $^) $(filter %.S, $^) \
		--std=gnu99 -lgcc -Wl,-Bstatic,-T,$(FIRMWARE_DIR)/firmware.lds,--strip-debug
	chmod -x $@

$(BUILD_DIR)/firmware.bin: $(BUILD_DIR)/firmware.elf
	$(TOOLCHAIN_PREFIX)objcopy -O binary $< $@
	chmod -x $@

$(BUILD_DIR)/firmware.hex: $(BUILD_DIR)/firmware.bin
	python3 util/makehex.py $< 1792 > $@

## ------------------------------
## iceFUN flow: synth/p&r/bitstream

$(BUILD_DIR)/icefun.json: $(RTL_DIR)/*.v $(BUILD_DIR)/firmware.hex
	yosys -v3 -p 'synth_ice40 -top top -json $@' $(RTL_DIR)/icefun.v

$(BUILD_DIR)/icefun.asc: $(BUILD_DIR)/icefun.json $(RTL_DIR)/icefun.pcf
	nextpnr-ice40 --hx8k --package cb132 --json $< --pcf $(RTL_DIR)/icefun.pcf --asc $@

$(BUILD_DIR)/icefun.bin: $(BUILD_DIR)/icefun.asc
	icepack $< $@

## ------------------------------
## ARTY flow: synth/pack/place/route/fasm/bitstream

$(BUILD_DIR)/top.eblif: $(RTL_DIR)/*.v $(BUILD_DIR)/firmware.hex $(RTL_DIR)/arty.xdc
	cd build && symbiflow_synth -t top -v ../rtl/arty.v -d artix7 -p xc7a35tcsg324-1 -x ../$(RTL_DIR)/arty.xdc

$(BUILD_DIR)/top.net: $(BUILD_DIR)/top.eblif
	cd build && symbiflow_pack -e top.eblif -d xc7a50t_test

$(BUILD_DIR)/top.place: $(BUILD_DIR)/top.net
	cd build && symbiflow_place -e top.eblif -d xc7a50t_test -n top.net -P xc7a35tcsg324-1

$(BUILD_DIR)/top.route: $(BUILD_DIR)/top.place
	cd build && symbiflow_route -e top.eblif -d xc7a50t_test

$(BUILD_DIR)/top.fasm: $(BUILD_DIR)/top.route
	cd build && symbiflow_write_fasm -e top.eblif -d xc7a50t_test

$(BUILD_DIR)/arty.bit: $(BUILD_DIR)/top.fasm
	cd build && symbiflow_write_bitstream -d artix7 -f top.fasm -p xc7a35tcsg324-1 -b arty.bit

## ------
## el fin

clean:
	@cd $(BUILD_DIR) && rm -f *.bin *.hex *.elf *.asc *.json *.log *.rpt *.bit *.fasm *.v *.ilang *.net *.sdc *.eblif *.place *.ioplace *.route *.post_routing

.PHONY: clean
