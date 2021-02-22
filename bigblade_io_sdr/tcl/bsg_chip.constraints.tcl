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
set core_clk_name "core_clk"
set core_clk_period_ps 1000
set core_clk_uncertainty_per 3.0
set core_clk_uncertainty_ps [expr min([expr ${core_clk_period_ps}*(${core_clk_uncertainty_per}/100.0)], 20)]

set core_input_delay_per  20.0
set core_input_delay_ps  [expr ${core_clk_period_ps}*(${core_input_delay_per}/100.0)]
set core_output_delay_per 20.0
set core_output_delay_ps [expr ${core_clk_period_ps}*(${core_output_delay_per}/100.0)]

set link_clk_name "link_clk"
set link_clk_period_ps 1000
set link_clk_uncertainty_per 3.0
set link_clk_uncertainty_ps [expr min([expr ${link_clk_period_ps}*(${link_clk_uncertainty_per}/100.0)], 20)]

set link_input_delay_per  20.0
set link_input_delay_ps  [expr ${link_clk_period_ps}*(${link_input_delay_per}/100.0)]
set link_output_delay_per 20.0
set link_output_delay_ps [expr ${link_clk_period_ps}*(${link_output_delay_per}/100.0)]

set token_clk_name "token_clk"
set token_clk_period_ps 2000
set token_clk_uncertainty_per 3.0
set token_clk_uncertainty_ps [expr min([expr ${token_clk_period_ps}*(${token_clk_uncertainty_per}/100.0)], 20)]

set token_input_delay_per  20.0
set token_input_delay_ps  [expr ${token_clk_period_ps}*(${token_input_delay_per}/100.0)]
set token_output_delay_per 20.0
set token_output_delay_ps [expr ${token_clk_period_ps}*(${token_output_delay_per}/100.0)]

########################################
## Reg2Reg
create_clock -period ${core_clk_period_ps} -name ${core_clk_name} [get_ports "core_clk_i"]
set_clock_uncertainty ${core_clk_uncertainty_ps} [get_clocks ${core_clk_name}]
create_clock -period ${link_clk_period_ps} -name "fwd_link_clk" [get_ports "io_fwd_link_clk_i"]
set_clock_uncertainty ${link_clk_uncertainty_ps} [get_clocks "fwd_link_clk"]
create_clock -period ${link_clk_period_ps} -name "rev_link_clk" [get_ports "io_rev_link_clk_i"]
set_clock_uncertainty ${link_clk_uncertainty_ps} [get_clocks "rev_link_clk"]
create_clock -period ${token_clk_period_ps} -name "fwd_token_clk" [get_ports "io_fwd_link_token_i"]
set_clock_uncertainty ${token_clk_uncertainty_ps} [get_clocks "fwd_token_clk"]
create_clock -period ${token_clk_period_ps} -name "rev_token_clk" [get_ports "io_rev_link_token_i"]
set_clock_uncertainty ${token_clk_uncertainty_ps} [get_clocks "rev_token_clk"]

########################################
## In2Reg
set driving_lib_cell $LIB_CELLS(invx2)

set core_input_pins [filter_collection [filter_collection [all_inputs] "name=~core*" ] "name!~*clk*"]
set_input_delay ${core_input_delay_ps} -clock ${core_clk_name} ${core_input_pins}

set fwd_link_input_pins [filter_collection [filter_collection [filter_collection [all_inputs] "name=~io_fwd_link*" ] "name!~*clk*"] "name!~*token*"]
set rev_link_input_pins [filter_collection [filter_collection [filter_collection [all_inputs] "name=~io_rev_link*" ] "name!~*clk*"] "name!~*token*"]
set_input_delay ${link_input_delay_ps} -clock "fwd_link_clk" ${fwd_link_input_pins}
set_input_delay ${link_input_delay_ps} -clock "rev_link_clk" ${rev_link_input_pins}

set_driving_cell -no_design_rule -lib_cell ${driving_lib_cell} [remove_from_collection [all_inputs] [get_ports *clk*]]

########################################
## Reg2Out
set load_lib_pin $LIB_CELLS(invx8,load_pin)

set core_output_pins [filter_collection [all_outputs] "name=~core_*"]
set_output_delay ${core_output_delay_ps} -clock ${core_clk_name} ${core_output_pins}
set_load [load_of [get_lib_pin */${load_lib_pin}]] ${core_output_pins}

set fwd_link_output_pins [filter_collection [filter_collection [all_outputs] "name=~io_fwd_link*" ] "name!~*token*"]
set rev_link_output_pins [filter_collection [filter_collection [all_outputs] "name=~io_rev_link*" ] "name!~*token*"]
set_output_delay ${link_output_delay_ps} -clock ${core_clk_name} ${fwd_link_output_pins}
set_output_delay ${link_output_delay_ps} -clock ${core_clk_name} ${rev_link_output_pins}
set_load [load_of [get_lib_pin */${load_lib_pin}]] ${fwd_link_output_pins}
set_load [load_of [get_lib_pin */${load_lib_pin}]] ${rev_link_output_pins}

########################################
## False
set_false_path -from [get_ports async_uplink_reset_i]
set_false_path -from [get_ports async_downlink_reset_i]
set_false_path -from [get_ports async_downstream_reset_i]
set_false_path -from [get_ports async_token_reset_i]

set_false_path -to [get_ports async_uplink_reset_o]
set_false_path -to [get_ports async_downlink_reset_o]
set_false_path -to [get_ports async_downstream_reset_o]
set_false_path -to [get_ports async_token_reset_o]

########################################
## CDC
set_max_delay ${core_clk_period_ps} -from "fwd_link_clk" -to ${core_clk_name} -ignore_clock_latency
set_max_delay ${core_clk_period_ps} -from "rev_link_clk" -to ${core_clk_name} -ignore_clock_latency
set_max_delay ${core_clk_period_ps} -from ${core_clk_name} -to "fwd_link_clk" -ignore_clock_latency
set_max_delay ${core_clk_period_ps} -from ${core_clk_name} -to "rev_link_clk" -ignore_clock_latency

set_min_delay 0 -from "fwd_link_clk" -to ${core_clk_name} -ignore_clock_latency
set_min_delay 0 -from "rev_link_clk" -to ${core_clk_name} -ignore_clock_latency
set_min_delay 0 -from ${core_clk_name} -to "fwd_link_clk" -ignore_clock_latency
set_min_delay 0 -from ${core_clk_name} -to "rev_link_clk" -ignore_clock_latency

set_max_delay ${core_clk_period_ps} -from "fwd_token_clk" -to ${core_clk_name} -ignore_clock_latency
set_max_delay ${core_clk_period_ps} -from "rev_token_clk" -to ${core_clk_name} -ignore_clock_latency
set_max_delay ${core_clk_period_ps} -from ${core_clk_name} -to "fwd_token_clk" -ignore_clock_latency
set_max_delay ${core_clk_period_ps} -from ${core_clk_name} -to "rev_token_clk" -ignore_clock_latency

set_min_delay 0 -from "fwd_token_clk" -to ${core_clk_name} -ignore_clock_latency
set_min_delay 0 -from "rev_token_clk" -to ${core_clk_name} -ignore_clock_latency
set_min_delay 0 -from ${core_clk_name} -to "fwd_token_clk" -ignore_clock_latency
set_min_delay 0 -from ${core_clk_name} -to "rev_token_clk" -ignore_clock_latency

########################################
## Derate
bsg_chip_derate_cells
bsg_chip_derate_mems
#report_timing_derate

puts "BSG-info: Completed script [info script]\n"

