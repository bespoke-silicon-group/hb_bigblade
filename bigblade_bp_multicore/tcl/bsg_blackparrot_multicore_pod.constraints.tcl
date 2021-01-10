puts "BSG-info: Running script [info script]\n"

set input_delay_per  20.0
set output_delay_per 20.0

set bp_input_delay_ps  [expr ${bp_clk_period_ps}*(${input_delay_per}/100.0)]
set bp_output_delay_ps [expr ${bp_clk_period_ps}*(${output_delay_per}/100.0)]

set mc_input_delay_ps  [expr ${mc_clk_period_ps}*(${input_delay_per}/100.0)]
set mc_output_delay_ps [expr ${mc_clk_period_ps}*(${output_delay_per}/100.0)]

set driving_lib_cell "SC7P5T_INVX2_SSC14R"
set load_lib_pin     "SC7P5T_INVX8_SSC14R/A"

# Reg2Reg
create_clock -period ${bp_clk_period_ps} -name ${bp_clk_name} [get_ports "bp_clk_i"]
set_clock_uncertainty ${bp_clk_uncertainty_ps} [get_clocks ${bp_clk_name}]

create_clock -period ${mc_clk_period_ps} -name ${mc_clk_name} [get_ports "mc_clk_i"]
set_clock_uncertainty ${mc_clk_uncertainty_ps} [get_clocks ${mc_clk_name}]

# In2Reg
set bp_input_pins [filter_collection [filter_collection [all_inputs] "name!~*clk*"] "name=~bp*"]
set mc_input_pins [filter_collection [filter_collection [all_inputs] "name!~*clk*"] "name=~mc*"]
set false_input_pins [filter_collection [filter_collection [all_inputs] "name!~*clk*"] "name=~my*"]
set_driving_cell -no_design_rule -lib_cell ${driving_lib_cell} [remove_from_collection [all_inputs] [get_ports *clk*]]
set_input_delay ${bp_input_delay_ps} -clock ${bp_clk_name} ${bp_input_pins}
set_input_delay ${mc_input_delay_ps} -clock ${mc_clk_name} ${mc_input_pins}
set_input_delay ${bp_input_delay_ps} -clock ${bp_clk_name} ${false_input_pins}

# Reg2Out
set bp_output_pins [filter_collection [all_outputs] "name=~bp*"]
set mc_output_pins [filter_collection [all_outputs] "name=~mc*"]
set_load [load_of [get_lib_pin */${load_lib_pin}]] ${bp_output_pins}
set_load [load_of [get_lib_pin */${load_lib_pin}]] ${mc_output_pins}
set_output_delay ${bp_output_delay_ps} -clock ${bp_clk_name} ${bp_output_pins}
set_output_delay ${mc_output_delay_ps} -clock ${mc_clk_name} ${mc_output_pins}

set_false_path -from [get_ports my_*]

# Derate
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
#report_timing_derate

# Retiming
set_app_var compile_keep_original_for_external_references true
set_app_var case_analysis_propagate_through_icg true

puts "BSG-info: Completed script [info script]\n"
