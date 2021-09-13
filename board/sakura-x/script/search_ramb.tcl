#set origin_dir "."
set project_name [lindex $argv 0]
set work_dir [lindex $argv 1]
set orig_proj_dir [file normalize $work_dir/$project_name]

# open project
open_project $orig_proj_dir/$project_name.xpr

# open implemented design
open_run impl_1

# search for all RAMB blocks
foreach m [get_cells composed_soc/memory_reg_*] { put $m; report_property $m {LOC} }

