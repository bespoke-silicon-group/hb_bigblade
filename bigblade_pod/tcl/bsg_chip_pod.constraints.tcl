puts "BSG-info: Running script [info script]\n"


source -echo -verbose $constraints_dir/hb_design_constants.tcl

set clk_name           ${manycore_clk_name}
set clk_period_ps      ${manycore_clk_period_ps}
set clk_uncertainty_ps ${manycore_clk_uncertainty_ps}
create_clock -period ${clk_period_ps} -name ${clk_name} [get_ports clk_i]
set_clock_uncertainty ${clk_uncertainty_ps} [get_clocks ${clk_name}]


# input pins
set all_input_pins [list]
append_to_collection all_input_pins [get_ports reset_i]
append_to_collection all_input_pins [get_ports hor_link_sif_i*]
append_to_collection all_input_pins [get_ports ver_link_sif_i*]
append_to_collection all_input_pins [get_ports ruche_link_i*]
append_to_collection all_input_pins [get_ports north_wh_link_sif_i*]
append_to_collection all_input_pins [get_ports south_wh_link_sif_i*]
set input_delay_ps [expr ${clk_period_ps}*0.50]
set_driving_cell -no_design_rule -lib_cell "SC7P5T_INVX2_SSC14R" ${all_input_pins}
set_input_delay ${input_delay_ps} -clock ${clk_name} ${all_input_pins}


# output pins
set all_output_pins [list]
append_to_collection all_output_pins [get_ports hor_link_sif_o*]
append_to_collection all_output_pins [get_ports ver_link_sif_o*]
append_to_collection all_output_pins [get_ports ruche_link_o*]
append_to_collection all_output_pins [get_ports north_wh_link_sif_o*]
append_to_collection all_output_pins [get_ports south_wh_link_sif_o*]
set output_delay_ps [expr ${clk_period_ps}*0.50]
set_load [load_of [get_lib_pin */SC7P5T_INVX8_SSC14R/A]] ${all_output_pins}
set_output_delay ${output_delay_ps} -clock ${clk_name} ${all_output_pins}

# false path
set_false_path -from [get_ports north_vcache_pod*]
set_false_path -from [get_ports north_dest_wh_cord_i*]
set_false_path -from [get_ports south_vcache_pod*]
set_false_path -from [get_ports south_dest_wh_cord_i*]
set_false_path -from [get_ports pod_*]


# ungrouping
set_ungroup [get_cells "pod/mc/link"] true
set_ungroup [get_cells "pod/mc/rr*"] true
set_ungroup [get_cells "pod/north_vc_row/rc*"] true
set_ungroup [get_cells "pod/south_vc_row/rc*"] true
set_ungroup [get_cells "pod/north_vc_row"] true
set_ungroup [get_cells "pod/south_vc_row"] true
set_ungroup [get_cells "pod/mc"] true
set_ungroup [get_cells "pod"] true

# dont touch ruche buffers
set hard_inv_cells [get_cells -hier -filter "name=~*hard_inv*"]
set hard_buf_cells [get_cells -hier -filter "name=~*hard_buf*"]
set_dont_touch $hard_inv_cells true
set_dont_touch $hard_buf_cells true
set_dont_touch [get_nets -of [get_pins -of $hard_inv_cells -filter "name==A"]] true
set_dont_touch [get_nets -of [get_pins -of $hard_inv_cells -filter "name==Z"]] true
set_dont_touch [get_nets -of [get_pins -of $hard_buf_cells -filter "name==A"]] true
set_dont_touch [get_nets -of [get_pins -of $hard_buf_cells -filter "name==Z"]] true
set_dont_touch [get_nets -of [get_pins "pod/mc/*tile/ruche_link_*"]] true
set_dont_touch [get_nets -of [get_pins "pod/north_vc_row/*vc/wh_link_sif_*"]] true
set_dont_touch [get_nets -of [get_pins "pod/south_vc_row/*vc/wh_link_sif_*"]] true
set_dont_touch [get_nets -of [get_ports "north_wh_link_sif_*"]] true
set_dont_touch [get_nets -of [get_ports "south_wh_link_sif_*"]] true
set_dont_touch [get_nets -of [get_ports "ruche_link_*"]] true


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
