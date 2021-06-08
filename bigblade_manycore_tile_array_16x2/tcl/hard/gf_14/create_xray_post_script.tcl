if { [sizeof [get_lib_cells */* -filter "is_memory_cell"]] > 0 } {
  set_timing_derate -cell_delay -early 0.97 [get_lib_cells */* -filter "is_memory_cell"]
  set_timing_derate -cell_delay -late  1.03 [get_lib_cells */* -filter "is_memory_cell"]
  set_timing_derate -cell_check -early 0.97 [get_lib_cells */* -filter "is_memory_cell"]
  set_timing_derate -cell_check -late  1.03 [get_lib_cells */* -filter "is_memory_cell"]
}

report_timing_derate


set multicycle_cells [list]
append_to_collection multicycle_cells [get_cells y_*__x_*__tile/dff_x/data_r_reg_*]
append_to_collection multicycle_cells [get_cells y_*__x_*__tile/dff_y/data_r_reg_*]
set_multicycle_path 2 -setup -to   $multicycle_cells
set_multicycle_path 2 -hold  -to   $multicycle_cells
set_multicycle_path 2 -setup -from $multicycle_cells
set_multicycle_path 2 -hold  -from $multicycle_cells
