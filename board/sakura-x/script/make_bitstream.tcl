#set origin_dir "."
set project_name [lindex $argv 0]
set work_dir [lindex $argv 1]
set orig_proj_dir [file normalize $work_dir/$project_name]

# open project
open_project $orig_proj_dir/$project_name.xpr

# suppress some not very useful messages
# IP flow regeneration
set_msg_config -id "\[IP_Flow 19-3664\]" -suppress

# reset runs
reset_run synth_1
reset_run impl_1

# run syntesis
launch_runs synth_1
wait_on_run synth_1

# run imp
launch_runs impl_1 -to_step write_bitstream
wait_on_run impl_1

#open_run impl_1
#write_mem_info design1.mmi
