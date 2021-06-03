


# multicycle cells
set multicycle_cells [list]
# manycore_tiles
append_to_collection multicycle_cells [get_cells podrow/px_*__pod/*_vc_x_0__*_vc_row/vc_y_0__vc_x_*__vc/x_dff/data_r_reg_*]
append_to_collection multicycle_cells [get_cells podrow/px_*__pod/*_vc_x_0__*_vc_row/vc_y_0__vc_x_*__vc/y_dff/data_r_reg_*]
# vcache
append_to_collection multicycle_cells [get_cells podrow/px_*__pod/mc_y_*__mc_x_0__mc/y_*__x_*__tile/dff_x/data_r_reg_*]
append_to_collection multicycle_cells [get_cells podrow/px_*__pod/mc_y_*__mc_x_0__mc/y_*__x_*__tile/dff_y/data_r_reg_*]
# sdr north
append_to_collection multicycle_cells [get_cells sdr_n_x_*__sdr_n/sdr_x_*__sdr_n/dff_global_x/data_r_reg_*]
append_to_collection multicycle_cells [get_cells sdr_n_x_*__sdr_n/sdr_x_*__sdr_n/dff_global_y/data_r_reg_*]
# sdr corner
append_to_collection multicycle_cells [get_cells sdr_nw/dff_global_x/data_r_reg*]
append_to_collection multicycle_cells [get_cells sdr_nw/dff_global_y/data_r_reg*]
append_to_collection multicycle_cells [get_cells sdr_ne/dff_global_x/data_r_reg*]
append_to_collection multicycle_cells [get_cells sdr_ne/dff_global_y/data_r_reg*]
append_to_collection multicycle_cells [get_cells sdr_sw/dff_global_x/data_r_reg*]
append_to_collection multicycle_cells [get_cells sdr_sw/dff_global_y/data_r_reg*]
append_to_collection multicycle_cells [get_cells sdr_se/dff_global_x/data_r_reg*]
append_to_collection multicycle_cells [get_cells sdr_se/dff_global_y/data_r_reg*]
# sdr_west east
append_to_collection multicycle_cells [get_cells sdr_*_y_*__sdr_*/dff_global_x/data_r_reg*]
append_to_collection multicycle_cells [get_cells sdr_*_y_*__sdr_*/dff_global_y/data_r_reg*]




set_multicycle_path 2 -setup -to   $multicycle_cells
set_multicycle_path 2 -hold  -to   $multicycle_cells
set_multicycle_path 2 -setup -from $multicycle_cells
set_multicycle_path 2 -hold  -from $multicycle_cells




# derating
if { [sizeof [get_lib_cells */* -filter "is_memory_cell"]] > 0 } {
  set_timing_derate -cell_delay -early 0.97 [get_lib_cells */* -filter "is_memory_cell"]
  set_timing_derate -cell_delay -late  1.03 [get_lib_cells */* -filter "is_memory_cell"]
  set_timing_derate -cell_check -early 0.97 [get_lib_cells */* -filter "is_memory_cell"]
  set_timing_derate -cell_check -late  1.03 [get_lib_cells */* -filter "is_memory_cell"]
}

report_timing_derate

