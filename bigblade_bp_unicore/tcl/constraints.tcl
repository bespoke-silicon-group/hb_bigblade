puts "BSG-info: Running script [info script]\n"

# constraints dir
set constraints_dir $::env(BSG_DESIGNS_TARGET_DIR)/tcl

########################################
##
## Clock Setup
##

set bp_clk_name "bp_clk" ;# main clock running black parrot
set bp_clk_period_ps       2000
set bp_clk_uncertainty_per 3.0
set bp_clk_uncertainty_ps  [expr min([expr ${bp_clk_period_ps}*(${bp_clk_uncertainty_per}/100.0)], 20)]

set mc_clk_name "mc_clk" ;# clock for the manycore
set mc_clk_period_ps       2000
set mc_clk_uncertainty_per 3.0
set mc_clk_uncertainty_ps  [expr min([expr ${mc_clk_period_ps}*(${mc_clk_uncertainty_per}/100.0)], 20)]

set_app_var timing_enable_multiple_clocks_per_reg true
set_app_var compile_keep_original_for_external_references true
set_app_var case_analysis_propagate_through_icg true

# constraints
if { ${DESIGN_NAME} == "bsg_blackparrot_unicore_tile_node" } {
  source -echo -verbose $constraints_dir/bsg_blackparrot_unicore_tile_node.constraints.tcl
} elseif { ${DESIGN_NAME} == "bsg_blackparrot_unicore_pod" } {
  source -echo -verbose $constraints_dir/bsg_blackparrot_unicore_pod.constraints.tcl
}

puts "BSG-info: Completed script [info script]\n"
