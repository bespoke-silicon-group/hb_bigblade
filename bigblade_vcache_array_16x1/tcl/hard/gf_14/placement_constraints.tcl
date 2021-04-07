puts "BSG-info: Running script [info script]\n"

set_app_options -name plan.place.auto_generate_blockages -value false

source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_common_variables.tcl

# ==========================================================
# Place Tiles
# ==========================================================

for {set x 0} {$x < $HB_SUBARRAY_NUM_TILES_X_P} {incr x} {
  set vcache_cell [get_cells "vc_y_0__vc_x_${x}__vc"]
  set llx [expr ($x*($vcache_width+$vcache_x_space))]
  set lly 0
  set urx [expr $llx + $vcache_width]
  set ury [expr $lly + $vcache_height]

  move_objects $vcache_cell -x $llx -y $lly
  set_fixed_objects $vcache_cell
}

# ==========================================================
# PROC MAKE RP ARRAY
# ==========================================================

proc make_rp_array {rp_name cells row col orientation} {
  create_rp_group  -name $rp_name -rows $row -columns $col
  set r 0
  set c 0
  foreach_in_collection cell $cells {
    add_to_rp_group $rp_name -cells $cell -column $c -row $r -orientation $orientation
    if {$c == [expr $col-1]} {
      set c 0
      incr r
    } else {
      incr c
    }
  }
}

# ==========================================================
# CREATE RUCHE BUFFER RP GROUPS
# ==========================================================

for {set x 0} {$x < [expr $HB_SUBARRAY_NUM_TILES_X_P]} {incr x} {
  set vc_cell [get_cells "vc_y_0__vc_x_${x}__vc"]
  set vc_lly [get_attribute $vc_cell boundary_bounding_box.ll_y]
  set vc_urx [get_attribute $vc_cell boundary_bounding_box.ur_x]

  set curr_y_track 240
  set x_offset [expr $vc_urx + $RB_RP_X_OFFSET]


  # west side
  for {set b 0} {$b < $HB_WH_LINK_WIDTH_P} {incr b} {
      set buffer_cells [list]
      append_to_collection buffer_cells [get_cells "rr_0__rc_${x}__rl_0_*_rb_w_inv_inv0/hard_hard_${b}__hard_inv"]
      append_to_collection buffer_cells [get_cells "rr_0__rc_${x}__rl_1_*_rb_w_inv_inv0/hard_hard_${b}__hard_inv"]

      set rp_name "bsg_north_vc_rp_rb_w_${x}_${b}"
      set my_rp [make_rp_array $rp_name $buffer_cells 1 2 "MY"]

      set y_offset [round_down_to_nearest [expr $vc_lly + ($curr_y_track*0.128)] 0.48]
      set_rp_group_options $rp_name -x_offset $x_offset \
                                    -y_offset $y_offset \
                                    -anchor_corner bottom_left

      set curr_y_track [expr $curr_y_track + 4]
  }

  # east side
  for {set b 0} {$b < $HB_WH_LINK_WIDTH_P} {incr b} {
      set buffer_cells [list]
      append_to_collection buffer_cells [get_cells "rr_0__rc_${x}__rl_0_*_rb_e_inv_inv0/hard_hard_${b}__hard_inv"]
      append_to_collection buffer_cells [get_cells "rr_0__rc_${x}__rl_1_*_rb_e_inv_inv0/hard_hard_${b}__hard_inv"]

      set rp_name "bsg_north_vc_rp_rb_e_${x}_${b}"
      set my_rp [make_rp_array $rp_name $buffer_cells 1 2 "R0"]

      set y_offset [round_down_to_nearest [expr $vc_lly + ($curr_y_track*0.128)] 0.48]
      set_rp_group_options $rp_name -x_offset $x_offset \
                                    -y_offset $y_offset \
                                    -anchor_corner bottom_left

      set curr_y_track [expr $curr_y_track + 4]
  }
}

puts "BSG-info: Completed script [info script]\n"
