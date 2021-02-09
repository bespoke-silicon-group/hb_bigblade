puts "BSG-info: Running script [info script]\n"

source -echo -verbose $::env(BSG_DESIGNS_TARGET_TCL_HARD_DIR)/hb_common_variables.tcl


initialize_floorplan \
  -control_type core \
  -coincident_boundary true \
  -shape R \
  -side_length [list $tile_width $tile_height]\
  -core_utilization 0.80



puts "BSG-info: Completed script [info script]\n"
