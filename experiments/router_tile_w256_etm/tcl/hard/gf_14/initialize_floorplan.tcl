puts "BSG-info: Running script [info script]\n"

source -echo -verbose $::env(BSG_DESIGNS_TARGET_TCL_HARD_DIR)/fp_common.tcl

initialize_floorplan \
  -control_type core \
  -coincident_boundary true \
  -shape R \
  -side_length "$tile_w $tile_h"

puts "BSG-info: Completed script [info script]\n"
