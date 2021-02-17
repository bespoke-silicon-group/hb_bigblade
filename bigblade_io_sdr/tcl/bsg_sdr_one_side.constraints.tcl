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
set down_clk_name "down_clk"
set down_clk_period_ps 1000
set down_clk_uncertainty_per 3.0
set down_clk_uncertainty_ps [expr min([expr ${down_clk_period_ps}*(${down_clk_uncertainty_per}/100.0)], 20)]

set down_input_delay_per  20.0
set down_input_delay_ps  [expr ${down_clk_period_ps}*(${down_input_delay_per}/100.0)]
set down_output_delay_per 20.0
set down_output_delay_ps [expr ${down_clk_period_ps}*(${down_output_delay_per}/100.0)]

set link_clk_name "link_clk"
set link_clk_period_ps 2000
set link_clk_uncertainty_per 3.0
set link_clk_uncertainty_ps [expr min([expr ${link_clk_period_ps}*(${link_clk_uncertainty_per}/100.0)], 20)]

set link_input_delay_per  20.0
set link_input_delay_ps  [expr ${link_clk_period_ps}*(${link_input_delay_per}/100.0)]
set link_output_delay_per 20.0
set link_output_delay_ps [expr ${link_clk_period_ps}*(${link_output_delay_per}/100.0)]

set token_clk_name "token_clk"
set token_clk_period_ps 4000
set token_clk_uncertainty_per 3.0
set token_clk_uncertainty_ps [expr min([expr ${token_clk_period_ps}*(${token_clk_uncertainty_per}/100.0)], 20)]

set token_input_delay_per  20.0
set token_input_delay_ps  [expr ${token_clk_period_ps}*(${token_input_delay_per}/100.0)]
set token_output_delay_per 20.0
set token_output_delay_ps [expr ${token_clk_period_ps}*(${token_output_delay_per}/100.0)]

########################################
## Reg2Reg
create_clock -period ${down_clk_period_ps} -name ${down_clk_name} [get_ports "downstream_clk_i"]
set_clock_uncertainty ${down_clk_uncertainty_ps} [get_clocks ${down_clk_name}]
create_clock -period ${link_clk_period_ps} -name ${link_clk_name} [get_ports "link_clk_i"]
set_clock_uncertainty ${link_clk_uncertainty_ps} [get_clocks ${link_clk_name}]
create_clock -period ${token_clk_period_ps} -name ${token_clk_name} [get_ports "link_token_i"]
set_clock_uncertainty ${token_clk_uncertainty_ps} [get_clocks ${token_clk_name}]

########################################
## In2Reg
set driving_lib_cell $LIB_CELLS(invx2)
set down_input_pins [filter_collection [filter_collection [all_inputs] "name=~downstream*" ] "name!~*clk*"]
append_to_collection ${down_input_pins} [filter_collection [filter_collection [all_inputs] "name=~uplink*" ] "name!~*clk*"]
# These paths are actually async, but STA doesn't like that
append_to_collection ${down_input_pins} [get_ports async_token_reset_i]
append_to_collection ${down_input_pins} [get_ports downlink_reset_i]
set link_input_pins [filter_collection [filter_collection [filter_collection [all_inputs] "name=~link*" ] "name!~*clk*"] "name!~*token*"]
set_input_delay ${down_input_delay_ps} -clock ${down_clk_name} ${down_input_pins}
set_input_delay ${link_input_delay_ps} -clock ${link_clk_name} ${link_input_pins}
set_driving_cell -no_design_rule -lib_cell ${driving_lib_cell} [remove_from_collection [all_inputs] [get_ports *clk*]]

########################################
## Reg2Out
set load_lib_pin $LIB_CELLS(invx8,load_pin)
set down_output_pins [filter_collection [all_outputs] "name=~downstream*" ]
append_to_collection ${down_output_pins} [filter_collection [all_outputs] "name=~uplink*"]
set link_output_pins [filter_collection [all_outputs] "name=~link*" ]
set token_output_pins [filter_collection [all_outputs] "name=~*link_token*"]
set_output_delay ${down_output_delay_ps} -clock ${down_clk_name} ${down_output_pins}
set_output_delay ${link_output_delay_ps} -clock ${link_clk_name} ${link_output_pins}
set_output_delay ${token_output_delay_ps} -clock ${token_clk_name} ${token_output_pins}
set_load [load_of [get_lib_pin */${load_lib_pin}]] ${down_output_pins}
set_load [load_of [get_lib_pin */${load_lib_pin}]] ${link_output_pins}
set_load [load_of [get_lib_pin */${load_lib_pin}]] ${token_output_pins}

########################################
## False

########################################
## Derate
bsg_chip_derate_cells
bsg_chip_derate_mems
#report_timing_derate

puts "BSG-info: Completed script [info script]\n"

