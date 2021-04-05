puts "BSG-info: Running script [info script]\n"

source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_common_variables.tcl

# ==========================================================
# MOVE TAP CELLS SO THAT IT DOES NOT OVERLAP WITH RUCHE BUFFERS.
# ==========================================================

for {set x 0} {$x < [expr $HB_SUBARRAY_NUM_TILES_X_P]} {incr x} {
  set tile_cell [get_cell "vc_x_${x}__vc"]
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

# ==========================================================
# PLACEMENT BLOCKAGE BETWEEN TILES
# ==========================================================

for {set x 0} {$x < [expr $HB_SUBARRAY_NUM_TILES_X_P]} {incr x} {
  set lly [get_attribute [get_cells "vc_x_${x}__vc"] boundary_bounding_box.ll_y]
  set ury [get_attribute [get_cells "vc_x_${x}__vc"] boundary_bounding_box.ur_y]

  # left side
  set llx [get_attribute [get_cells "vc_x_${x}__vc"] boundary_bounding_box.ur_x]
  set urx [expr $llx + $RB_RP_X_OFFSET]
  set boundary [list [list $llx $lly] [list $urx $ury]]
  create_placement_blockage -boundary $boundary -type hard -name "vc_rp_${x}_left"

  # right side
  set urx [expr $llx+$vcache_x_space]
  set llx [expr $urx - (0.084*46)]
  set boundary [list [list $llx $lly] [list $urx $ury]]
  create_placement_blockage -boundary $boundary -type hard -name "vc_rp_${x}_right"
}

puts "BSG-info: Completed script [info script]\n"
