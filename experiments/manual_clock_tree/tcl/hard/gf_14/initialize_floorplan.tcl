#source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_common_variables.tcl

set grid_width  [expr 28*[unit_height]]
set grid_height [expr 12*[unit_height]]
set  tile_array_width         [expr $grid_width*176.5]
set  tile_array_height        [expr $grid_height*65.5]


initialize_floorplan \
  -control_type core \
  -coincident_boundary true \
  -shape R \
  -side_length "$tile_array_width $tile_array_height"

