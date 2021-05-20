puts "BSG-info: Running script [info script]\n"

set grid_w [expr 160 * [unit_width] ]
set grid_h [expr 12  * [unit_height]]

set decap_boundary_cell         */SC7P5T_DECAPSTX32_SSC14R
set decap_top_bot_boundary_cell */SC7P5T_DECAPSTX16_SSC14R ;# We can get a higher density using this cell because of the tap cells
set filler_x2_cell              */SC7P5T_FILLX2_SSC14R
set filler_x3_cell              */SC7P5T_FILLX3_SSC14R
set tap_cell                    */SC7P5T_TAPX14_SSC14R

set decap_w [get_attr $decap_boundary_cell width]
set tap_w [get_attr $tap_cell width]

set core_die_offset_x 0
set core_die_offset_y 0

set block_w [expr 2 * $grid_w]
set block_h [expr 22 * [unit_height]]

puts "BSG-info: Completed script [info script]\n"
