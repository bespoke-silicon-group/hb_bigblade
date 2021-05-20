puts "BSG-info: Running script [info script]\n"

########################################
## Source common scripts
source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_design_constants.tcl
source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/bsg_async.constraints.tcl
source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/bsg_chip_cdc.constraints.tcl
source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/bsg_chip_misc.tcl
source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/basejump_stl/hard/gf_14/bsg_link/tcl/bsg_link_sdr.constraints.tcl

########################################
## App Var Setup
# Needed for CDC multiple clock path constraints
set_app_var timing_enable_multiple_clocks_per_reg true
# Needed for retiming in some cases
set_app_var compile_keep_original_for_external_references true
# Needed for automatic clock-gate insertions
set_app_var case_analysis_propagate_through_icg true

########################################
## Clock Setup
set xcel_clk_name "core_clk" ;# main clock running CGRA
set xcel_clk_period_ps       1000 ; # feel free to loosen this to 1500 in the backend
set xcel_clk_uncertainty_per 3.0
set xcel_clk_uncertainty_ps  [expr min([expr $xcel_clk_period_ps*($xcel_clk_uncertainty_per/100.0)], 20)]

set xcel_input_delay_min_per 2.0
set xcel_input_delay_min_ps [expr $xcel_clk_period_ps*$xcel_input_delay_min_per/100.0]
set xcel_input_delay_max_per 70.0
set xcel_input_delay_max_ps [expr $xcel_clk_period_ps*$xcel_input_delay_max_per/100.0]

set xcel_output_delay_min_per 2.0
set xcel_output_delay_min_ps [expr $xcel_clk_period_ps*$xcel_output_delay_min_per/100.0]
set xcel_output_delay_max_per 20.0
set xcel_output_delay_max_ps [expr $xcel_clk_period_ps*$xcel_output_delay_max_per/100.0]

set link_clk_period_ps        1000
set link_clk_uncertainty_per  3.0
set link_clk_uncertainty_ps  [expr min([expr $link_clk_period_ps*($link_clk_uncertainty_per/100.0)], 20)]

set token_clk_period_ps       [expr 2*$link_clk_period_ps]
set token_clk_uncertainty_per 3.0
set token_clk_uncertainty_ps  [expr min([expr $token_clk_period_ps*($token_clk_uncertainty_per/100.0)], 20)]

set max_io_output_margin_ps   200
set max_io_input_margin_ps    200

set tag_clk_name "tag_clk"
set tag_clk_period_ps      5000.0 ;# 200 MHz
set tag_clk_uncertainty_ps 20

set tag_input_delay_min_ps 100
set tag_input_delay_max_ps 4000

########################################
## Reg2Reg
create_clock -period $xcel_clk_period_ps -name $xcel_clk_name [get_ports clk_i]
set_clock_uncertainty $xcel_clk_uncertainty_ps [get_clocks $xcel_clk_name]

create_clock -period $tag_clk_period_ps -name $tag_clk_name [get_ports tag_clk_i]
set_clock_uncertainty $tag_clk_uncertainty_ps  [get_clocks $tag_clk_name]

########################################
## In2Reg
set xcel_input_pins [get_ports reset_i]
append_to_collection xcel_input_pins [get_ports async_*_reset_i]
set_input_delay -min $xcel_input_delay_min_ps -clock $xcel_clk_name $xcel_input_pins
set_input_delay -max $xcel_input_delay_max_ps -clock $xcel_clk_name $xcel_input_pins
set_driving_cell -min -no_design_rule -lib_cell $LIB_CELLS(invx2) [all_inputs]
set_driving_cell -max -no_design_rule -lib_cell $LIB_CELLS(invx8) [all_inputs]

set tag_in_ports [get_ports tag_data_i]
append_to_collection tag_in_ports [get_ports tag_node_id_offset_i[*]]
set_input_delay -max $tag_input_delay_max_ps -clock $tag_clk_name $tag_in_ports

########################################
## Reg2Out
set xcel_output_pins [get_ports sdr_disable_o]
set_output_delay -min $xcel_output_delay_min_ps -clock $xcel_clk_name $xcel_output_pins
set_output_delay -max $xcel_output_delay_max_ps -clock $xcel_clk_name $xcel_output_pins
set_load -min [load_of [get_lib_pin */$LIB_CELLS(invx2,load_pin)]] [all_outputs]
set_load -max [load_of [get_lib_pin */$LIB_CELLS(invx8,load_pin)]] [all_outputs]

########################################
## SDR constraints
for {set i 0} {$i < 4} {incr i} {
  bsg_link_sdr_constraints                                         \
    $xcel_clk_name                                                 \
    [get_ports clk_i]                                              \
    "fwd_out_clk_$i"                                               \
    $xcel_clk_period_ps                                            \
    $max_io_output_margin_ps                                       \
    [get_ports io_fwd_link_clk_o[$i]]                              \
    [get_ports "io_fwd_link_data_o[$i][*] io_fwd_link_v_o[$i]"]    \
    "fwd_in_clk_$i"                                                \
    $link_clk_period_ps                                            \
    $max_io_input_margin_ps                                        \
    [get_ports io_fwd_link_clk_i[$i]]                              \
    [get_ports "io_fwd_link_data_i[$i][*] io_fwd_link_v_i[$i]"]    \
    "fwd_tkn_clk_$i"                                               \
    [get_ports io_fwd_link_token_i[$i]]                            \
    $link_clk_uncertainty_ps

  bsg_link_sdr_constraints                                         \
    $xcel_clk_name                                                 \
    [get_ports clk_i]                                              \
    "rev_out_clk_$i"                                               \
    $xcel_clk_period_ps                                            \
    $max_io_output_margin_ps                                       \
    [get_ports io_rev_link_clk_o[$i]]                              \
    [get_ports "io_rev_link_data_o[$i][*] io_rev_link_v_o[$i]"]    \
    "rev_in_clk_$i"                                                \
    $link_clk_period_ps                                            \
    $max_io_input_margin_ps                                        \
    [get_ports io_rev_link_clk_i[$i]]                              \
    [get_ports "io_rev_link_data_i[$i][*] io_rev_link_v_i[$i]"]    \
    "rev_tkn_clk_$i"                                               \
    [get_ports io_rev_link_token_i[$i]]                            \
    $link_clk_uncertainty_ps
}

########################################
## False paths
set_false_path -from [get_ports tag_node_id_offset_i[*]]
set_false_path -to   [get_ports sdr_disable_o]

########################################
## Disable timing
bsg_link_sdr_disable_timing_constraints

########################################
## Dont touch
bsg_link_sdr_dont_touch_constraints [get_ports {io_*_link_data_i[*] io_*_link_v_i}]

## AND reduction network and broadcast network DONT_TOUCH's
set_dont_touch [get_cells -hier -filter "full_name=~*BSG_DONT_TOUCH*"] true

########################################
## CDC Paths
for {set i 0} {$i < 4} {incr i} {
  set cdc_clocks [get_clocks $xcel_clk_name]
  append_to_collection cdc_clocks [get_clocks fwd_in_clk_${i}]
  append_to_collection cdc_clocks [get_clocks tag_clk]
  bsg_async_icl $cdc_clocks

  set cdc_clocks [get_clocks $xcel_clk_name]
  append_to_collection cdc_clocks [get_clocks rev_in_clk_${i}]
  append_to_collection cdc_clocks [get_clocks tag_clk]
  bsg_async_icl $cdc_clocks

  set cdc_clocks [get_clocks $xcel_clk_name]
  append_to_collection cdc_clocks [get_clocks fwd_tkn_clk_${i}]
  append_to_collection cdc_clocks [get_clocks tag_clk]
  bsg_async_icl $cdc_clocks

  set cdc_clocks [get_clocks $xcel_clk_name]
  append_to_collection cdc_clocks [get_clocks rev_tkn_clk_${i}]
  append_to_collection cdc_clocks [get_clocks tag_clk]
  bsg_async_icl $cdc_clocks
}

########################################
## Derate
bsg_chip_derate_cells
bsg_chip_derate_mems
#report_timing_derate

#set_app_var sh_continue_on_error false

########################################
## Ungrouping
# PP: ungroup this data path module and hopefully DC will stop inserting buffers
# to the is_calc control signal...
set_ungroup [get_designs *bsg_gf_14_reduce_and_* ] true
set_ungroup [get_designs -filter "hdl_template==CGRACoreCtrl__1736738b526e3fb9" ] true
set_ungroup [get_designs -filter "hdl_template==CGRACoreDpath__1736738b526e3fb9" ] true
set_ungroup [get_designs -filter "hdl_template==CGRACore__1736738b526e3fb9" ] true

########################################
## Flattening

########################################
## Retiming

puts "BSG-info: Completed script [info script]\n"
