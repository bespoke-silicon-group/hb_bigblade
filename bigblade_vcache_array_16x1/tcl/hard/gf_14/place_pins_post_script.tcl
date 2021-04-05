puts "BSG-info: Running script [info script]\n"

source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_common_variables.tcl

# ==========================================================
# REALIGN NORTH VCACHE RUCHE BUFFERS NEXT TO THE CORESSPONDING PINS
# ==========================================================

for {set x 0} {$x < [expr $HB_SUBARRAY_NUM_TILES_X_P]} {incr x} {

  set tile_cell [get_cell "vc_x_${x}__vc"]
  set tile_urx [get_attribute $tile_cell boundary_bounding_box.ur_x]
  set tile_lly [get_attribute $tile_cell boundary_bounding_box.ll_y]
  set tile_ury [get_attribute $tile_cell boundary_bounding_box.ur_y]
  set rp_x [expr $tile_urx + $RB_RP_X_OFFSET]

  for {set b 0} {$b < $HB_WH_LINK_WIDTH_P} {incr b} {
    set rp_name "bsg_north_vc_rp_rb_w_${x}_${b}"
    set rp_group [get_rp_groups $rp_name]
    set pin_idx [expr $b + $HB_WH_LINK_WIDTH_P]
    set pin [get_pins -of $tile_cell -filter "name==wh_link_sif_i[${pin_idx}]"]
    set rp_y [round_down_to_nearest [get_attribute $pin bounding_box.ll_y] 0.48]

    set_rp_group_options $rp_name -x_offset $rp_x -y_offset $rp_y
    move_objects $rp_group -x $rp_x -y $rp_y
  }

  for {set b 0} {$b < $HB_WH_LINK_WIDTH_P} {incr b} {
    set rp_name "bsg_north_vc_rp_rb_e_${x}_${b}"
    set rp_group [get_rp_groups $rp_name]
    set pin_idx [expr $b + $HB_WH_LINK_WIDTH_P]
    set pin [get_pins -of $tile_cell -filter "name==wh_link_sif_o[${pin_idx}]"]
    set rp_y [round_down_to_nearest [get_attribute $pin bounding_box.ll_y] 0.48]

    set_rp_group_options $rp_name -x_offset $rp_x -y_offset $rp_y
    move_objects $rp_group -x $rp_x -y $rp_y
  }
}

puts "BSG-info: Completed script [info script]\n"
