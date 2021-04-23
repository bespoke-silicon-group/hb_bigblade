puts "BSG-info: Running script [info script]\n"

########################################
## Source common scripts
source -echo -verbose $::env(hb_bigblade_dir)/common/hb_design_constants.tcl
source -echo -verbose $::env(hb_bigblade_dir)/common/bsg_async.constraints.tcl
source -echo -verbose $::env(hb_bigblade_dir)/common/bsg_chip_cdc.constraints.tcl
source -echo -verbose $::env(hb_bigblade_dir)/common/bsg_chip_misc.tcl
source -echo -verbose $::env(basejump_stl_dir)/hard/gf_14/bsg_link/tcl/bsg_link_sdr.constraints.tcl

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
set xcel_clk_name "xcel_clk" ;# main clock running CGRA
set xcel_clk_period_ps       1100
set xcel_clk_uncertainty_per 3.0
set xcel_clk_uncertainty_ps  [expr min([expr $xcel_clk_period_ps*($xcel_clk_uncertainty_per/100.0)], 20)]

set xcel_input_delay_min_per 2.0
set xcel_input_delay_min_ps [expr $xcel_clk_period_ps*$xcel_input_delay_min_per/100.0]
set xcel_input_delay_max_per 70.0
set xcel_input_delay_max_ps [expr $xcel_clk_period_ps*$xcel_input_delay_max_per/100.0]

set link_clk_period_ps        1000
set link_clk_uncertainty_per  3.0
set link_clk_uncertainty_ps  [expr min([expr $link_clk_period_ps*($link_clk_uncertainty_per/100.0)], 20)]

set token_clk_period_ps       [expr 2*$link_clk_period_ps]
set token_clk_uncertainty_per 3.0
set token_clk_uncertainty_ps  [expr min([expr $token_clk_period_ps*($token_clk_uncertainty_per/100.0)], 20)]

set max_io_output_margin_ps   200
set max_io_input_margin_ps    200

########################################
## Reg2Reg
create_clock -period $xcel_clk_period_ps -name $xcel_clk_name [get_ports clk_i]
set_clock_uncertainty $xcel_clk_uncertainty_ps [get_clocks $xcel_clk_name]

########################################
## In2Reg
set xcel_input_pins [get_ports reset_i]
append_to_collection xcel_input_pins [get_ports global_y_cord_i[*]]
append_to_collection xcel_input_pins [get_ports async_*_reset_i]
set_input_delay -min $xcel_input_delay_min_ps -clock $xcel_clk_name $xcel_input_pins
set_input_delay -max $xcel_input_delay_max_ps -clock $xcel_clk_name $xcel_input_pins
set_driving_cell -min -no_design_rule -lib_cell "SC7P5T_CKINVX2_SSC14R" [all_inputs]
set_driving_cell -max -no_design_rule -lib_cell "SC7P5T_CKINVX8_SSC14R" [all_inputs]

set_driving_cell -no_design_rule -lib_cell "SC7P5T_CKBUFX1_SSC14R" [get_ports clk_i]

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
set_false_path -from [get_ports global_*_cord_i]
set_false_path -from [get_ports async_*_reset_i]
set_false_path -to [get_ports async_*_reset_o]

########################################
## Disable timing
bsg_link_sdr_disable_timing_constraints

########################################
## Dont touch
bsg_link_sdr_dont_touch_constraints [get_ports {io_*_link_data_i[*] io_*_link_v_i}]

########################################
## CDC Paths
for {set i 0} {$i < 4} {incr i} {
  set cdc_clocks [get_clocks $xcel_clk_name]
  append_to_collection cdc_clocks [get_clocks fwd_in_clk_${i}]
  bsg_async_icl $cdc_clocks
  
  set cdc_clocks [get_clocks $xcel_clk_name]
  append_to_collection cdc_clocks [get_clocks rev_in_clk_${i}]
  bsg_async_icl $cdc_clocks
  
  set cdc_clocks [get_clocks $xcel_clk_name]
  append_to_collection cdc_clocks [get_clocks fwd_tkn_clk_${i}]
  bsg_async_icl $cdc_clocks
  
  set cdc_clocks [get_clocks $xcel_clk_name]
  append_to_collection cdc_clocks [get_clocks rev_tkn_clk_${i}]
  bsg_async_icl $cdc_clocks
}

########################################
## Derate
bsg_chip_derate_cells
bsg_chip_derate_mems
#report_timing_derate

########################################
## Disabled or false paths
bsg_chip_disable_1r1w_paths {"*regfile*rf*"}
bsg_chip_disable_1r1w_paths {"*btb*tag_mem*"}

########################################
## Ungrouping
#set_ungroup [get_designs -filter "hdl_template==bsg_dff_chain"                   ] true
#set_ungroup [get_designs -filter "hdl_template==bsg_mux_one_hot"                 ] true
#set_ungroup [get_designs -filter "hdl_template==bsg_scan"                        ] true
#set_ungroup [get_designs -filter "hdl_template==bsg_priority_encode_one_hot_out" ] true
#set_ungroup [get_designs -filter "hdl_template==bsg_priority_encode"             ] true

#set_ungroup [get_designs -filter "hdl_template==bsg_manycore_reg_id_decode"      ] true
#set_ungroup [get_designs -filter "hdl_template==bsg_manycore_endpoint"           ] true
#set_ungroup [get_designs -filter "hdl_template==bsg_manycore_lock_ctrl"          ] true
#set_ungroup [get_designs -filter "hdl_template==hash_function"                   ] true

#set_ungroup [get_designs -filter "hdl_template==compareRecFN"                    ] true 
#set_ungroup [get_designs -filter "hdl_template==divSqrtRecFNToRaw_small"         ] true
#set_ungroup [get_designs -filter "hdl_template==fNToRecFN"                       ] true
#set_ungroup [get_designs -filter "hdl_template==recFNToRawFN"                    ] true
#set_ungroup [get_designs -filter "hdl_template==roundAnyRawFNToRecFN"            ] true
#set_ungroup [get_designs -filter "hdl_template==iNFromException"                 ] true
#set_ungroup [get_designs -filter "hdl_template==iNToRawFN"                       ] true
#set_ungroup [get_designs -filter "hdl_template==iNToRecFN"                       ] true
#set_ungroup [get_designs -filter "hdl_template==isSigNaNRecFN"                   ] true
#set_ungroup [get_designs -filter "hdl_template==mulAddRecFNToRaw"                ] true
#set_ungroup [get_designs -filter "hdl_template==recFNToFN"                       ] true
#set_ungroup [get_designs -filter "hdl_template==recFNToIN"                       ] true
#set_ungroup [get_designs -filter "hdl_template==recFNToRecFN"                    ] true
#set_ungroup [get_designs -filter "hdl_template==reverse"                         ] true
#set_ungroup [get_designs -filter "hdl_template==lowMaskHiLo"                     ] true
#set_ungroup [get_designs -filter "hdl_template==lowMaskLoHi"                     ] true
#set_ungroup [get_designs -filter "hdl_template==countLeadingZeros"               ] true
#set_ungroup [get_designs -filter "hdl_template==compressBy2"                     ] true
#set_ungroup [get_designs -filter "hdl_template==compressBy4"                     ] true

########################################
## Flattening

########################################
## Retiming

puts "BSG-info: Completed script [info script]\n"
