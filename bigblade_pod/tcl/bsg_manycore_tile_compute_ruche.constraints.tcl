puts "BSG-info: Running script [info script]\n"

source -echo -verbose $constraints_dir/hb_design_constants.tcl

# core clk
set clk_name           ${manycore_clk_name}
set clk_period_ps      ${manycore_clk_period_ps}
set clk_uncertainty_ps ${manycore_clk_uncertainty_ps}
create_clock -period ${clk_period_ps} -name ${clk_name} [get_ports clk_i]
set_clock_uncertainty ${clk_uncertainty_ps} [get_clocks ${clk_name}]

set ruche_input_ports  [sort_collection [get_ports ruche_link_i*] name]
set ruche_output_ports [sort_collection [get_ports ruche_link_o*] name]


# input pins
set all_input_pins [remove_from_collection [all_inputs] [get_ports clk_i]]
set input_max_delay_ps [expr ${clk_period_ps}*0.70]
set input_min_delay_ps [expr ${clk_period_ps}*0.02]
set_input_delay -max ${input_max_delay_ps} -clock ${clk_name} ${all_input_pins}
set_input_delay -min ${input_min_delay_ps} -clock ${clk_name} ${all_input_pins}

# output pins
set all_output_pins [all_outputs]
set output_max_delay_ps [expr ${clk_period_ps}*0.20]
set output_min_delay_ps [expr ${clk_period_ps}*0.02]
set_output_delay -max ${output_max_delay_ps} -clock ${clk_name} ${all_output_pins}
set_output_delay -min ${output_min_delay_ps} -clock ${clk_name} ${all_output_pins}


# feedthrough input pins
set feedthrough_input_pins [index_collection $ruche_input_ports [expr 2*$HB_RUCHE_LINK_WIDTH_P] [expr (6*$HB_RUCHE_LINK_WIDTH_P)-1]]
set_dont_touch [get_nets -of_objects $feedthrough_input_pins] true


# input driving cell
set_driving_cell -min -no_design_rule -lib_cell "SC7P5T_INVX8_SSC14R" [all_inputs]
set_driving_cell -max -no_design_rule -lib_cell "SC7P5T_INVX2_SSC14R" [all_inputs]

# output load
set_load -max [load_of [get_lib_pin "*/SC7P5T_INVX8_SSC14R/A"]] [all_outputs]
set_load -min [load_of [get_lib_pin "*/SC7P5T_INVX2_SSC14R/A"]] [all_outputs]


# false path
set_case_analysis 0 [get_ports my_*]
set_case_analysis 0 [get_ports pod_*]

# derating
set cells_to_derate [list]
append_to_collection cells_to_derate [get_cells -quiet -hier -filter "ref_name=~gf14_*"]
append_to_collection cells_to_derate [get_cells -quiet -hier -filter "ref_name=~IN12LP_*"]

if { [sizeof $cells_to_derate] > 0 } {
  foreach_in_collection cell $cells_to_derate {
    set_timing_derate -cell_delay -early 0.97 $cell
    set_timing_derate -cell_delay -late  1.03 $cell
    set_timing_derate -cell_check -early 0.97 $cell
    set_timing_derate -cell_check -late  1.03 $cell
  }
}

# Ungroup
set_ungroup [get_designs -filter "hdl_template==bsg_manycore_reg_id_decode"] true
set_ungroup [get_designs -filter "hdl_template==bsg_manycore_endpoint"] true
set_ungroup [get_designs -filter "hdl_template==network_tx"] true
set_ungroup [get_designs -filter "hdl_template==network_rx"] true
set_ungroup [get_designs -filter "hdl_template==bsg_scan"] true
set_ungroup [get_designs -filter "hdl_template==reverse"] true
set_ungroup [get_designs -filter "hdl_template==bsg_manycore_lock_ctrl"] true
set_ungroup [get_designs -filter "hdl_template==recFNToRawFN"] true
set_ungroup [get_designs -filter "hdl_template==hash_function"] true
set_ungroup [get_designs -filter "hdl_template==bsg_transpose"] true
set_ungroup [get_designs -filter "hdl_template==bsg_concentrate_static"] true
set_ungroup [get_designs -filter "hdl_template==bsg_array_concentrate_static"] true
set_ungroup [get_designs -filter "hdl_template==bsg_unconcentrate_static"] true
set_ungroup [get_designs fpu_float_fma] false
set_ungroup [get_designs fpu_float_fma_round] false
ungroup [get_cells proc/h.z/vcore/fpu_int0/*] -flatten
ungroup [get_cells proc/h.z/vcore/fpu_float0/fma1/*] -flatten
ungroup [get_cells proc/h.z/vcore/fpu_float0/fma2/*] -flatten
ungroup [get_cells proc/h.z/vcore/fpu_float0/aux0/*] -flatten
ungroup [get_cells proc/h.z/vcore/fpu_fdiv_fsqrt0/*] -flatten
ungroup [get_cells proc/h.z/vcore/idiv0/*] -flatten

# Retiming
set_optimize_registers true -designs [get_designs fpu_float_fma] -check_design -verbose
set_optimize_registers true -designs [get_designs fpu_float_fma_round] -check_design -verbose

#set_app_var case_analysis_propagate_through_icg true
#update_timing

puts "BSG-info: Completed script [info script]\n"
