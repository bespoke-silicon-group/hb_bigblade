puts "BSG-info: Running script [info script]\n"

source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_common_variables.tcl

#remove_buffers [get_cells FTB*]
for {set i [expr 2*$HB_RUCHE_LINK_WIDTH_P]} {$i < [expr 2*$HB_RUCHE_FACTOR_P*$HB_RUCHE_LINK_WIDTH_P]} {incr i} {
  set_dont_touch [get_nets "ruche_link_i[${i}]"] true
}

if { [sizeof [get_lib_cells */* -filter "is_memory_cell"]] > 0 } {
  set_timing_derate -cell_delay -early 0.97 [get_lib_cells */* -filter "is_memory_cell"]
  set_timing_derate -cell_delay -late  1.03 [get_lib_cells */* -filter "is_memory_cell"]
  set_timing_derate -cell_check -early 0.97 [get_lib_cells */* -filter "is_memory_cell"]
  set_timing_derate -cell_check -late  1.03 [get_lib_cells */* -filter "is_memory_cell"]
}

report_timing_derate


puts "BSG-info: Completed script [info script]\n"
