puts "BSG-info: Running script [info script]\n"

source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_common_variables.tcl


initialize_floorplan \
  -control_type core \
  -coincident_boundary true \
  -shape R \
  -side_length [list $sdr_east_west_width $sdr_east_west_height]



puts "BSG-info: Completed script [info script]\n"
