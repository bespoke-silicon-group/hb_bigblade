puts "BSG-info: Running script [info script]\n"

source $::env(BSG_DESIGNS_TARGET_TCL_HARD_DIR)/hb_common_variables.tcl

#remove_buffers [get_cells FTB*]
for {set i [expr 2*$HB_RUCHE_LINK_WIDTH_P]} {$i < [expr 2*$HB_RUCHE_FACTOR_P*$HB_RUCHE_LINK_WIDTH_P]} {incr i} {
  set_dont_touch [get_nets "ruche_link_i[${i}]"] true
}



puts "BSG-info: Completed script [info script]\n"
