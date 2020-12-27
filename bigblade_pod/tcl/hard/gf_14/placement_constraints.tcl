puts "BSG-info: Running script [info script]\n"

#source $::env(BSG_DESIGNS_TARGET_TCL_HARD_DIR)/hb_placement_blockage.tcl
source $::env(BSG_DESIGNS_TARGET_TCL_HARD_DIR)/hb_placement_sram.tcl
source $::env(BSG_DESIGNS_TARGET_TCL_HARD_DIR)/hb_placement_rp_group.tcl

puts "BSG-info: Completed script [info script]\n"
