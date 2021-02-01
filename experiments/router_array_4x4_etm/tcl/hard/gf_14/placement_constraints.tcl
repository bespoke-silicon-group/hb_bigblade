puts "BSG-info: Running script [info script]\n"

set_app_options -name plan.place.auto_generate_blockages -value false

source -echo -verbose $::env(BSG_DESIGNS_TARGET_TCL_HARD_DIR)/fp_common.tcl

set tiles [get_cells "*__tile"]
#for {set r [expr $num_tiles_y_p-1]} {$r >= 0} {incr r -1} {
#  for {set c 0} {$c < $num_tiles_x_p} {incr c} {
#    append_to_collection tiles [get_cells "y_${r}__x_${c}__tile"]
#  }
#}

set tile_array [create_macro_array \
  -num_rows $num_tiles_y_p \
  -num_cols $num_tiles_x_p \
  -align bottom \
  -horizontal_channel_height [expr $tile_gap_y] \
  -vertical_channel_width [expr $tile_gap_x] \
  -orientation N \
  $tiles]

set_macro_relative_location \
  -target_object $tile_array \
  -target_corner bl \
  -target_orientation R0 \
  -anchor_corner bl \
  -offset "$init_gap_x $init_gap_y"

puts "BSG-info: Completed script [info script]\n"
