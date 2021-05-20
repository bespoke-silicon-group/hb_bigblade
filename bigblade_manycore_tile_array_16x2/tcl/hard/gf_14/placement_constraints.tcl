puts "BSG-info: Running script [info script]\n"

set_app_options -name plan.place.auto_generate_blockages -value false

source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_common_variables.tcl

# ==========================================================
# Place Tiles
# ==========================================================

for {set y 0} {$y < $HB_SUBARRAY_NUM_TILES_Y_P} {incr y} {
  for {set x 0} {$x < $HB_SUBARRAY_NUM_TILES_X_P} {incr x} {
    set tile_cell [get_cells "y_${y}__x_${x}__tile"]
    set llx [expr $x * ($tile_x_pitch)]
    set lly [expr ($HB_SUBARRAY_NUM_TILES_Y_P - $y - 1) * ($tile_height + $tile_y_space)]
    move_objects $tile_cell -x $llx -y $lly
    set_fixed_objects $tile_cell
  }
}

# ==========================================================
# PROC MAKE RP ARRAY
# ==========================================================

proc make_rp_array {rp_name cells row col} {
  create_rp_group  -name $rp_name -rows $row -columns $col
  set r 0
  set c 0
  foreach_in_collection cell $cells {
    add_to_rp_group $rp_name -cells $cell -column $c -row $r
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
    set x_offset [expr $tile_urx + 11*[unit_width]]

    # west side
    for {set b 0} {$b < $HB_RUCHE_LINK_WIDTH_P} {incr b} {
      set buffer_cells [list]
      append_to_collection buffer_cells [get_cells "rr_${y}__rc_${x}__rl_0_*_rb_w_bf_buf0/hard_hard_${b}__hard_buf"]
      append_to_collection buffer_cells [get_cells "rr_${y}__rc_${x}__rl_1_*_rb_w_inv_inv0/hard_hard_${b}__hard_inv"]
      append_to_collection buffer_cells [get_cells "rr_${y}__rc_${x}__rl_2_*_rb_w_inv_inv0/hard_hard_${b}__hard_inv"]
      if {[expr $HB_SUBARRAY_NUM_TILES_X_P-1] == $x} {
        append_to_collection buffer_cells [get_cells "lr_${y}__lb_w/hard_hard_${b}__hard_buf"]
      }
      set rp_name "bsg_rp_rb_w_${y}_${x}_${b}"
      set my_rp [make_rp_array $rp_name $buffer_cells 1 [sizeof_collection $buffer_cells]]

      set y_offset [round_down_to_nearest [expr $tile_lly + ($curr_y_track*0.128)] 0.48]
      set_rp_group_options $rp_name -x_offset $x_offset \
                                    -y_offset $y_offset \
                                    -anchor_corner bottom_left \
                                    -optimization_restriction no_opt
      set curr_y_track [expr $curr_y_track + 4]
    }

    # leftover local buffers
    if {$x == [expr $HB_SUBARRAY_NUM_TILES_X_P-1]} {
      set buffer_cells [list]
      for {set b $HB_RUCHE_LINK_WIDTH_P} {$b < $HB_LINK_WIDTH_P} {incr b} {
        append_to_collection buffer_cells [get_cells "lr_${y}__lb_w/hard_hard_${b}__hard_buf"]
      }
      set rp_name "bsg_lb_w_${y}"
      set my_rp [make_rp_array $rp_name $buffer_cells 5 3]
      set y_offset [round_down_to_nearest [expr $tile_lly + ($curr_y_track*0.128)] 0.48]
      set_rp_group_options $rp_name -x_offset $x_offset \
                                    -y_offset $y_offset \
                                    -anchor_corner bottom_left \
                                    -optimization_restriction no_opt
    }



    # east side
    set curr_y_track [expr $curr_y_track + 24]
    for {set b 0} {$b < $HB_RUCHE_LINK_WIDTH_P} {incr b} {
      set buffer_cells [list]
      append_to_collection buffer_cells [get_cells "rr_${y}__rc_${x}__rl_0_*_rb_e_bf_buf0/hard_hard_${b}__hard_buf"]
      append_to_collection buffer_cells [get_cells "rr_${y}__rc_${x}__rl_1_*_rb_e_inv_inv0/hard_hard_${b}__hard_inv"]
      append_to_collection buffer_cells [get_cells "rr_${y}__rc_${x}__rl_2_*_rb_e_inv_inv0/hard_hard_${b}__hard_inv"]
      if {[expr $HB_SUBARRAY_NUM_TILES_X_P-1] == $x} {
        append_to_collection buffer_cells [get_cells "lr_${y}__lb_e/hard_hard_${b}__hard_buf"]
      }

      set rp_name "bsg_rp_rb_e_${y}_${x}_${b}"
      set my_rp [make_rp_array $rp_name $buffer_cells 1 [sizeof_collection $buffer_cells]]

      set y_offset [round_down_to_nearest [expr $tile_lly + ($curr_y_track*0.128)] 0.48]
      set_rp_group_options $rp_name -x_offset $x_offset \
                                    -y_offset $y_offset \
                                    -anchor_corner bottom_left \
                                    -optimization_restriction no_opt

      set curr_y_track [expr $curr_y_track + 4]
    }

    # leftover local buffers
    if {$x == [expr $HB_SUBARRAY_NUM_TILES_X_P-1]} {
      set buffer_cells [list]
      for {set b $HB_RUCHE_LINK_WIDTH_P} {$b < $HB_LINK_WIDTH_P} {incr b} {
        append_to_collection buffer_cells [get_cells "lr_${y}__lb_e/hard_hard_${b}__hard_buf"]
      }
      set rp_name "bsg_lb_e_${y}"
      set my_rp [make_rp_array $rp_name $buffer_cells 5 3]
      set y_offset [round_down_to_nearest [expr $tile_lly + ($curr_y_track*0.128)] 0.48]
      set_rp_group_options $rp_name -x_offset $x_offset \
                                    -y_offset $y_offset \
                                    -anchor_corner bottom_left \
                                    -optimization_restriction no_opt
    }

  }
}









puts "BSG-info: Completed script [info script]\n"
