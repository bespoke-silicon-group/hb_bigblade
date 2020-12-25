puts "BSG-info: Running script [info script]\n"


source -echo -verbose $constraints_dir/hb_design_constants.tcl

# core clk
set clk_name           ${manycore_clk_name}
set clk_period_ps      ${manycore_clk_period_ps}
set clk_uncertainty_ps ${manycore_clk_uncertainty_ps}
create_clock -period ${clk_period_ps} -name ${clk_name} [get_ports clk_i]
set_clock_uncertainty ${clk_uncertainty_ps} [get_clocks ${clk_name}]


set ruche_input_ports  [sort_collection [get_ports wh_link_sif_i*] name]
set ruche_output_ports [sort_collection [get_ports wh_link_sif_o*] name]


# input pins
set all_input_pins [list]
append_to_collection all_input_pins [get_ports reset_i]
append_to_collection all_input_pins [get_ports ver_link_sif_i*]
append_to_collection all_input_pins [index_collection $ruche_input_ports 0 [expr ($HB_WH_LINK_WIDTH_P*2)-1]]
set input_delay_ps [expr ${clk_period_ps}*0.50]
set_driving_cell -no_design_rule -lib_cell "SC7P5T_INVX2_SSC14R" ${all_input_pins}
set_input_delay ${input_delay_ps} -clock ${clk_name} ${all_input_pins}


# output pins
set all_output_pins [list]
append_to_collection all_output_pins [get_ports ver_link_sif_o*]
append_to_collection all_output_pins [index_collection $ruche_output_ports 0 [expr ($HB_WH_LINK_WIDTH_P*2)-1]]
set output_delay_ps [expr ${clk_period_ps}*0.50]
set_load [load_of [get_lib_pin */SC7P5T_INVX8_SSC14R/A]] ${all_output_pins}
set_output_delay ${output_delay_ps} -clock ${clk_name} ${all_output_pins}


# input feedthrough pins
set feedthrough_input_pins [index_collection $ruche_input_ports [expr 2*$HB_WH_LINK_WIDTH_P] [expr (4*$HB_WH_LINK_WIDTH_P)-1]]
set_driving_cell -no_design_rule -lib_cell "SC7P5T_INVX2_SSC14R" ${feedthrough_input_pins}
set_input_delay 10.0 -clock ${clk_name} ${feedthrough_input_pins}
set_dont_touch [get_nets -of_objects $feedthrough_input_pins] true


# feedthrough output pins
set feedthrough_output_pins [index_collection $ruche_output_ports [expr 2*$HB_WH_LINK_WIDTH_P] [expr (4*$HB_WH_LINK_WIDTH_P)-1]]
set_load [load_of [get_lib_pin */SC7P5T_INVX8_SSC14R/A]] ${feedthrough_output_pins}
set_output_delay 10.0 -clock ${clk_name} ${feedthrough_output_pins}


# false path
set_false_path -from [get_ports global_*]
set_false_path -from [get_ports my_wh_cord_i*]
set_false_path -from [get_ports my_wh_cid_i*]
set_false_path -from [get_ports dest_wh_cord_i*]


# ungrouping
set_ungroup [get_designs -filter "hdl_template==bsg_mux"] true
set_ungroup [get_designs -filter "hdl_template==bsg_decode"] true
set_ungroup [get_designs -filter "hdl_template==bsg_mux_segmented"] true
set_ungroup [get_designs -filter "hdl_template==bsg_mux_one_hot"] true
set_ungroup [get_designs -filter "hdl_template==bsg_scan"] true
set_ungroup [get_designs -filter "hdl_template==bsg_expand_bitmask"] true
set_ungroup [get_designs -filter "hdl_template==bsg_manycore_endpoint"] true
set_ungroup [get_designs -filter "hdl_template==bsg_transpose"] true
set_ungroup [get_designs -filter "hdl_template==bsg_concentrate_static"] true
set_ungroup [get_designs -filter "hdl_template==bsg_array_concentrate_static"] true
set_ungroup [get_designs -filter "hdl_template==bsg_unconcentrate_static"] true


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

puts "BSG-info: Completed script [info script]\n"
