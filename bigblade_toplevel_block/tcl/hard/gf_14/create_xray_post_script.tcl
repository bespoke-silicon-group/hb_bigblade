
source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/bsg_chip_misc.tcl

#remove_clocks [get_clocks {ext_io_clk ext_noc_clk ext_mc_clk*}]


set io_clk_period_ps          800.0 ;# 1.25 GHz
set io_clk_uncertainty_ps     20

for {set i 0} {$i < 8} {incr i} {
  for {set j 0} {$j < 2} {incr j} {
    set io_clk_name   "mem_link_${i}_${j}_io_clk"
    create_clock -period $io_clk_period_ps -name $io_clk_name [get_pins "mem_link*${i}*link/ddr_link*${j}*link/clk_gen_io/clk_gen_inst/mux_inst/*/Z"]
    set_clock_uncertainty $io_clk_uncertainty_ps  [get_clocks $io_clk_name]
    set_propagated_clock [get_clocks $io_clk_name]
    set_case_analysis 0 [get_pins "mem_link*${i}*link/ddr_link*${j}*delay/sig*mux*/S*"]
  }
}

for {set j 0} {$j < 2} {incr j} {
  set io_clk_name   "io_link_${j}_io_clk"
  create_clock -period $io_clk_period_ps -name $io_clk_name [get_pins "io_link/ddr_link*${j}*link/clk_gen_io/clk_gen_inst/mux_inst/*/Z"]
  set_clock_uncertainty $io_clk_uncertainty_ps  [get_clocks $io_clk_name]
  set_propagated_clock [get_clocks $io_clk_name]
  set_case_analysis 0 [get_pins "io_link/ddr_link*${j}*delay/sig*mux*/S*"]
}

for {set i 0} {$i < 8} {incr i} {
  set wh_master_clk_name   "mem_link_${i}_master_clk"
  create_clock -period 1000 -name $wh_master_clk_name [get_pins "mem_link*${i}*link/ddr_link*0*link/clk_gen_noc/clk_gen_inst/mux_inst/*/Z"]
  set_clock_uncertainty 20 [get_clocks $wh_master_clk_name]
  set_propagated_clock [get_clocks $wh_master_clk_name]
}

set wh_master_clk_name   "io_link_master_clk"
create_clock -period 1000 -name $wh_master_clk_name [get_pins "io_link/ddr_link*0*link/clk_gen_noc/clk_gen_inst/mux_inst/*/Z"]
set_clock_uncertainty 20 [get_clocks $wh_master_clk_name]
set_propagated_clock [get_clocks $wh_master_clk_name]



#bsg_chip_derate_cells

foreach_in_collection cell [get_cells "mem_link*link/ddr_link*link/downlink/*downstream/*harden*fifo/*hardened*/*mem*/*macro*mem"] {
  set_disable_timing $cell -from CLKA -to CLKB
  set_disable_timing $cell -from CLKB -to CLKA
}
foreach_in_collection cell [get_cells "io_link/ddr_link*link/downlink/*downstream/*harden*fifo/*hardened*/*mem*/*macro*mem"] {
  set_disable_timing $cell -from CLKA -to CLKB
  set_disable_timing $cell -from CLKB -to CLKA
}
foreach_in_collection cell [get_cells "io_link/tunnel/bcti/b1_ntf/*buff*fifo/*hardened*/*mem*/*macro*mem"] {
  set_disable_timing $cell -from CLKA -to CLKB
  set_disable_timing $cell -from CLKB -to CLKA
}

if { [sizeof [get_lib_cells */* -filter "is_memory_cell"]] > 0 } {
  set_timing_derate -cell_delay -early 0.97 [get_lib_cells */* -filter "is_memory_cell"]
  set_timing_derate -cell_delay -late  1.03 [get_lib_cells */* -filter "is_memory_cell"]
  set_timing_derate -cell_check -early 0.97 [get_lib_cells */* -filter "is_memory_cell"]
  set_timing_derate -cell_check -late  1.03 [get_lib_cells */* -filter "is_memory_cell"]
}



# multicycle cells
set multicycle_cells [list]
# manycore_tiles
append_to_collection multicycle_cells [get_cells core_complex_core_*__podrow/podrow/px_*__pod/*_vc_x_0__*_vc_row/vc_y_0__vc_x_*__vc/x_dff/data_r_reg_*]
append_to_collection multicycle_cells [get_cells core_complex_core_*__podrow/podrow/px_*__pod/*_vc_x_0__*_vc_row/vc_y_0__vc_x_*__vc/y_dff/data_r_reg_*]
# vcache
append_to_collection multicycle_cells [get_cells core_complex_core_*__podrow/podrow/px_*__pod/mc_y_*__mc_x_0__mc/y_*__x_*__tile/dff_x/data_r_reg_*]
append_to_collection multicycle_cells [get_cells core_complex_core_*__podrow/podrow/px_*__pod/mc_y_*__mc_x_0__mc/y_*__x_*__tile/dff_y/data_r_reg_*]
# sdr north
append_to_collection multicycle_cells [get_cells core_complex_core_*__podrow/sdr_n_x_*__sdr_n/sdr_x_*__sdr_n/dff_global_x/data_r_reg_*]
append_to_collection multicycle_cells [get_cells core_complex_core_*__podrow/sdr_n_x_*__sdr_n/sdr_x_*__sdr_n/dff_global_y/data_r_reg_*]
# sdr corner
append_to_collection multicycle_cells [get_cells core_complex_core_*__podrow/sdr_nw/dff_global_x/data_r_reg*]
append_to_collection multicycle_cells [get_cells core_complex_core_*__podrow/sdr_nw/dff_global_y/data_r_reg*]
append_to_collection multicycle_cells [get_cells core_complex_core_*__podrow/sdr_ne/dff_global_x/data_r_reg*]
append_to_collection multicycle_cells [get_cells core_complex_core_*__podrow/sdr_ne/dff_global_y/data_r_reg*]
append_to_collection multicycle_cells [get_cells core_complex_core_*__podrow/sdr_sw/dff_global_x/data_r_reg*]
append_to_collection multicycle_cells [get_cells core_complex_core_*__podrow/sdr_sw/dff_global_y/data_r_reg*]
append_to_collection multicycle_cells [get_cells core_complex_core_*__podrow/sdr_se/dff_global_x/data_r_reg*]
append_to_collection multicycle_cells [get_cells core_complex_core_*__podrow/sdr_se/dff_global_y/data_r_reg*]
# sdr_west east
append_to_collection multicycle_cells [get_cells core_complex_core_*__podrow/sdr_*_y_*__sdr_*/dff_global_x/data_r_reg*]
append_to_collection multicycle_cells [get_cells core_complex_core_*__podrow/sdr_*_y_*__sdr_*/dff_global_y/data_r_reg*]




set_multicycle_path 2 -setup -to   $multicycle_cells
set_multicycle_path 2 -hold  -to   $multicycle_cells
set_multicycle_path 2 -setup -from $multicycle_cells
set_multicycle_path 2 -hold  -from $multicycle_cells


