# Xilinx Vivado script
# Version: Vivado 2018.2
# Function:
#   Generate a vivado project for the rocketchip SoC on sakura X board

set bsp_dir 	 [lindex $argv 0]
set work_dir 	 [lindex $argv 1]
set project_name [lindex $argv 2]
set part		 [lindex $argv 3]

# Set the directory path for the original project from where this script was exported
set orig_proj_dir [file normalize $work_dir/$project_name]

# Create project
create_project $project_name $work_dir/$project_name

# Set the directory path for the new project
set proj_dir [get_property directory [current_project]]

# Set project properties
set obj [get_projects $project_name]
set_property "default_lib" "xil_defaultlib" $obj
set_property "PART" $part $obj 
set_property "simulator_language" "Mixed" $obj

# Create 'sources_1' fileset (if not found)
if {[string equal [get_filesets -quiet sources_1] ""]} {
  create_fileset -srcset sources_1
}

# Set 'sources_1' fileset object
set files [list]
set vfiles [glob -directory $bsp_dir/rtl/ *.v]
foreach item $vfiles {
	lappend files [file normalize $item]
}
add_files -norecurse -fileset [get_filesets sources_1] $files
add_files -norecurse -fileset [get_filesets sources_1] [file normalize $bsp_dir/board/sakura-x/sakura-x.v]
add_files -norecurse -fileset [get_filesets sources_1] [file normalize $bsp_dir/build/firmware.mem]

set_property verilog_define [list FPGA Differential_clock_capable_pin] [get_filesets sources_1] 

# Set 'sources_1' fileset properties
set_property "top" "sakura_x" [get_filesets sources_1]

# Clock generator
create_ip -name clk_wiz -vendor xilinx.com -library ip -version 6.0 -module_name clk_wiz_0
set_property -dict [list \
                        CONFIG.PRIMITIVE {MMCM} \
						CONFIG.PRIM_SOURCE {Differential_clock_capable_pin} \
						CONFIG.PRIM_IN_FREQ {200.000} \
						CONFIG.MMCM_COMPENSATION {ZHOLD} \
						CONFIG.MMCM_DIVCLK_DIVIDE {1} \
						CONFIG.RESET_TYPE {ACTIVE_HIGH} \
						CONFIG.RESET_PORT {reset} \
						CONFIG.CLKOUT1_DRIVES {BUFG} \
						CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {50.000}] \
    [get_ips clk_wiz_0]
generate_target {instantiation_template} [get_files $proj_dir/$project_name.srcs/sources_1/ip/clk_wiz_0_1/clk_wiz_0.xci]

# Create 'constrs_1' fileset (if not found)
if {[string equal [get_filesets -quiet constrs_1] ""]} {
  create_fileset -constrset constrs_1
}

# Set 'constrs_1' fileset object
set obj [get_filesets constrs_1]

# Add/Import constrs file and set constrs file properties
set file "[file normalize "$bsp_dir/board/sakura-x/sakura-x.xdc"]"
set file_added [add_files -norecurse -fileset $obj $file]

# generate all IP source code
generate_target all [get_ips]

# force create the synth_1 path (need to make soft link in Makefile)
launch_runs -scripts_only synth_1


# suppress some not very useful messages
# warning partial connection
set_msg_config -id "\[Synth 8-350\]" -suppress
# info do synthesis
set_msg_config -id "\[Synth 8-256\]" -suppress
set_msg_config -id "\[Synth 8-638\]" -suppress
# BRAM mapped to LUT due to optimization
set_msg_config -id "\[Synth 8-3969\]" -suppress
# BRAM with no output register
set_msg_config -id "\[Synth 8-4480\]" -suppress
# DSP without input pipelining
set_msg_config -id "\[Drc 23-20\]" -suppress
# Update IP version
set_msg_config -id "\[Netlist 29-345\]" -suppress


# do not flatten design
set_property STEPS.SYNTH_DESIGN.ARGS.FLATTEN_HIERARCHY none [get_runs synth_1]
