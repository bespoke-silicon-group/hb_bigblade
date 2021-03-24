puts "BSG-info: Running script [info script]\n"

########################################
## Source common scripts
source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_common_variables.tcl

# constraints
set keepout_margin_x [expr 6*[unit_width]]
set keepout_margin_y [expr 1*[unit_height]]
set keepout_margins [list $keepout_margin_x $keepout_margin_y $keepout_margin_x $keepout_margin_y]

set dcache_data_mems [get_cells -hier -filter "ref_name=~gf14_* && full_name=~*dcache*data_mem*"]

set data_mem_width         [lindex [get_attribute [get_cell -hier $dcache_data_mems] width ] 0]
set data_mem_height        [lindex [get_attribute [get_cell -hier $dcache_data_mems] height] 0]

set int_regfile [get_cells -hier -filter "ref_name=~gf14_* && full_name=~*int_regfile*"]
set int_regfile_width         [lindex [get_attribute [get_cell -hier $int_regfile] width ] 0]
set int_regfile_height        [lindex [get_attribute [get_cell -hier $int_regfile] height] 0]

#set tile_width 400
#set tile_width [round_up_to_nearest [expr 4*($data_mem_width + 2*$keepout_margin_x)+2*$keepout_margin_x] [unit_width]]
#set tile_height [round_up_to_nearest [expr 8*($data_mem_height + 2*$keepout_margin_y)+2*$keepout_margin_y] [unit_height]]
#set tile_width [round_up_to_nearest 325 [unit_width]]
#set tile_width [round_up_to_nearest 300 [unit_width]]
#set tile_width [round_up_to_nearest 325 [unit_width]]
#set tile_height [round_up_to_nearest 500 [unit_height]]
#set tile_height [round_up_to_nearest [expr 4*($data_mem_height + 2*$keepout_margin_y)+2*$keepout_margin_y+2*($int_regfile_height + $keepout_margin_y)] [unit_height]]
#set tile_height [round_up_to_nearest 578.304 [unit_height]]

set bp_tile_width [round_up_to_nearest 277.5174 [unit_width]]
set bp_tile_height [round_up_to_nearest [expr 3*($tile_height + $tile_y_space)-$tile_y_space] [unit_height]]

initialize_floorplan        \
  -control_type die         \
  -coincident_boundary true \
  -shape R                  \
  -core_offset 0.0          \
  -side_length [list $bp_tile_width $bp_tile_height]

puts "BSG-info: Completed script [info script]\n"

