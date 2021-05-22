puts "BSG-info: Running script [info script]\n"

source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_common_variables.tcl

# ==========================================================
# MOVE TAP CELLS SO THAT IT DOES NOT OVERLAP WITH RUCHE BUFFERS.
# ==========================================================

for {set y 0} {$y < $HB_SUBARRAY_NUM_TILES_Y_P} {incr y} {
  for {set x 0} {$x < [expr $HB_SUBARRAY_NUM_TILES_X_P]} {incr x} {
    set tile_cell [get_cell "y_${y}__x_${x}__tile"]
    set tile_lly [get_attribute $tile_cell boundary_bounding_box.ll_y]
    set tile_urx [get_attribute $tile_cell boundary_bounding_box.ur_x]
    set tile_ury [get_attribute $tile_cell boundary_bounding_box.ur_y]


    set llx $tile_urx
    set lly $tile_lly
    set urx [expr $llx + $tile_x_space]
    set ury $tile_ury
    set search_bbox [list [list $llx $lly] [list $urx $ury]]
    set search_bbox [bsg_expand_bbox $search_bbox 0.01]


    if {$x == [expr $HB_SUBARRAY_NUM_TILES_X_P-1]} {
      set tapx [expr $tile_array_width-1.176]
    } else {
      set tapx [expr $llx+(0.084*42)]
    }
    set tap_cells [get_cells -filter "name=~tapfiller*" -within $search_bbox]
    foreach_in_collection tap_cell $tap_cells {
      set_attribute $tap_cell -name physical_status -value placed
      set tap_cell_y [get_attribute $tap_cell boundary_bounding_box.ll_y]
      move_objects $tap_cell -x $tapx -y $tap_cell_y
      set_attribute $tap_cell -name physical_status -value fixed
    }
  }
}


# ==========================================================
# PLACEMENT BLOCKAGE BETWEEN TILES
# ==========================================================

for {set y 0} {$y < $HB_SUBARRAY_NUM_TILES_Y_P} {incr y} {
  for {set x 0} {$x < [expr $HB_SUBARRAY_NUM_TILES_X_P]} {incr x} {
    set lly [get_attribute [get_cells "y_${y}__x_${x}__tile"] boundary_bounding_box.ll_y]
    set ury [get_attribute [get_cells "y_${y}__x_${x}__tile"] boundary_bounding_box.ur_y]

    # left side of buffer
    set llx [get_attribute [get_cells "y_${y}__x_${x}__tile"] boundary_bounding_box.ur_x]
    set urx [expr $llx + (0.084*11)]
    set boundary [list [list $llx $lly] [list $urx $ury]]
    create_placement_blockage -boundary $boundary -type hard -name "tile_rp_${x}_${y}_left"

    # right side of buffer
    if {$x == [expr $HB_SUBARRAY_NUM_TILES_X_P-1]} {
      set urx [expr $tile_array_width]
      set llx [expr $urx - (0.084*25)]
    } else {
      set urx [expr $llx+(0.084*58)]
      set llx [expr $urx-(0.084*16)]
    }
    set boundary [list [list $llx $lly] [list $urx $ury]]
    create_placement_blockage -boundary $boundary -type hard -name "tile_rp_${x}_${y}_right"
  }
}

puts "BSG-info: Completed script [info script]\n"
