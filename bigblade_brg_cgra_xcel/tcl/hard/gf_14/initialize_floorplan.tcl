puts "BSG-info: Running script [info script]\n"

########################################
## Source common scripts
source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_common_variables.tcl

# constraints
set keepout_margin_x [expr 6*[unit_width]]
set keepout_margin_y [expr 1*[unit_height]]
set keepout_margins [list $keepout_margin_x $keepout_margin_y $keepout_margin_x $keepout_margin_y]

set cgra_tile_width [round_up_to_nearest 450 [unit_height]]
set cgra_tile_height [round_up_to_nearest [expr 4*($tile_height + $tile_y_space)-$tile_y_space] [unit_height]]

initialize_floorplan        \
  -control_type die         \
  -coincident_boundary true \
  -shape R                  \
  -core_offset 0.0          \
  -side_length [list $cgra_tile_width $cgra_tile_height]

puts "BSG-info: Completed script [info script]\n"

