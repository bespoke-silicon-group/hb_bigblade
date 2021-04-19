puts "BSG-info: Running script [info script]\n"

source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_common_variables.tcl


if {$::env(EAST_NOT_WEST) == 1} {
  # east
  initialize_floorplan \
    -control_type core \
    -coincident_boundary true \
    -shape R \
    -side_length [list $sdr_horiz_east_width $sdr_horiz_height]
} else {
  # west
  initialize_floorplan \
    -control_type core \
    -coincident_boundary true \
    -shape R \
    -side_length [list [expr $sdr_horiz_west_width] $sdr_horiz_height]
}


puts "BSG-info: Completed script [info script]\n"
