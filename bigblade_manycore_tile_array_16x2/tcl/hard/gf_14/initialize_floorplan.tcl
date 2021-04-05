puts "BSG-info: Running script [info script]\n"

source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_common_variables.tcl

set core_height [expr $HB_SUBARRAY_NUM_TILES_Y_P * ($tile_height + $tile_y_space) - $tile_y_space]
set core_width  [expr $HB_SUBARRAY_NUM_TILES_X_P * ($tile_width  + $tile_x_space)]

initialize_floorplan \
  -control_type core \
  -coincident_boundary true \
  -shape R \
  -side_length "$core_width $core_height"

puts "BSG-info: Completed script [info script]\n"
