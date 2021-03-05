puts "BSG-info: Running script [info script]\n"

source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_common_variables.tcl


initialize_floorplan \
  -control_type core \
  -coincident_boundary true \
  -shape R \
  -side_length [list $vcache_width $vcache_height]



puts "BSG-info: Completed script [info script]\n"
