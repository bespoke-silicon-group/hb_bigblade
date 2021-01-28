puts "BSG-info: Running script [info script]\n"


source $::env(BSG_DESIGNS_TARGET_TCL_HARD_DIR)/hb_common_variables.tcl


# local proc
proc bsg_create_soft_bound {name llx lly urx ury} {
  set boundary [list [list $llx $lly] [list $urx $ury]]
  set my_bound [create_bound -name $name -type soft -boundary $boundary]
  return $my_bound
}


# north btc placement bound

set llx [expr 0.128*7980]
set lly [expr $core_height - 4.32]
set urx [expr 0.128*8135]
set ury $core_height
set north_btc_bound [bsg_create_soft_bound "north_btc_bound"  $llx $lly $urx $ury]
add_to_bound $north_btc_bound [get_cells -hier -filter "full_name=~pod_btc_n*"]

puts "BSG-info: Completed script [info script]\n"
