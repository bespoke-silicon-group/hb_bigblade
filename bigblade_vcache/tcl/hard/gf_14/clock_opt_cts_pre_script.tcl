puts "BSG-info: Running script [info script]\n"


# common local proc
proc get_y_cord {obj} {
  set lly [get_attribute $obj bounding_box.ll_y]
  set ury [get_attribute $obj bounding_box.ur_y]
  return [expr ($lly+$ury)/2]
}


source $::env(BSG_DESIGNS_TARGET_TCL_HARD_DIR)/hb_common_variables.tcl
source $::env(BSG_DESIGNS_TARGET_TCL_HARD_DIR)/hb_draw_wires.tcl

set core_llx [get_attribute [get_core_area] bounding_box.ll_x]
set core_urx [get_attribute [get_core_area] bounding_box.ur_x]

for {set i [expr 2*$HB_WH_LINK_WIDTH_P]} {$i < [expr 2*$HB_WH_RUCHE_FACTOR_P*$HB_WH_LINK_WIDTH_P]} {incr i} {
  set net [get_nets "wh_link_sif_i[${i}]"]
  set port [get_ports "wh_link_sif_i[${i}]"]
  set layer [get_attribute $port layer.name]
  set y [get_y_cord $port]
  draw_horizontal_wire $net $layer $core_llx $core_urx $y
}




puts "BSG-info: Completed script [info script]\n"
