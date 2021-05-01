puts "BSG-info: Running script [info script]\n"

source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_common_variables.tcl

set edge_offset          237
set die_width            11000
set die_height           9000
set die_block_width      [expr $die_width-2*$edge_offset]
set die_block_height     [expr $die_height-2*$edge_offset]

initialize_floorplan \
  -control_type core \
  -coincident_boundary true \
  -shape R \
  -side_length [list $die_block_width $die_block_height]



puts "BSG-info: Completed script [info script]\n"
