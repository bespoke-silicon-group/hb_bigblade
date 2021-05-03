puts "BSG-info: Running script [info script]\n"

source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_common_variables.tcl

if {$::env(EAST_NOT_WEST) == 1} {

  initialize_floorplan \
    -control_type core \
    -coincident_boundary true \
    -shape R \
    -side_length [list $sdr_corner_east_width $sdr_corner_height]

} else {

  initialize_floorplan \
    -control_type core \
    -coincident_boundary true \
    -shape R \
    -side_length [list $sdr_corner_west_width $sdr_corner_height]

}


puts "BSG-info: Completed script [info script]\n"
