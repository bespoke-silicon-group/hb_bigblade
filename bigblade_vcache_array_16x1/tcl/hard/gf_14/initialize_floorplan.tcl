puts "BSG-info: Running script [info script]\n"

source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_common_variables.tcl

set core_width  [expr $HB_SUBARRAY_NUM_TILES_X_P * ($vcache_width  + $vcache_x_space)]
set core_height [expr $vcache_height + $vcache_top_y_space/2.0]

initialize_floorplan \
  -control_type core \
  -coincident_boundary true \
  -shape R \
  -side_length "$core_width $core_height"

puts "BSG-info: Completed script [info script]\n"
