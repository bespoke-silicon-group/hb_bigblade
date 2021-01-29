puts "BSG-info: Running script [info script]\n"

########################################
## Source common scripts
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
set bp_clk_period_ps       2000
set bp_clk_uncertainty_per 3.0
set bp_clk_uncertainty_ps  [expr min([expr ${bp_clk_period_ps}*(${bp_clk_uncertainty_per}/100.0)], 20)]

set mc_clk_name "mc_clk" ;# clock for the manycore
set mc_clk_period_ps       1000
set mc_clk_uncertainty_per 3.0
set mc_clk_uncertainty_ps  [expr min([expr ${mc_clk_period_ps}*(${mc_clk_uncertainty_per}/100.0)], 20)]

set tag_clk_name "tag_clk" ;# clock for bsg_tag
set tag_clk_period_ps       6666.0 ;# 150 MHz
set tag_clk_uncertainty_per 3.0
set tag_clk_uncertainty_ps  [expr min([expr ${tag_clk_period_ps}*(${tag_clk_uncertainty_per}/100.0)], 20)]

set bp_input_delay_per  20.0
set bp_input_delay_ps  [expr ${bp_clk_period_ps}*(${bp_input_delay_per}/100.0)]
set bp_output_delay_per 20.0
set bp_output_delay_ps [expr ${bp_clk_period_ps}*(${bp_output_delay_per}/100.0)]

set mc_input_delay_per  20.0
set mc_input_delay_ps  [expr ${mc_clk_period_ps}*(${mc_input_delay_per}/100.0)]
set mc_output_delay_per 20.0
set mc_output_delay_ps [expr ${mc_clk_period_ps}*(${mc_output_delay_per}/100.0)]

set tag_input_delay_per  50.0
set tag_input_delay_ps  [expr ${tag_clk_period_ps}*(${tag_input_delay_per}/100.0)]
set tag_output_delay_per 50.0
set tag_output_delay_ps [expr ${tag_clk_period_ps}*(${tag_output_delay_per}/100.0)]

########################################
## Reg2Reg
create_clock -period ${bp_clk_period_ps} -name ${bp_clk_name} [get_ports "bp_clk_i"]
set_clock_uncertainty ${bp_clk_uncertainty_ps} [get_clocks ${bp_clk_name}]

create_clock -period ${mc_clk_period_ps} -name ${mc_clk_name} [get_ports "mc_clk_i"]
set_clock_uncertainty ${mc_clk_uncertainty_ps} [get_clocks ${mc_clk_name}]

set tag_clk_pins [get_ports {bsg_tag_i[*][clk]}]
create_clock -period ${tag_clk_period_ps} -name ${tag_clk_name} ${tag_clk_pins}
set_clock_uncertainty ${tag_clk_uncertainty_ps} [get_clocks ${tag_clk_name}]

########################################
## In2Reg
set driving_lib_cell $LIB_CELLS(invx2)
set mc_input_pins [filter_collection [filter_collection [all_inputs] "name=~mc*" ] "name!~*clk*"]
set bp_input_pins [filter_collection [filter_collection [all_inputs] "name=~bp*" ] "name!~*clk*"]
set tag_input_pins [remove_from_collection [filter_collection [all_inputs] "name=~bsg_tag*"] ${tag_clk_pins}]
set_input_delay ${bp_input_delay_ps} -clock ${bp_clk_name} ${bp_input_pins}
set_input_delay ${mc_input_delay_ps} -clock ${mc_clk_name} ${mc_input_pins}
set_input_delay ${tag_input_delay_ps} -clock ${tag_clk_name} ${tag_input_pins}
set_driving_cell -no_design_rule -lib_cell ${driving_lib_cell} [remove_from_collection [all_inputs] [get_ports *clk*]]

########################################
## Reg2Out
set load_lib_pin $LIB_CELLS(invx8,load_pin)
## Note: BP Unicore has no BP output pins, but BP Multicore will
#set bp_output_pins [filter_collection [all_outputs] "name=~bp*"]
set mc_output_pins [filter_collection [all_outputs] "name=~mc*"]
#set_load [load_of [get_lib_pin */${load_lib_pin}]] ${bp_output_pins}
set_load [load_of [get_lib_pin */${load_lib_pin}]] ${mc_output_pins}
#set_output_delay ${bp_output_delay_ps} -clock ${bp_clk_name} ${bp_output_pins}
set_output_delay ${mc_output_delay_ps} -clock ${mc_clk_name} ${mc_output_pins}

########################################
## Disabled or false paths
bsg_chip_disable_1r1w_paths {"*regfile*rf*"}
bsg_chip_disable_1r1w_paths {"*btb*tag_mem*"}

########################################
## CDC Paths
update_timing
bsg_chip_async_constraints
bsg_chip_cdc_constraints [all_clocks]

########################################
## Derate
bsg_chip_derate_cells
bsg_chip_derate_mems
#report_timing_derate

########################################
## Ungrouping
set_ungroup [get_designs -filter "hdl_template==bsg_array_concentrate_static"] true
set_ungroup [get_designs -filter "hdl_template==bsg_concentrate_static"      ] true
set_ungroup [get_designs -filter "hdl_template==bsg_crossbar_o_by_i"         ] true
set_ungroup [get_designs -filter "hdl_template==bsg_dff_chain"               ] true
set_ungroup [get_designs -filter "hdl_template==bsg_scan"                    ] true
set_ungroup [get_designs -filter "hdl_template==bsg_transpose"               ] true
set_ungroup [get_designs -filter "hdl_template==bsg_unconcentrate_static"    ] true

set_ungroup [get_designs -filter "hdl_template==bsg_manycore_reg_id_decode"  ] true
set_ungroup [get_designs -filter "hdl_template==bsg_manycore_endpoint"       ] true
set_ungroup [get_designs -filter "hdl_template==bsg_manycore_lock_ctrl"      ] true
set_ungroup [get_designs -filter "hdl_template==hash_function"               ] true

set_ungroup [get_designs -filter "hdl_template==bp_be_bypass"                ] true
set_ungroup [get_designs -filter "hdl_template==bp_be_dcache"                ] true
set_ungroup [get_designs -filter "hdl_template==bp_be_fp_to_rec"             ] true
set_ungroup [get_designs -filter "hdl_template==bp_be_rec_to_fp"             ] true
set_ungroup [get_designs -filter "hdl_template==bp_fe_icache"                ] true
set_ungroup [get_designs -filter "hdl_template==bp_fe_pc_gen"                ] true

set_ungroup [get_designs -filter "hdl_template==compareRecFN"                ] true 
set_ungroup [get_designs -filter "hdl_template==divSqrtRecFNToRaw_small"     ] true
set_ungroup [get_designs -filter "hdl_template==fNToRecFN"                   ] true
set_ungroup [get_designs -filter "hdl_template==recFNToRawFN"                ] true
set_ungroup [get_designs -filter "hdl_template==roundAnyRawFNToRecFN"        ] true
set_ungroup [get_designs -filter "hdl_template==iNToRecFN"                   ] true
set_ungroup [get_designs -filter "hdl_template==isSigNaNRecFN"               ] true
set_ungroup [get_designs -filter "hdl_template==mulAddRecFNToRaw"            ] true
set_ungroup [get_designs -filter "hdl_template==recFNToFN"                   ] true
set_ungroup [get_designs -filter "hdl_template==recFNToIN"                   ] true
set_ungroup [get_designs -filter "hdl_template==recFNToRecFN"                ] true
set_ungroup [get_designs -filter "hdl_template==reverse"                     ] true
set_ungroup [get_designs -filter "hdl_template==lowMaskHiLo"                 ] true
set_ungroup [get_designs -filter "hdl_template==lowMaskLoHi"                 ] true
set_ungroup [get_designs -filter "hdl_template==countLeadingZeros"           ] true
set_ungroup [get_designs -filter "hdl_template==compressBy2"                 ] true
set_ungroup [get_designs -filter "hdl_template==compressBy4"                 ] true

########################################
## Retiming
set_optimize_registers true -designs [get_designs *pipe_fma*] -check_design -verbose
set_optimize_registers true -designs [get_designs *pipe_aux*] -check_design -verbose
set_optimize_registers true -designs [get_designs *pipe_mem*] -check_design -verbose
update_timing

puts "BSG-info: Completed script [info script]\n"

