puts "BSG-info: Running script [info script]\n"



source $::env(BSG_DESIGNS_TARGET_TCL_HARD_DIR)/hb_common_variables.tcl



###   local proc
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



# MANYCORE TILE RUCHE buffers
for {set y 0} {$y < $HB_NUM_TILES_Y_P} {incr y} {
  for {set x 0} {$x < [expr $HB_NUM_TILES_X_P]} {incr x} {
    set tile_cell [get_cells "pod_mc_y_${y}__x_${x}__tile"] 
    set tile_lly [get_attribute $tile_cell boundary_bounding_box.ll_y]
    set tile_urx [get_attribute $tile_cell boundary_bounding_box.ur_x]


    set curr_y_track 56
    set x_offset [expr $tile_urx + $RB_RP_X_OFFSET]


    # to west
    for {set b 0} {$b < $HB_RUCHE_LINK_WIDTH_P} {incr b} {
      set buffer_cells [list]
      append_to_collection buffer_cells [get_cells "pod_mc_rr_${y}__rc_${x}__rl_0_*_rb_w_bf_buf0/hard_hard_${b}__hard_buf"]
      append_to_collection buffer_cells [get_cells "pod_mc_rr_${y}__rc_${x}__rl_1_*_rb_w_inv_inv0/hard_hard_${b}__hard_inv"]
      append_to_collection buffer_cells [get_cells "pod_mc_rr_${y}__rc_${x}__rl_2_*_rb_w_inv_inv0/hard_hard_${b}__hard_inv"]
    
      set rp_name "bsg_rp_rb_w_${y}_${x}_${b}"
      set my_rp [make_rp_array $rp_name $buffer_cells 1 3 "MY"]

      set y_offset [round_down_to_nearest [expr $tile_lly + ($curr_y_track*0.128)] 0.48]
      set_rp_group_options $rp_name -x_offset $x_offset \
                                    -y_offset $y_offset \
                                    -anchor_corner bottom_left
    
      set curr_y_track [expr $curr_y_track + 4]
    }

    # to east
    for {set b 0} {$b < $HB_RUCHE_LINK_WIDTH_P} {incr b} {
      set buffer_cells [list]
      append_to_collection buffer_cells [get_cells "pod_mc_rr_${y}__rc_${x}__rl_0_*_rb_e_bf_buf0/hard_hard_${b}__hard_buf"]
      append_to_collection buffer_cells [get_cells "pod_mc_rr_${y}__rc_${x}__rl_1_*_rb_e_inv_inv0/hard_hard_${b}__hard_inv"]
      append_to_collection buffer_cells [get_cells "pod_mc_rr_${y}__rc_${x}__rl_2_*_rb_e_inv_inv0/hard_hard_${b}__hard_inv"]
    
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





# NORTH VC ruche buffers
for {set x 0} {$x < [expr $HB_NUM_TILES_X_P]} {incr x} {
  set vc_cell [get_cells "pod_north_vc_row_vc_x_${x}__vc"]
  set vc_lly [get_attribute $vc_cell boundary_bounding_box.ll_y]
  set vc_urx [get_attribute $vc_cell boundary_bounding_box.ur_x]

  set curr_y_track 240
  set x_offset [expr $vc_urx + $RB_RP_X_OFFSET]


  # to west
  for {set b 0} {$b < $HB_WH_LINK_WIDTH_P} {incr b} {
      set buffer_cells [list]
      append_to_collection buffer_cells [get_cells "pod_north_vc_row_rc_${x}__rl_0_*_rb_w_inv_inv0/hard_hard_${b}__hard_inv"]
      append_to_collection buffer_cells [get_cells "pod_north_vc_row_rc_${x}__rl_1_*_rb_w_inv_inv0/hard_hard_${b}__hard_inv"]
    
      set rp_name "bsg_north_vc_rp_rb_w_${y}_${x}_${b}"
      set my_rp [make_rp_array $rp_name $buffer_cells 1 2 "MY"]

      set y_offset [round_down_to_nearest [expr $vc_lly + ($curr_y_track*0.128)] 0.48]
      set_rp_group_options $rp_name -x_offset $x_offset \
                                    -y_offset $y_offset \
                                    -anchor_corner bottom_left
    
      set curr_y_track [expr $curr_y_track + 4]
  }

  # to east
  for {set b 0} {$b < $HB_WH_LINK_WIDTH_P} {incr b} {
      set buffer_cells [list]
      append_to_collection buffer_cells [get_cells "pod_north_vc_row_rc_${x}__rl_0_*_rb_e_inv_inv0/hard_hard_${b}__hard_inv"]
      append_to_collection buffer_cells [get_cells "pod_north_vc_row_rc_${x}__rl_1_*_rb_e_inv_inv0/hard_hard_${b}__hard_inv"]
    
      set rp_name "bsg_north_vc_rp_rb_e_${y}_${x}_${b}"
      set my_rp [make_rp_array $rp_name $buffer_cells 1 2 "R0"]

      set y_offset [round_down_to_nearest [expr $vc_lly + ($curr_y_track*0.128)] 0.48]
      set_rp_group_options $rp_name -x_offset $x_offset \
                                    -y_offset $y_offset \
                                    -anchor_corner bottom_left
    
      set curr_y_track [expr $curr_y_track + 4]
  }
}



# SOUTH VC ruche buffers
for {set x 0} {$x < [expr $HB_NUM_TILES_X_P]} {incr x} {
  set vc_cell [get_cells "pod_south_vc_row_vc_x_${x}__vc"]
  set vc_lly [get_attribute $vc_cell boundary_bounding_box.ll_y]
  set vc_urx [get_attribute $vc_cell boundary_bounding_box.ur_x]

  set curr_y_track 240
  set x_offset [expr $vc_urx + $RB_RP_X_OFFSET]


  # to west
  for {set b 0} {$b < $HB_WH_LINK_WIDTH_P} {incr b} {
      set buffer_cells [list]
      append_to_collection buffer_cells [get_cells "pod_south_vc_row_rc_${x}__rl_0_*_rb_w_inv_inv0/hard_hard_${b}__hard_inv"]
      append_to_collection buffer_cells [get_cells "pod_south_vc_row_rc_${x}__rl_1_*_rb_w_inv_inv0/hard_hard_${b}__hard_inv"]
    
      set rp_name "bsg_south_vc_rp_rb_w_${y}_${x}_${b}"
      set my_rp [make_rp_array $rp_name $buffer_cells 1 2 "MY"]

      set y_offset [round_down_to_nearest [expr $vc_lly + ($curr_y_track*0.128)] 0.48]
      set_rp_group_options $rp_name -x_offset $x_offset \
                                    -y_offset $y_offset \
                                    -anchor_corner bottom_left
    
      set curr_y_track [expr $curr_y_track + 4]
  }

  # to east
  for {set b 0} {$b < $HB_WH_LINK_WIDTH_P} {incr b} {
      set buffer_cells [list]
      append_to_collection buffer_cells [get_cells "pod_south_vc_row_rc_${x}__rl_0_*_rb_e_inv_inv0/hard_hard_${b}__hard_inv"]
      append_to_collection buffer_cells [get_cells "pod_south_vc_row_rc_${x}__rl_1_*_rb_e_inv_inv0/hard_hard_${b}__hard_inv"]
    
      set rp_name "bsg_south_vc_rp_rb_e_${y}_${x}_${b}"
      set my_rp [make_rp_array $rp_name $buffer_cells 1 2 "R0"]

      set y_offset [round_down_to_nearest [expr $vc_lly + ($curr_y_track*0.128)] 0.48]
      set_rp_group_options $rp_name -x_offset $x_offset \
                                    -y_offset $y_offset \
                                    -anchor_corner bottom_left
    
      set curr_y_track [expr $curr_y_track + 4]
  }
}




puts "BSG-info: Completed script [info script]\n"
