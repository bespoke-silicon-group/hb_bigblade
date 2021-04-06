puts "BSG-info: Running script [info script]\n"

source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_common_variables.tcl

set  tile_array_width       141.1200
set  vcache_array_width     $tile_array_width
set  sdr_east_west_width    47.0400
set  sdr_north_south_width  141.1200
set  sdr_corner_width       $sdr_east_west_width

set  tile_array_height       377.2800
set  vcache_array_height     146.8800
set  sdr_east_west_height    187.2000
set  sdr_north_south_height  17.2800
set  sdr_corner_height       145.4400

set  pod_width   [expr $HB_NUM_TILES_X_P*($tile_width + $tile_x_space) + 2*($sdr_east_west_width + $tile_x_space)]
set  pod_height  [expr $HB_NUM_TILES_Y_P*($tile_height + $tile_y_space) + 2*($vcache_height + $vcache_bot_y_space) + 2*($sdr_north_south_height + $tile_y_space) + 10*[unit_height]]

initialize_floorplan \
  -control_type core \
  -coincident_boundary true \
  -shape R \
  -side_length "$pod_width $pod_height"

puts "BSG-info: Completed script [info script]\n"
