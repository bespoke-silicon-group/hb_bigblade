set multicycle_cells [list]
append_to_collection multicycle_cells [get_cells sdr_x_*__sdr_n/dff_core_reset/data_r_reg_*]
append_to_collection multicycle_cells [get_cells sdr_x_*__sdr_n/dff_global_x/data_r_reg_*]
append_to_collection multicycle_cells [get_cells sdr_x_*__sdr_n/dff_global_y/data_r_reg_*]
set_multicycle_path 2 -setup -to   $multicycle_cells
set_multicycle_path 2 -hold  -to   $multicycle_cells
set_multicycle_path 2 -setup -from $multicycle_cells
set_multicycle_path 2 -hold  -from $multicycle_cells

