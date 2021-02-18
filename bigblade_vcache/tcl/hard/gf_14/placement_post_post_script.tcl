puts "BSG-info: Running script [info script]\n"


source $::env(BSG_DESIGNS_TARGET_TCL_HARD_DIR)/hb_common_variables.tcl

# move tap cells so that it does not overlap with ruche buffers.
for {set y 0} {$y < $HB_NUM_TILES_Y_P} {incr y} {
  for {set x 0} {$x < [expr $HB_NUM_TILES_X_P]} {incr x} {
    set tile_cell [get_cell "pod_mc_y_${y}__x_${x}__tile"]
    set tile_lly [get_attribute $tile_cell boundary_bounding_box.ll_y]
    set tile_urx [get_attribute $tile_cell boundary_bounding_box.ur_x]
    set tile_ury [get_attribute $tile_cell boundary_bounding_box.ur_y]


    set llx $tile_urx
    set lly $tile_lly
    set urx [expr $llx + $tile_x_space]
    set ury $tile_ury
    set search_bbox [list [list $llx $lly] [list $urx $ury]]
    set search_bbox [bsg_expand_bbox $search_bbox 0.01]

    set tap_cells [get_cells -filter "name=~tapfiller*" -within $search_bbox]
    foreach_in_collection tap_cell $tap_cells {
      set_attribute $tap_cell -name physical_status -value placed
      set tap_cell_y [get_attribute $tap_cell boundary_bounding_box.ll_y]
      move_objects $tap_cell -x [expr $llx+$TAPCELL_X_OFFSET] -y $tap_cell_y
      set_attribute $tap_cell -name physical_status -value fixed
    }
  }
}


for {set x 0} {$x < [expr $HB_NUM_TILES_X_P]} {incr x} {
  set tile_cell [get_cell "pod_north_vc_row_vc_x_${x}__vc"]
  set tile_lly [get_attribute $tile_cell boundary_bounding_box.ll_y]
  set tile_urx [get_attribute $tile_cell boundary_bounding_box.ur_x]
  set tile_ury [get_attribute $tile_cell boundary_bounding_box.ur_y]


  set llx $tile_urx
  set lly $tile_lly
  set urx [expr $llx + $vcache_x_space]
  set ury $tile_ury
  set search_bbox [list [list $llx $lly] [list $urx $ury]]
  set search_bbox [bsg_expand_bbox $search_bbox 0.01]

  set tap_cells [get_cells -filter "name=~tapfiller*" -within $search_bbox]
  foreach_in_collection tap_cell $tap_cells {
    set_attribute $tap_cell -name physical_status -value placed
    set tap_cell_y [get_attribute $tap_cell boundary_bounding_box.ll_y]
    move_objects $tap_cell -x [expr $llx+$TAPCELL_X_OFFSET] -y $tap_cell_y
    set_attribute $tap_cell -name physical_status -value fixed
  }
}

for {set x 0} {$x < [expr $HB_NUM_TILES_X_P]} {incr x} {
  set tile_cell [get_cell "pod_south_vc_row_vc_x_${x}__vc"]
  set tile_lly [get_attribute $tile_cell boundary_bounding_box.ll_y]
  set tile_urx [get_attribute $tile_cell boundary_bounding_box.ur_x]
  set tile_ury [get_attribute $tile_cell boundary_bounding_box.ur_y]


  set llx $tile_urx
  set lly $tile_lly
  set urx [expr $llx + $vcache_x_space]
  set ury $tile_ury
  set search_bbox [list [list $llx $lly] [list $urx $ury]]
  set search_bbox [bsg_expand_bbox $search_bbox 0.01]

  set tap_cells [get_cells -filter "name=~tapfiller*" -within $search_bbox]
  foreach_in_collection tap_cell $tap_cells {
    set_attribute $tap_cell -name physical_status -value placed
    set tap_cell_y [get_attribute $tap_cell boundary_bounding_box.ll_y]
    move_objects $tap_cell -x [expr $llx+$TAPCELL_X_OFFSET] -y $tap_cell_y
    set_attribute $tap_cell -name physical_status -value fixed
  }
}



# placement blockage between tiles
for {set y 0} {$y < $HB_NUM_TILES_Y_P} {incr y} {
  for {set x 0} {$x < [expr $HB_NUM_TILES_X_P]} {incr x} {
    set lly [get_attribute [get_cells "pod_mc_y_${y}__x_${x}__tile"] boundary_bounding_box.ll_y]
    set ury [get_attribute [get_cells "pod_mc_y_${y}__x_${x}__tile"] boundary_bounding_box.ur_y]
    
    # left side of buffer
    set llx [get_attribute [get_cells "pod_mc_y_${y}__x_${x}__tile"] boundary_bounding_box.ur_x]
    set urx [expr $llx + $RB_RP_X_OFFSET]
    set boundary [list [list $llx $lly] [list $urx $ury]]
    create_placement_blockage -boundary $boundary -type hard -name "tile_rp_${x}_${y}_left"

    # right side of buffer
    #set xp1 [expr $x+1]
    #set urx [get_attribute [get_cells "pod_mc_y_${y}__x_${xp1}__tile"] boundary_bounding_box.ll_x]
    set urx [expr $llx+$tile_x_space]
    set llx [expr $urx - (0.084*33)]
    set boundary [list [list $llx $lly] [list $urx $ury]]
    create_placement_blockage -boundary $boundary -type hard -name "tile_rp_${x}_${y}_right"
  }
}


# placement blockage between vcaches (north)
for {set x 0} {$x < [expr $HB_NUM_TILES_X_P]} {incr x} {
  set lly [get_attribute [get_cells "pod_north_vc_row_vc_x_${x}__vc"] boundary_bounding_box.ll_y]
  set ury [get_attribute [get_cells "pod_north_vc_row_vc_x_${x}__vc"] boundary_bounding_box.ur_y]

  # left side
  set llx [get_attribute [get_cells "pod_north_vc_row_vc_x_${x}__vc"] boundary_bounding_box.ur_x]
  set urx [expr $llx + $RB_RP_X_OFFSET]
  set boundary [list [list $llx $lly] [list $urx $ury]]
  create_placement_blockage -boundary $boundary -type hard -name "north_vc_rp_${x}_left"
  # right side
  #set xp1 [expr $x+1]
  #set urx [get_attribute [get_cells "pod_north_vc_row_vc_x_${xp1}__vc"] boundary_bounding_box.ll_x]
  set urx [expr $llx+$vcache_x_space]
  set llx [expr $urx - (0.084*46)]
  set boundary [list [list $llx $lly] [list $urx $ury]]
  create_placement_blockage -boundary $boundary -type hard -name "north_vc_rp_${x}_right"
}



# placement blockage between vcaches (south)
for {set x 0} {$x < [expr $HB_NUM_TILES_X_P]} {incr x} {
  set lly [get_attribute [get_cells "pod_south_vc_row_vc_x_${x}__vc"] boundary_bounding_box.ll_y]
  set ury [get_attribute [get_cells "pod_south_vc_row_vc_x_${x}__vc"] boundary_bounding_box.ur_y]

  # left side
  set llx [get_attribute [get_cells "pod_south_vc_row_vc_x_${x}__vc"] boundary_bounding_box.ur_x]
  set urx [expr $llx + $RB_RP_X_OFFSET]
  set boundary [list [list $llx $lly] [list $urx $ury]]
  create_placement_blockage -boundary $boundary -type hard -name "south_vc_rp_${x}_left"
  # right side
  #set xp1 [expr $x+1]
  #set urx [get_attribute [get_cells "pod_south_vc_row_vc_x_${xp1}__vc"] boundary_bounding_box.ll_x]
  set urx [expr $llx+$vcache_x_space]
  set llx [expr $urx - (0.084*46)]
  set boundary [list [list $llx $lly] [list $urx $ury]]
  create_placement_blockage -boundary $boundary -type hard -name "south_vc_rp_${x}_right"
}


set BLOCKAGE_WIDTH 58.24

# placement blockage vcaches (north) (top/bottom side)
for {set x 0} {$x < $HB_NUM_TILES_X_P} {incr x} {
  set vcache_cell [get_cells "pod_north_vc_row_vc_x_${x}__vc"]
  set vcache_llx [get_attribute $vcache_cell boundary_bounding_box.ll_x]
  set vcache_lly [get_attribute $vcache_cell boundary_bounding_box.ll_y]
  set vcache_ury [get_attribute $vcache_cell boundary_bounding_box.ur_y]

  set llx [expr $vcache_llx + $NORTH_INPUT_OFFSET]
  set urx [expr $llx + $BLOCKAGE_WIDTH]

  # top side
  set lly $vcache_ury
  set ury [expr $lly + 0.48]
  set boundary [list [list $llx $lly] [list $urx $ury]]
  create_placement_blockage -boundary $boundary -type hard -name "north_vc_rp_${x}_top_1"

  set ury $core_height
  set lly [expr $ury - 0.48]
  set boundary [list [list $llx $lly] [list $urx $ury]]
  create_placement_blockage -boundary $boundary -type hard -name "north_vc_rp_${x}_top_2"

  # bottom side
  set lly [expr $vcache_lly - $vcache_top_y_space]
  set ury [expr $lly + 0.48]
  set boundary [list [list $llx $lly] [list $urx $ury]]
  create_placement_blockage -boundary $boundary -type hard -name "north_vc_rp_${x}_bottom_1"

  set ury $vcache_lly
  set lly [expr $ury - 0.48]
  set boundary [list [list $llx $lly] [list $urx $ury]]
  create_placement_blockage -boundary $boundary -type hard -name "north_vc_rp_${x}_bottom_2"
}


# placement blockage vcaches (south) (top/bottom side)
for {set x 0} {$x < $HB_NUM_TILES_X_P} {incr x} {
  set vcache_cell [get_cells "pod_south_vc_row_vc_x_${x}__vc"]
  set vcache_llx [get_attribute $vcache_cell boundary_bounding_box.ll_x]
  set vcache_lly [get_attribute $vcache_cell boundary_bounding_box.ll_y]
  set vcache_ury [get_attribute $vcache_cell boundary_bounding_box.ur_y]

  set llx [expr $vcache_llx + $NORTH_INPUT_OFFSET]
  set urx [expr $llx + $BLOCKAGE_WIDTH]

  # top side
  set lly $vcache_ury
  set ury [expr $lly + 0.48]
  set boundary [list [list $llx $lly] [list $urx $ury]]
  create_placement_blockage -boundary $boundary -type hard -name "south_vc_rp_${x}_top_1"

  set ury [expr $vcache_ury + $vcache_bot_y_space]
  set lly [expr $ury - 0.48]
  set boundary [list [list $llx $lly] [list $urx $ury]]
  create_placement_blockage -boundary $boundary -type hard -name "south_vc_rp_${x}_top_2"

  # bottom side
  set lly 0
  set ury 0.48
  set boundary [list [list $llx $lly] [list $urx $ury]]
  create_placement_blockage -boundary $boundary -type hard -name "south_vc_rp_${x}_bottom_1"

  set ury $vcache_lly
  set lly [expr $ury - 0.48]
  set boundary [list [list $llx $lly] [list $urx $ury]]
  create_placement_blockage -boundary $boundary -type hard -name "south_vc_rp_${x}_bottom_2"
}


for {set y 0} {$y < [expr $HB_NUM_TILES_Y_P-1]} {incr y} {
  for {set x 0} {$x < $HB_NUM_TILES_X_P} {incr x} {
    set tile_cell [get_cell "pod_mc_y_${y}__x_${x}__tile"]
    set tile_llx [get_attribute $tile_cell boundary_bounding_box.ll_x]
    set tile_lly [get_attribute $tile_cell boundary_bounding_box.ll_y]


    set llx [expr $tile_llx + $NORTH_INPUT_OFFSET]
    set urx [expr $llx + $BLOCKAGE_WIDTH]

    # bottom side
    set lly [expr $tile_lly - $tile_y_space]
    set ury [expr $lly + 0.48]
    set boundary [list [list $llx $lly] [list $urx $ury]]
    create_placement_blockage -boundary $boundary -type hard -name "tile_rp_${x}_${y}_bottom_1"

    # bottom side
    set ury [expr $tile_lly]
    set lly [expr $ury - 0.48]
    set boundary [list [list $llx $lly] [list $urx $ury]]
    create_placement_blockage -boundary $boundary -type hard -name "tile_rp_${x}_${y}_bottom_2"
  }
}



puts "BSG-info: Completed script [info script]\n"
