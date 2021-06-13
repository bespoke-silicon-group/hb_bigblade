puts "BSG-info running user_place_opt_script"

# placement blockage for tie cells (west)
for {set y 0} {$y < 4} {incr y} {
  set mc_cell [get_cells "podrow/px_0__pod/mc_y_${y}__mc_x_0__mc"]
  set cell_llx [get_attribute $mc_cell boundary_bounding_box.ll_x]
  set cell_lly [get_attribute $mc_cell boundary_bounding_box.ll_y]
  set cell_ury [get_attribute $mc_cell boundary_bounding_box.ur_y]

  set llx [expr $cell_llx - 0.252]
  set lly $cell_lly
  set urx [expr $cell_llx]
  set ury $cell_ury
  set boundary [list [list $llx $lly] [list $urx $ury]]
  create_placement_blockage -boundary $boundary -type hard -name "bsg_tile_cell_block_w_${y}"
}

# placement blockage for tie cells (east)
for {set y 0} {$y < 4} {incr y} {
  set mc_cell [get_cells "podrow/px_3__pod/mc_y_${y}__mc_x_0__mc"]
  set cell_urx [get_attribute $mc_cell boundary_bounding_box.ur_x]
  set cell_lly [get_attribute $mc_cell boundary_bounding_box.ll_y]
  set cell_ury [get_attribute $mc_cell boundary_bounding_box.ur_y]

  set llx [expr $cell_urx]
  set lly $cell_lly
  set urx [expr $cell_urx + 0.252]
  set ury $cell_ury
  set boundary [list [list $llx $lly] [list $urx $ury]]
  create_placement_blockage -boundary $boundary -type hard -name "bsg_tile_cell_block_e_${y}"
}



#return




#create_placement -timing_driven
add_tie_cells
legalize_placement -incremental

puts "BSG-info finished user_place_opt_script"
