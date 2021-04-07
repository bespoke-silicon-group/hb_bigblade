puts "BSG-info: Running script [info script]\n"

source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_common_variables.tcl

#remove_buffers [get_cells FTB*]
for {set i [expr 2*$HB_WH_LINK_WIDTH_P]} {$i < [expr 2*$HB_WH_RUCHE_FACTOR_P*$HB_WH_LINK_WIDTH_P]} {incr i} {
  set_dont_touch [get_nets "wh_link_sif_i[${i}]"] true
}

puts "BSG-info: Completed script [info script]\n"
