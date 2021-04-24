

#set_app_options -name plan.place.auto_generate_blockages -value false
proc round_y {y} {
  return [round_down_to_nearest $y 0.48]
}

proc round_x {x} {
  return [round_down_to_nearest $x 0.084]
}



for {set x 0} {$x < 8} {incr x} {
  for {set y 0} {$y < 2} {incr y} {
    set dff_cell [get_cells "data_r_reg_${x}__${y}_"]
    set my_x [round_x [expr 263*($x+1)]]
    set my_y [round_y [expr 130*($y+1)]]
    move_objects $dff_cell -x $my_x -y $my_y
    set_fixed_objects $dff_cell
  }
}
