puts "BSG-info: Running script [info script]\n"

set_app_options -name plan.place.auto_generate_blockages -value false

source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_common_variables.tcl

# ==========================================================
# Place Tiles
# ==========================================================

for {set y 0} {$y < $HB_SUBARRAY_NUM_TILES_Y_P} {incr y} {
  for {set x 0} {$x < $HB_SUBARRAY_NUM_TILES_X_P} {incr x} {
    set tile_cell [get_cells "y_${y}__x_${x}__tile"]
    set llx [expr $x * ($tile_width + $tile_x_space)]
    set lly [expr ($HB_SUBARRAY_NUM_TILES_Y_P - $y - 1) * ($tile_height + $tile_y_space)]
    move_objects $tile_cell -x $llx -y $lly
    set_fixed_objects $tile_cell
  }
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

for {set y 0} {$y < $HB_SUBARRAY_NUM_TILES_Y_P} {incr y} {
  for {set x 0} {$x < [expr $HB_SUBARRAY_NUM_TILES_X_P]} {incr x} {
    set tile_cell [get_cells "y_${y}__x_${x}__tile"]
    set tile_lly [get_attribute $tile_cell boundary_bounding_box.ll_y]
    set tile_urx [get_attribute $tile_cell boundary_bounding_box.ur_x]

    set curr_y_track 56
    set x_offset [expr $tile_urx + $RB_RP_X_OFFSET]

    # west side
    for {set b 0} {$b < $HB_RUCHE_LINK_WIDTH_P} {incr b} {
      set buffer_cells [list]
      append_to_collection buffer_cells [get_cells "rr_${y}__rc_${x}__rl_0_*_rb_w_bf_buf0/hard_hard_${b}__hard_buf"]
      append_to_collection buffer_cells [get_cells "rr_${y}__rc_${x}__rl_1_*_rb_w_inv_inv0/hard_hard_${b}__hard_inv"]
      append_to_collection buffer_cells [get_cells "rr_${y}__rc_${x}__rl_2_*_rb_w_inv_inv0/hard_hard_${b}__hard_inv"]

      set rp_name "bsg_rp_rb_w_${y}_${x}_${b}"
      set my_rp [make_rp_array $rp_name $buffer_cells 1 3 "MY"]

      set y_offset [round_down_to_nearest [expr $tile_lly + ($curr_y_track*0.128)] 0.48]
      set_rp_group_options $rp_name -x_offset $x_offset \
                                    -y_offset $y_offset \
                                    -anchor_corner bottom_left

      set curr_y_track [expr $curr_y_track + 4]
    }

    # east side
    for {set b 0} {$b < $HB_RUCHE_LINK_WIDTH_P} {incr b} {
      set buffer_cells [list]
      append_to_collection buffer_cells [get_cells "rr_${y}__rc_${x}__rl_0_*_rb_e_bf_buf0/hard_hard_${b}__hard_buf"]
      append_to_collection buffer_cells [get_cells "rr_${y}__rc_${x}__rl_1_*_rb_e_inv_inv0/hard_hard_${b}__hard_inv"]
      append_to_collection buffer_cells [get_cells "rr_${y}__rc_${x}__rl_2_*_rb_e_inv_inv0/hard_hard_${b}__hard_inv"]

      set rp_name "bsg_rp_rb_e_${y}_${x}_${b}"
      set my_rp [make_rp_array $rp_name $buffer_cells 1 3 "R0"]

      set y_offset [round_down_to_nearest [expr $tile_lly + ($curr_y_track*0.128)] 0.48]
      set_rp_group_options $rp_name -x_offset $x_offset \
                                    -y_offset $y_offset \
                                    -anchor_corner bottom_left

      set curr_y_track [expr $curr_y_track + 4]
    }
  }
}

puts "BSG-info: Completed script [info script]\n"
