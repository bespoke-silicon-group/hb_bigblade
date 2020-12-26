puts "BSG-info: Running script [info script]\n"


source -echo -verbose $::env(BSG_DESIGNS_TARGET_TCL_HARD_DIR)/hb_common_variables.tcl

# bot vcache
for {set x 0} {$x < $HB_NUM_TILES_X_P} {incr x} {
  set vcache_cell [get_cells "pod/south_vc_row/vc_x_${x}__vc"]
  set llx [expr $bot_vcache_llx+($x*($vcache_width+$vcache_x_space))]
  set lly [expr $bot_vcache_lly]
  set urx [expr $llx + $vcache_width]
  set ury [expr $lly + $vcache_height]

  if {$x == 0} {
    set_block_boundary -cell $vcache_cell -boundary [list [list $llx $lly] [list $urx $ury]]
  }

  move_objects $vcache_cell -x $llx -y $lly
}


# tile array
for {set y 0} {$y < $HB_NUM_TILES_Y_P} {incr y} {
  for {set x 0} {$x < $HB_NUM_TILES_X_P} {incr x} {
    set tile_cell [get_cells "pod/mc/y_${y}__x_${x}__tile"]
    
    set llx [expr ($tile_array_llx+($x*($tile_width+$tile_x_space)))]
    set lly [expr ($tile_array_lly+(($HB_NUM_TILES_Y_P-$y-1)*($tile_height+$tile_y_space)))]
    set urx [expr $llx + ($tile_width)]
    set ury [expr $lly + ($tile_height)]

    if {$x == 0 && $y == 0} {
      set_block_boundary -cell $tile_cell -boundary [list [list $llx $lly] [list $urx $ury]]
    }
    move_objects $tile_cell -x $llx -y $lly
  }
}

# bot vcache
for {set x 0} {$x < $HB_NUM_TILES_X_P} {incr x} {
  set vcache_cell [get_cells "pod/north_vc_row/vc_x_${x}__vc"]
  set llx [expr $top_vcache_llx+($x*($vcache_width+$vcache_x_space))]
  set lly [expr $top_vcache_lly]
  set urx [expr $llx + $vcache_width]
  set ury [expr $lly + $vcache_height]

  move_objects $vcache_cell -x $llx -y $lly
}





puts "BSG-info: Completed script [info script]\n"
