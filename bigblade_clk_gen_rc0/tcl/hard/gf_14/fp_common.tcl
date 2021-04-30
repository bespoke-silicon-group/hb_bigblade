puts "BSG-info: Running script [info script]\n"

set decap_boundary_cell */SC7P5T_DECAPSTX8_SSC14R
set filler_x2_cell      */SC7P5T_FILLX2_SSC14R
set filler_x3_cell      */SC7P5T_FILLX3_SSC14R
set tap_cell            */SC7P5T_TAPX14_SSC14R

set tap_w   [get_attr $tap_cell            width]
set decap_w [get_attr $decap_boundary_cell width]

set core_die_offset_x 0
set core_die_offset_y 0

set bounds_w 17.724
set bounds_h  7.680
set bounds_offset_x [expr $core_die_offset_x + $decap_w + $tap_w]
set bounds_offset_y [expr $core_die_offset_y + [unit_height]]

set block_w [expr $bounds_w + 2*$decap_w + $tap_w]
set block_h [expr $bounds_h + 2*[unit_height]]

puts "BSG-info: Completed script [info script]\n"
