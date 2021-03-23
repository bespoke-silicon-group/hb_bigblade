source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_common_variables.tcl

# place wh ruche buffers

set inv_cell_width 0.756
set core_llx [get_attribute [get_core_area]  bounding_box.ll_x]
set core_lly [get_attribute [get_core_area]  bounding_box.ll_y]
set core_urx [get_attribute [get_core_area]  bounding_box.ur_x]
set core_ury [get_attribute [get_core_area]  bounding_box.ur_y]


# input
for {set i 0} {$i < $HB_WH_LINK_WIDTH_P} {incr i} {
  # get y coordinate based on port location
  set idx [expr $i + $HB_WH_LINK_WIDTH_P]
  set port [get_port "core_wh_link_sif_i[$idx]"]
  set y [round_down_to_nearest [get_attribute $port bounding_box.ll_y] 0.128]


  set cell [get_cell "hard_inv_in/hard_hard_${i}__hard_inv"]
  #set_attribute $cell -name physical_status -value placed
  if {$::env(EAST_NOT_WEST) == 1} {
    move_object $cell -x [expr $core_llx + 0.084*4] -y $y
  } else {
    move_object $cell -x [expr $core_urx - $inv_cell_width - 0.084*4] -y $y
  }

  set_attribute $cell -name physical_status -value fixed
}


# output
for {set i 0} {$i < $HB_WH_LINK_WIDTH_P} {incr i} {
  # get y coordinate based on port location
  set idx [expr $i + $HB_WH_LINK_WIDTH_P]
  set port [get_port "core_wh_link_sif_o[$idx]"]
  set y [round_down_to_nearest [get_attribute $port bounding_box.ll_y] 0.128]


  set cell [get_cell "hard_inv_out/hard_hard_${i}__hard_inv"]
  #set_attribute $cell -name physical_status -value placed
  if {$::env(EAST_NOT_WEST) == 1} {
    move_object $cell -x [expr $core_llx + 0.084*4] -y $y
  } else {
    move_object $cell -x [expr $core_urx - $inv_cell_width - 0.084*4] -y $y
  }

  set_attribute $cell -name physical_status -value fixed
}
