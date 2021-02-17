puts "BSG-info: Running script [info script]\n"

########################################
## Source common scripts
source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/bsg_chip_cdc.constraints.tcl
source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/bsg_chip_misc.tcl

########################################
## App Var Setup
# Needed for CDC multiple clock path constraints
set_app_var timing_enable_multiple_clocks_per_reg true
# Needed for automatic clock-gate insertions
set_app_var case_analysis_propagate_through_icg true

########################################
## Clock Setup
set a_down_clk_name "a_down_clk"
set a_down_clk_period_ps 900
set a_down_clk_uncertainty_per 3.0
set a_down_clk_uncertainty_ps [expr min([expr ${a_down_clk_period_ps}*(${a_down_clk_uncertainty_per}/100.0)], 20)]

set a_down_input_delay_per  20.0
set a_down_input_delay_ps  [expr ${a_down_clk_period_ps}*(${a_down_input_delay_per}/100.0)]
set a_down_output_delay_per 20.0
set a_down_output_delay_ps [expr ${a_down_clk_period_ps}*(${a_down_output_delay_per}/100.0)]

set b_down_clk_name "b_down_clk"
set b_down_clk_period_ps 1100
set b_down_clk_uncertainty_per 3.0
set b_down_clk_uncertainty_ps [expr min([expr ${b_down_clk_period_ps}*(${b_down_clk_uncertainty_per}/100.0)], 20)]

set b_down_input_delay_per  20.0
set b_down_input_delay_ps  [expr ${b_down_clk_period_ps}*(${b_down_input_delay_per}/100.0)]
set b_down_output_delay_per 20.0
set b_down_output_delay_ps [expr ${b_down_clk_period_ps}*(${b_down_output_delay_per}/100.0)]

########################################
## Reg2Reg
create_clock -period ${a_down_clk_period_ps} -name ${a_down_clk_name} [get_ports "a_downstream_clk_i"]
create_clock -period ${b_down_clk_period_ps} -name ${b_down_clk_name} [get_ports "b_downstream_clk_i"]
set_clock_uncertainty ${a_down_clk_uncertainty_ps} [get_clocks ${a_down_clk_name}]
set_clock_uncertainty ${b_down_clk_uncertainty_ps} [get_clocks ${b_down_clk_name}]
create_generated_clock -name "a_tkn_clk" -source [get_ports "a_downstream_clk_i"] -edges {1 3 5} -edge_shift {0 0 0} [get_pins a_sdr/link_token_o]
create_generated_clock -name "b_tkn_clk" -source [get_ports "b_downstream_clk_i"] -edges {1 3 5} -edge_shift {0 0 0} [get_pins b_sdr/link_token_o]

########################################
## In2Reg
set driving_lib_cell $LIB_CELLS(invx2)
set a_down_input_pins [filter_collection [filter_collection [all_inputs] "name!~*clk*"] "name=~a_*"]
set b_down_input_pins [filter_collection [filter_collection [all_inputs] "name!~*clk*"] "name=~b_*"]
set_input_delay ${a_down_input_delay_ps} -clock ${a_down_clk_name} ${a_down_input_pins}
set_input_delay ${b_down_input_delay_ps} -clock ${b_down_clk_name} ${b_down_input_pins}
set_driving_cell -no_design_rule -lib_cell ${driving_lib_cell} [remove_from_collection [all_inputs] [get_ports *clk*]]

########################################
## Reg2Out
set load_lib_pin $LIB_CELLS(invx8,load_pin)
set a_down_output_pins [filter_collection [all_outputs] "name=~a_*"]
set b_down_output_pins [filter_collection [all_outputs] "name=~b_*"]
set_output_delay ${a_down_output_delay_ps} -clock ${a_down_clk_name} ${a_down_output_pins}
set_output_delay ${b_down_output_delay_ps} -clock ${b_down_clk_name} ${b_down_output_pins}
set_load [load_of [get_lib_pin */${load_lib_pin}]] [all_outputs]

########################################
## False
set_false_path -from [get_ports a_downlink_reset_i]
set_false_path -from [get_ports b_downlink_reset_i]
set_false_path -from [get_ports a_async_token_reset_i]
set_false_path -from [get_ports b_async_token_reset_i]

########################################
## Derate
bsg_chip_derate_cells
bsg_chip_derate_mems
#report_timing_derate

puts "BSG-info: Completed script [info script]\n"

