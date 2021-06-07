puts "BSG-info: Running script [info script]\n"

########################################
## Source common scripts
source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_common_variables.tcl

#set tile_width 400
#set tile_width [round_up_to_nearest [expr 4*($data_mem_width + 2*$keepout_margin_x)+2*$keepout_margin_x] [unit_width]]
#set tile_height [round_up_to_nearest [expr 8*($data_mem_height + 2*$keepout_margin_y)+2*$keepout_margin_y] [unit_height]]
#set tile_width [round_up_to_nearest 325 [unit_width]]
#set tile_width [round_up_to_nearest 300 [unit_width]]
#set tile_width [round_up_to_nearest 325 [unit_width]]
#set tile_height [round_up_to_nearest 500 [unit_height]]
#set tile_height [round_up_to_nearest [expr 4*($data_mem_height + 2*$keepout_margin_y)+2*$keepout_margin_y+2*($int_regfile_height + $keepout_margin_y)] [unit_height]]
#set tile_height [round_up_to_nearest 578.304 [unit_height]]

set bp_tile_width [expr [round_up_to_nearest 282.24 [unit_width]]]
set bp_tile_height [round_up_to_nearest [expr 3*($tile_height + $tile_y_space)-$tile_y_space] [unit_height]]

initialize_floorplan        \
  -control_type die         \
  -coincident_boundary true \
  -shape R                  \
  -core_offset 0.0          \
  -side_length [list $bp_tile_width $bp_tile_height]

puts "BSG-info: Completed script [info script]\n"