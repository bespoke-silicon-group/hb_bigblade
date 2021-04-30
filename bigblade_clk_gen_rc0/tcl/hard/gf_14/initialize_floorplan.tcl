puts "BSG-info: Running script [info script]\n"

source -echo -verbose $::env(BSG_DESIGNS_TARGET_TCL_HARD_DIR)/fp_common.tcl

initialize_floorplan \
  -control_type core \
  -coincident_boundary true \
  -shape R \
  -side_length "$block_w $block_h" \
  -core_offset "$core_die_offset_x $core_die_offset_y"

puts "BSG-info: Completed script [info script]\n"
