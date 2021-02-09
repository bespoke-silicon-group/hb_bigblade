puts "BSG-info: Running script [info script]\n"

set_app_options -name plan.place.auto_generate_blockages -value false

#source $::env(BSG_DESIGNS_TARGET_TCL_HARD_DIR)/hb_placement_blockage.tcl
source $::env(BSG_DESIGNS_TARGET_TCL_HARD_DIR)/hb_placement_sram.tcl
#source $::env(BSG_DESIGNS_TARGET_TCL_HARD_DIR)/hb_placement_rp_group.tcl
#source $::env(BSG_DESIGNS_TARGET_TCL_HARD_DIR)/hb_placement_bound.tcl

puts "BSG-info: Completed script [info script]\n"
