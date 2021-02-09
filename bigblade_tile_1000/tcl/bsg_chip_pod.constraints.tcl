puts "BSG-info: Running script [info script]\n"

source -echo -verbose $constraints_dir/hb_design_constants.tcl
source -echo -verbose $constraints_dir/bsg_async.constraints.tcl

# core clk
create_clock -period ${manycore_clk_period_ps} -name ${manycore_clk_name} [get_ports clk_i]
set_clock_uncertainty ${manycore_clk_uncertainty_ps} [get_clocks ${manycore_clk_name}]

# tag clk
set tag_clock_pins [list]
append_to_collection tag_clock_pins [get_ports "north_bsg_tag_i\[clk\]"]
append_to_collection tag_clock_pins [get_ports "south_bsg_tag_i\[clk\]"]
create_clock -period ${tag_clk_period_ps} -name ${tag_clk_name} $tag_clock_pins
set_clock_uncertainty ${tag_clk_uncertainty_ps} [get_clocks ${tag_clk_name}]

# tag input pins
set tag_input_pins [list]
append_to_collection tag_input_pins [get_ports "north_bsg_tag_i\[op\]"]
append_to_collection tag_input_pins [get_ports "north_bsg_tag_i\[param\]"]
append_to_collection tag_input_pins [get_ports "north_bsg_tag_i\[en\]"]
append_to_collection tag_input_pins [get_ports "south_bsg_tag_i\[op\]"]
append_to_collection tag_input_pins [get_ports "south_bsg_tag_i\[param\]"]
append_to_collection tag_input_pins [get_ports "south_bsg_tag_i\[en\]"]
set input_min_delay_ps [expr ${tag_clk_period_ps}*0.02]
set input_max_delay_ps [expr ${tag_clk_period_ps}*0.50]
set_input_delay -min ${input_min_delay_ps} -clock ${tag_clk_name} ${tag_input_pins}
set_input_delay -max ${input_max_delay_ps} -clock ${tag_clk_name} ${tag_input_pins}

# input pins
set all_input_pins [list]
append_to_collection all_input_pins [get_ports hor_link_sif_i*]
append_to_collection all_input_pins [get_ports ver_link_sif_i*]
append_to_collection all_input_pins [get_ports ruche_link_i*]
append_to_collection all_input_pins [get_ports north_wh_link_sif_i*]
append_to_collection all_input_pins [get_ports south_wh_link_sif_i*]
append_to_collection all_input_pins [get_ports north_vcache_pod*]
append_to_collection all_input_pins [get_ports south_vcache_pod*]
append_to_collection all_input_pins [get_ports pod*]
set input_min_delay_ps [expr ${manycore_clk_period_ps}*0.02]
set input_max_delay_ps [expr ${manycore_clk_period_ps}*0.50]
set_input_delay -min ${input_min_delay_ps} -clock ${manycore_clk_name} ${all_input_pins}
set_input_delay -max ${input_max_delay_ps} -clock ${manycore_clk_name} ${all_input_pins}


# output pins
set all_output_pins [list]
append_to_collection all_output_pins [get_ports hor_link_sif_o*]
append_to_collection all_output_pins [get_ports ver_link_sif_o*]
append_to_collection all_output_pins [get_ports ruche_link_o*]
append_to_collection all_output_pins [get_ports north_wh_link_sif_o*]
append_to_collection all_output_pins [get_ports south_wh_link_sif_o*]
set output_min_delay_ps [expr ${manycore_clk_period_ps}*0.02]
set output_max_delay_ps [expr ${manycore_clk_period_ps}*0.50]
set_output_delay -min ${output_min_delay_ps} -clock ${manycore_clk_name} ${all_output_pins}
set_output_delay -max ${output_max_delay_ps} -clock ${manycore_clk_name} ${all_output_pins}


# driver
set_driving_cell -min -no_design_rule -lib_cell "SC7P5T_INVX8_SSC14R" [all_inputs]
set_driving_cell -max -no_design_rule -lib_cell "SC7P5T_INVX1_SSC14R" [all_inputs]

# load
set_load -min [load_of [get_lib_pin */SC7P5T_INVX1_SSC14R/A]] [all_outputs]
set_load -max [load_of [get_lib_pin */SC7P5T_INVX8_SSC14R/A]] [all_outputs]


# async paths
set clocks [list]
append_to_collection clocks [get_clock ${manycore_clk_name}]
append_to_collection clocks [get_clock ${tag_clk_name}]
bsg_async_icl $clocks


# false path
set_case_analysis 0 [get_ports north_vcache_pod*]
set_case_analysis 0 [get_ports south_vcache_pod*]
set_case_analysis 0 [get_ports pod_*]

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

#set_app_var case_analysis_propagate_through_icg true 
#update_timing




puts "BSG-info: Completed script [info script]\n"
