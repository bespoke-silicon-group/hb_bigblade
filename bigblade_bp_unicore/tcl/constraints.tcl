puts "BSG-info: Running script [info script]\n"

########################################
## Source common scripts
source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_design_constants.tcl
source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/bsg_async.constraints.tcl
source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/bsg_chip_sdr.constraints.tcl
source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/bsg_chip_cdc.constraints.tcl
source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/bsg_chip_misc.tcl

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
set bp_clk_name "bp_clk" ;# main clock running black parrot
set bp_clk_period_ps       1100
set bp_clk_uncertainty_per 3.0
set bp_clk_uncertainty_ps  [expr min([expr $bp_clk_period_ps*($bp_clk_uncertainty_per/100.0)], 20)]

set bp_input_delay_min_per 2.0
set bp_input_delay_min_ps [expr $bp_clk_period_ps*$bp_input_delay_min_per/100.0]
set bp_input_delay_max_per 70.0
set bp_input_delay_max_ps [expr $bp_clk_period_ps*$bp_input_delay_max_per/100.0]

set link_clk_period_ps        1000
set link_clk_uncertainty_per  3.0
set link_clk_uncertainty_ps  [expr min([expr $link_clk_period_ps*($link_clk_uncertainty_per/100.0)], 20)]

set token_clk_period_ps       [expr 2*$link_clk_period_ps]
set token_clk_uncertainty_per 3.0
set token_clk_uncertainty_ps  [expr min([expr $token_clk_period_ps*($token_clk_uncertainty_per/100.0)], 20)]

set max_io_output_skew_ps     200
set max_io_input_skew_ps      200
set io_setup_time_output      [expr ($bp_clk_period_ps/2)-$max_io_output_skew_ps]
set io_hold_time_output       [expr 0-$max_io_output_skew_ps]
set io_max_input_delay        [expr ($link_clk_period_ps)-$max_io_input_skew_ps]
set io_min_input_delay        [expr $max_io_input_skew_ps]

########################################
## Reg2Reg
create_clock -period $bp_clk_period_ps -name $bp_clk_name [get_ports clk_i]
set_clock_uncertainty $bp_clk_uncertainty_ps [get_clocks $bp_clk_name]

########################################
## In2Reg
set bp_input_pins [get_ports reset_i]
append_to_collection bp_input_pins [get_ports global_y_cord_i[*]]
append_to_collection bp_input_pins [get_ports async_*_reset_i]
set_input_delay -min $bp_input_delay_min_ps -clock $bp_clk_name $bp_input_pins
set_input_delay -max $bp_input_delay_max_ps -clock $bp_clk_name $bp_input_pins
set_driving_cell -min -no_design_rule -lib_cell $LIB_CELLS(invx2) [all_inputs]
set_driving_cell -max -no_design_rule -lib_cell $LIB_CELLS(invx8) [all_inputs]

set_driving_cell -no_design_rule -lib_cell "SC7P5T_CKBUFX1_SSC14R" [get_ports clk_i]

########################################
## SDR constraints
for set i 0 $i < 3 incr i 

  # upstream (fwd)
  set fwd_out_clk_name "fwd_out_clk_$i"
  set fwd_tkn_clk_name "fwd_tkn_clk_$i"
  set_load [load_of [get_lib_pin "*/SC7P5T_CKBUFX2_SSC14R/CLK"]] [get_ports io_fwd_link_clk_o[$i]]
  constrain_output_sdr_ports [get_ports io_fwd_link_clk_o[$i]] [get_ports io_fwd_link_data_o[$i][*]] $io_setup_time_output $io_hold_time_output
  constrain_output_sdr_ports [get_ports io_fwd_link_clk_o[$i]] [get_ports io_fwd_link_v_o[$i]] $io_setup_time_output $io_hold_time_output
  create_clock -period $token_clk_period_ps -name $fwd_tkn_clk_name [get_ports io_fwd_link_token_i[$i]]
  set_clock_uncertainty $token_clk_uncertainty_ps [get_clock $fwd_tkn_clk_name]
  
  # upstream (rev)
  set rev_out_clk_name "rev_out_clk_$i"
  set rev_tkn_clk_name "rev_tkn_clk_$i"
  set_load [load_of [get_lib_pin "*/SC7P5T_CKBUFX2_SSC14R/CLK"]] [get_ports io_rev_link_clk_o[$i]]
  constrain_output_sdr_ports [get_ports io_rev_link_clk_o[$i]] [get_ports io_rev_link_data_o[$i][*]] $io_setup_time_output $io_hold_time_output
  constrain_output_sdr_ports [get_ports io_rev_link_clk_o[$i]] [get_ports io_rev_link_v_o[$i]] $io_setup_time_output $io_hold_time_output
  create_clock -period $token_clk_period_ps -name $rev_tkn_clk_name [get_ports io_rev_link_token_i[$i]]
  set_clock_uncertainty $token_clk_uncertainty_ps [get_clock $rev_tkn_clk_name]
  
  # downstream (fwd)
  set fwd_in_clk_name "fwd_in_clk_$i"
  create_clock -period $link_clk_period_ps -name $fwd_in_clk_name [get_ports io_fwd_link_clk_i[$i]]
  set_clock_uncertainty $link_clk_uncertainty_ps [get_clock $fwd_in_clk_name]
  set_driving_cell -no_design_rule -lib_cell "SC7P5T_CKBUFX2_SSC14R" [get_ports io_fwd_link_clk_i[$i]]
  constrain_input_sdr_ports $fwd_in_clk_name [get_ports io_fwd_link_data_i[$i][*]] $io_max_input_delay $io_min_input_delay
  constrain_input_sdr_ports $fwd_in_clk_name [get_ports io_fwd_link_v_i[$i]] $io_max_input_delay $io_min_input_delay
  
  # downstream (rev)
  set rev_in_clk_name "rev_in_clk_$i"
  create_clock -period $link_clk_period_ps -name $rev_in_clk_name [get_ports io_rev_link_clk_i[$i]]
  set_clock_uncertainty $link_clk_uncertainty_ps [get_clock $rev_in_clk_name]
  set_driving_cell -no_design_rule -lib_cell "SC7P5T_CKBUFX2_SSC14R" [get_ports io_rev_link_clk_i[$i]]
  constrain_input_sdr_ports $rev_in_clk_name [get_ports io_rev_link_data_i[$i][*]] $io_max_input_delay $io_min_input_delay
  constrain_input_sdr_ports $rev_in_clk_name [get_ports io_rev_link_v_i[$i]] $io_max_input_delay $io_min_input_delay


########################################
## Disabled or false paths
bsg_chip_disable_1r1w_paths "*regfile*rf*"
bsg_chip_disable_1r1w_paths "*btb*tag_mem*"

set_false_path -from [get_ports global_*_cord_i]
set_false_path -from [get_ports async_*_reset_i]
set_false_path -to [get_ports async_*_reset_o]

########################################
## CDC Paths
set cdc_clocks [get_clocks $bp_clk_name]
append_to_collection cdc_clocks [get_clocks fwd_in_clk_*]
bsg_async_icl $cdc_clocks

set cdc_clocks [get_clocks $bp_clk_name]
append_to_collection cdc_clocks [get_clocks rev_in_clk_*]
bsg_async_icl $cdc_clocks

set cdc_clocks [get_clocks $bp_clk_name]
append_to_collection cdc_clocks [get_clocks fwd_tkn_clk_*]
bsg_async_icl $cdc_clocks

set cdc_clocks [get_clocks $bp_clk_name]
append_to_collection cdc_clocks [get_clocks rev_tkn_clk_*]
bsg_async_icl $cdc_clocks

########################################
## Derate
bsg_chip_derate_cells
bsg_chip_derate_mems
#report_timing_derate

########################################
## Dont touch
# inputs
set_dont_touch_network -no_propagate [get_ports io_*_link_data_i*]
set_dont_touch_network -no_propagate [get_ports io_*_link_v_i*]
# outputs
set_dont_touch_network -no_propagate [get_flat_pins -filter "full_name=~*BSG_OSDR_BUF_DONT_TOUCH/Z"]
set_dont_touch_network -no_propagate [get_flat_pins -filter "full_name=~*BSG_OSDR_CKBUF_DONT_TOUCH/Z"]

########################################
## Ungrouping
set_ungroup [get_designs -filter "hdl_template==bsg_dff_chain"                   ] true
set_ungroup [get_designs -filter "hdl_template==bsg_mux_one_hot"                 ] true
set_ungroup [get_designs -filter "hdl_template==bsg_scan"                        ] true
set_ungroup [get_designs -filter "hdl_template==bsg_priority_encode_one_hot_out" ] true
set_ungroup [get_designs -filter "hdl_template==bsg_priority_encode"             ] true

set_ungroup [get_designs -filter "hdl_template==bsg_manycore_reg_id_decode"      ] true
set_ungroup [get_designs -filter "hdl_template==bsg_manycore_endpoint"           ] true
set_ungroup [get_designs -filter "hdl_template==bsg_manycore_lock_ctrl"          ] true
set_ungroup [get_designs -filter "hdl_template==hash_function"                   ] true

set_ungroup [get_designs -filter "hdl_template==bp_be_dcache"                    ] true
set_ungroup [get_designs -filter "hdl_template==bp_be_dcache_decoder"            ] true
set_ungroup [get_designs -filter "hdl_template==bp_be_dcache_wbuf"               ] true
set_ungroup [get_designs -filter "hdl_template==bp_be_fp_to_rec"                 ] true
set_ungroup [get_designs -filter "hdl_template==bp_be_rec_to_fp"                 ] true
set_ungroup [get_designs -filter "hdl_template==bp_fe_icache"                    ] true
set_ungroup [get_designs -filter "hdl_template==bp_fe_pc_gen"                    ] true
set_ungroup [get_designs -filter "hdl_template==bp_fe_instr_scan"                ] true
set_ungroup [get_designs -filter "hdl_template==bp_mmu"                          ] true
set_ungroup [get_designs -filter "hdl_template==bp_be_ptw"                       ] true
set_ungroup [get_designs -filter "hdl_template==bp_tlb"                          ] true
#set_ungroup [get_designs -filter "hdl_template==bsg_bus_pack"                    ] true

set_ungroup [get_designs -filter "hdl_template==compareRecFN"                    ] true 
set_ungroup [get_designs -filter "hdl_template==divSqrtRecFNToRaw_small"         ] true
set_ungroup [get_designs -filter "hdl_template==fNToRecFN"                       ] true
set_ungroup [get_designs -filter "hdl_template==recFNToRawFN"                    ] true
set_ungroup [get_designs -filter "hdl_template==roundAnyRawFNToRecFN"            ] true
set_ungroup [get_designs -filter "hdl_template==iNFromException"                 ] true
set_ungroup [get_designs -filter "hdl_template==iNToRawFN"                       ] true
set_ungroup [get_designs -filter "hdl_template==iNToRecFN"                       ] true
set_ungroup [get_designs -filter "hdl_template==isSigNaNRecFN"                   ] true
set_ungroup [get_designs -filter "hdl_template==mulAddRecFNToRaw"                ] true
set_ungroup [get_designs -filter "hdl_template==recFNToFN"                       ] true
set_ungroup [get_designs -filter "hdl_template==recFNToIN"                       ] true
set_ungroup [get_designs -filter "hdl_template==recFNToRecFN"                    ] true
set_ungroup [get_designs -filter "hdl_template==reverse"                         ] true
set_ungroup [get_designs -filter "hdl_template==lowMaskHiLo"                     ] true
set_ungroup [get_designs -filter "hdl_template==lowMaskLoHi"                     ] true
set_ungroup [get_designs -filter "hdl_template==countLeadingZeros"               ] true
set_ungroup [get_designs -filter "hdl_template==compressBy2"                     ] true
set_ungroup [get_designs -filter "hdl_template==compressBy4"                     ] true

########################################
## Flattening

#ungroup -flatten [get_cells -hier -filter "full_name=~*bp_be_pipe_aux/*"]
#ungroup -flatten [get_cells -hier -filter "full_name=~*bp_be_pipe_fma/*"]
#ungroup -flatten [get_cells -hier -filter "full_name=~*bp_be_pipe_long/*"]

########################################
## Retiming
set_optimize_registers true -designs [get_designs bp_be_pipe_aux* ] -check_design -verbose
set_optimize_registers true -designs [get_designs bp_be_pipe_fma* ] -check_design -verbose
set_optimize_registers true -designs [get_designs bp_be_pipe_long*] -check_design -verbose

puts "BSG-info: Completed script [info script]\n"

