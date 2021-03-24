source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_common_variables.tcl


set buf_cell_width 1.092
set inv_cell_width 0.756
set core_llx [get_attribute [get_core_area]  bounding_box.ll_x]
set core_lly [get_attribute [get_core_area]  bounding_box.ll_y]
set core_urx [get_attribute [get_core_area]  bounding_box.ur_x]
set core_ury [get_attribute [get_core_area]  bounding_box.ur_y]

if {$::env(EAST_NOT_WEST) == 0} { 
  # input
  for {set i 0} {$i < $HB_RUCHE_LINK_WIDTH_P} {incr i} {
    # get y coordinate based on port location
    set idx [expr $i]
    set port [get_port "core_ruche_link_i[$idx]"]
    set y [round_down_to_nearest [get_attribute $port bounding_box.ll_y] 0.48]


    set cell [get_cell "tieoff_west_inv0/hard_hard_${i}__hard_inv"]
    #set_attribute $cell -name physical_status -value placed
    move_object $cell -x [expr $core_urx - $inv_cell_width - 0.084*4] -y $y

    set_attribute $cell -name physical_status -value fixed
  }


  # input
  for {set i 0} {$i < $HB_RUCHE_LINK_WIDTH_P} {incr i} {
    # get y coordinate based on port location
    set idx [expr $i]
    set port [get_port "core_ruche_link_o[$idx]"]
    set y [round_down_to_nearest [get_attribute $port bounding_box.ll_y] 0.48]


    set cell [get_cell "tieoff_west_buf0/hard_hard_${i}__hard_buf"]
    #set_attribute $cell -name physical_status -value placed
    move_object $cell -x [expr $core_urx - $buf_cell_width - 0.084*4] -y $y

    set_attribute $cell -name physical_status -value fixed
  }


}
