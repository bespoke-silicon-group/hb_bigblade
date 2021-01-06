########################################
##
## Clock Setup
##

set bp_clk_name "bp_clk" ;# main clock running black parrot
set mc_clk_name "mc_clk" ;# clock for the manycore

set bp_clk_period_ps       2000
set bp_clk_uncertainty_per 3.0
set bp_clk_uncertainty_ps  [expr min([expr ${bp_clk_period_ps}*(${bp_clk_uncertainty_per}/100.0)], 20)]

set mc_clk_period_ps       2000
set mc_clk_uncertainty_per 3.0
set mc_clk_uncertainty_ps  [expr min([expr ${bp_clk_period_ps}*(${bp_clk_uncertainty_per}/100.0)], 20)]

set bp_clk_name           ${bp_clk_name}
set bp_clk_period_ps      ${bp_clk_period_ps}
set bp_clk_uncertainty_ps ${bp_clk_uncertainty_ps}

set input_delay_per  50.0
set output_delay_per 50.0

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
set_driving_cell -no_design_rule -lib_cell ${driving_lib_cell} [remove_from_collection [all_inputs] [get_ports *clk*]]
set_input_delay ${bp_input_delay_ps} -clock ${bp_clk_name} ${bp_input_pins}
set_input_delay ${mc_input_delay_ps} -clock ${mc_clk_name} ${mc_input_pins}

# Reg2Out
#set bp_output_pins [filter_collection [all_outputs] "name=~bp*"]
set mc_output_pins [filter_collection [all_outputs] "name=~mc*"]
#set_load [load_of [get_lib_pin */${load_lib_pin}]] ${bp_output_pins}
set_load [load_of [get_lib_pin */${load_lib_pin}]] ${mc_output_pins}
#set_output_delay ${bp_output_delay_ps} -clock ${bp_clk_name} ${bp_output_pins}
set_output_delay ${mc_output_delay_ps} -clock ${mc_clk_name} ${mc_output_pins}

# This timing assertion for the RF is only valid in designs that do not do simultaneous read and write to the same address,
# or do not use the read value when it writes
# Check your ram generator to see what it permits
foreach_in_collection cell [filter_collection [all_macro_cells] "full_name=~*_regfile*rf*"] {
  set_disable_timing $cell -from CLKA -to CLKB
  set_disable_timing $cell -from CLKB -to CLKA
}

foreach_in_collection cell [filter_collection [all_macro_cells] "full_name=~*btb*tag_mem*"] {
  set_disable_timing $cell -from CLKA -to CLKB
  set_disable_timing $cell -from CLKB -to CLKA
}

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

# CDC Paths
#=================
update_timing
set clocks [all_clocks]
foreach_in_collection launch_clk $clocks {
  if { [get_attribute $launch_clk is_generated] } {
    set launch_group [get_generated_clocks -filter "master_clock_name==[get_attribute $launch_clk master_clock_name]"]
    append_to_collection launch_group [get_attribute $launch_clk master_clock]
  } else {
    set launch_group [get_generated_clocks -filter "master_clock_name==[get_attribute $launch_clk name]"]
    append_to_collection launch_group $launch_clk
  }
  foreach_in_collection latch_clk [remove_from_collection $clocks $launch_group] {
    set launch_period [get_attribute $launch_clk period]
    set latch_period [get_attribute $latch_clk period]
    set max_delay_ps [expr min($launch_period,$latch_period)/2]
    set_max_delay $max_delay_ps -from $launch_clk -to $latch_clk -ignore_clock_latency
    set_min_delay 0             -from $launch_clk -to $latch_clk -ignore_clock_latency
  }
}

# Retiming
set_app_var compile_keep_original_for_external_references true
set_app_var case_analysis_propagate_through_icg true

current_design *pipe_fma*
create_clock -period ${bp_clk_period_ps} [get_ports "clk_i"]
set_optimize_registers true -check_design
uniquify -force
ungroup -flatten [get_cells -hier]
update_timing

current_design *pipe_aux*
create_clock -period ${bp_clk_period_ps} [get_ports "clk_i"]
set_optimize_registers true -check_design
uniquify -force
ungroup -flatten [get_cells -hier]
update_timing

current_design *pipe_mem*
create_clock -period ${bp_clk_period_ps} [get_ports "clk_i"]
set_optimize_registers true -check_design
uniquify -force
ungroup -flatten [get_cells -hier]
update_timing

current_design bsg_blackparrot_unicore_tile_node

