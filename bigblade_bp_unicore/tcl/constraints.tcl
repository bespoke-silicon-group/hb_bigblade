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

# constraints
if { ${DESIGN_NAME} == "bsg_blackparrot_unicore_tile_node" } {
  source -echo -verbose $constraints_dir/bsg_blackparrot_unicore_tile_node.constraints.tcl
} elseif { ${DESIGN_NAME} == "bsg_blackparrot_unicore_pod" } {
  source -echo -verbose $constraints_dir/bsg_blackparrot_unicore_pod.constraints.tcl
}

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

puts "BSG-info: Completed script [info script]\n"
