puts "BSG-info: Running script [info script]\n"

set tile_w 141.120
set tile_h 187.200

set width_p 34

set num_tiles_x_p 4
set num_tiles_y_p 4

set init_gap_x 13.440
set init_gap_y 11.520

set tile_gap_x 6.720
set tile_gap_y 8.640

set core_width  [expr $num_tiles_x_p*$tile_w + ($num_tiles_x_p-1)*$tile_gap_x + 2*$init_gap_x]
set core_height [expr $num_tiles_y_p*$tile_h + ($num_tiles_y_p-1)*$tile_gap_y + 2*$init_gap_y]

puts "BSG-info: Completed script [info script]\n"
