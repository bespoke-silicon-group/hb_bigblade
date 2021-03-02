source $::env(BSG_DESIGNS_TARGET_TCL_HARD_DIR)/hb_common_variables.tcl

proc get_pin_y {pin} {
  set lly [get_attribute $pin bounding_box.ll_y]
  set ury [get_attribute $pin bounding_box.ur_y]
  return [expr ($lly+$ury)/2]
}

for {set i 0} {$i < $HB_NUM_TILES_Y_P} {incr i} {
  set y [expr $HB_NUM_TILES_Y_P-1-$i]
  set tile_cell [get_cells "pod_mc_y_${y}__x_0__tile"]
  # output
  for {set j 0} {$j < $HB_RUCHE_LINK_WIDTH_P} {incr j} {
    set local_pin [get_pins -of $tile_cell -filter "name=~link_o[$j]"]
    set local_pin_y [get_pin_y $local_pin]
    set local_pin_name [get_attribute $local_pin full_name]
    puts $local_pin_name,$local_pin_y
    set ruche_idx [expr $j+($HB_RUCHE_LINK_WIDTH_P*2)]
    set ruche_pin [get_pins -of $tile_cell -filter "name=~ruche_link_o[${ruche_idx}]"]
    set ruche_pin_y [get_pin_y $ruche_pin]
    set ruche_pin_name [get_attribute $ruche_pin full_name]
    puts $ruche_pin_name,$ruche_pin_y
  }

  for {set j $HB_RUCHE_LINK_WIDTH_P} {$j < $HB_LINK_WIDTH_P} {incr j} {
    set local_pin [get_pins -of $tile_cell -filter "name=~link_o[$j]"]
    set local_pin_y [get_pin_y $local_pin]
    set local_pin_name [get_attribute $local_pin full_name]
    puts $local_pin_name,$local_pin_y
  }
  # input
  for {set j 0} {$j < $HB_RUCHE_LINK_WIDTH_P} {incr j} {
    set local_pin [get_pins -of $tile_cell -filter "name=~link_i[$j]"]
    set local_pin_y [get_pin_y $local_pin]
    set local_pin_name [get_attribute $local_pin full_name]
    puts $local_pin_name,$local_pin_y
    set ruche_idx [expr $j+($HB_RUCHE_LINK_WIDTH_P*2)]
    set ruche_pin [get_pins -of $tile_cell -filter "name=~ruche_link_i[${ruche_idx}]"]
    set ruche_pin_y [get_pin_y $ruche_pin]
    set ruche_pin_name [get_attribute $ruche_pin full_name]
    puts $ruche_pin_name,$ruche_pin_y
  }

  for {set j $HB_RUCHE_LINK_WIDTH_P} {$j < $HB_LINK_WIDTH_P} {incr j} {
    set local_pin [get_pins -of $tile_cell -filter "name=~link_i[$j]"]
    set local_pin_y [get_pin_y $local_pin]
    set local_pin_name [get_attribute $local_pin full_name]
    puts $local_pin_name,$local_pin_y
  }

}
