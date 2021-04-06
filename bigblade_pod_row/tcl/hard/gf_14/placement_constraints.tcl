puts "BSG-info: Running script [info script]\n"

source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_common_variables.tcl
set_app_options -name plan.place.auto_generate_blockages -value false

# Uncomment if you are sourcing this file many times interactively.
#set_fixed_objects -unfix [get_flat_cells]

set  tile_array_width       141.1200
set  vcache_array_width     $tile_array_width
set  sdr_east_west_width    47.0400
set  sdr_north_south_width  141.1200
set  sdr_corner_width       $sdr_east_west_width

set  tile_array_height       377.2800
set  vcache_array_height     146.8800
set  sdr_east_west_height    187.2000
set  sdr_north_south_height  17.2800
set  sdr_corner_height       145.4400

set pod_width    [expr $HB_NUM_TILES_X_P*($tile_width + $tile_x_space) + 2*($sdr_east_west_width + $tile_x_space)]
set pod_height   [expr $HB_NUM_TILES_Y_P*($tile_height + $tile_y_space) + 2*($vcache_height + $vcache_bot_y_space) + 2*($sdr_north_south_height + $tile_y_space) + 10*[unit_height]]

set pod_offset_x [expr $sdr_east_west_width + $tile_x_space]
set pod_offset_y [expr $sdr_north_south_height + $tile_y_space]

# SOUTH SDRS
for {set i 0} {$i < 16} {incr i} {
  move_object [get_cells sdr_s_x_${i}__sdr_s] -x [expr ($i) * ($sdr_north_south_width + $tile_x_space) + $tile_x_space + $sdr_corner_width] -y 0
  set_fixed_objects [get_cells sdr_s_x_${i}__sdr_s]
}

# BOTTOM VCACHE ARRAY
move_object [get_cells podrow/px_0__pod/south_vc_x_0__south_vc_row] -x $pod_offset_x -y $pod_offset_y
set_fixed_objects [get_cells podrow/px_0__pod/south_vc_x_0__south_vc_row]

# TILE ARRAYS
set y [expr $vcache_bot_y_space + $vcache_height + $pod_offset_y]
for {set i 3} {$i >= 0} {incr i -1} {
  move_object [get_cells podrow/px_0__pod/mc_y_${i}__mc_x_0__mc] -x $pod_offset_x -y $y
  set_fixed_objects [get_cells podrow/px_0__pod/mc_y_${i}__mc_x_0__mc]
  set y [expr $y + ($tile_height + $tile_y_space) * 2]
}

# TOP VCACHE ARRAY
move_object [get_cells podrow/px_0__pod/north_vc_x_0__north_vc_row] -x $pod_offset_x -y $y
set_fixed_objects [get_cells podrow/px_0__pod/north_vc_x_0__north_vc_row]

# SW/SE CORNER SDR
move_object [get_cells sdr_sw] -x 0 -y $pod_offset_y
move_object [get_cells sdr_se] -x [expr $pod_width - $sdr_corner_width] -y $pod_offset_y
set_fixed_objects [get_cells sdr_sw]
set_fixed_objects [get_cells sdr_se]

# SDR W/Ef
set y [expr $vcache_bot_y_space + $vcache_height + $pod_offset_y]
for {set i 7} {$i >= 0} {incr i -1} {
  move_object [get_cells sdr_w_y_${i}__sdr_w] -x 0 -y $y
  move_object [get_cells sdr_e_y_${i}__sdr_e] -x [expr $pod_width - $sdr_east_west_width] -y $y
  set_fixed_objects [get_cells sdr_w_y_${i}__sdr_w]
  set_fixed_objects [get_cells sdr_e_y_${i}__sdr_e]
  set y [expr $y + ($tile_height + $tile_y_space)]
}

# NW/NE CORNER SDR
move_object [get_cells sdr_nw] -x 0 -y $y
move_object [get_cells sdr_ne] -x [expr $pod_width - $sdr_corner_width] -y $y
set_fixed_objects [get_cells sdr_nw]
set_fixed_objects [get_cells sdr_ne]

# NORTH SDRS
set y [expr $y + $tile_y_space + $vcache_array_height]
for {set i 0} {$i < 16} {incr i} {
  move_object [get_cells sdr_n_x_${i}__sdr_n] -x [expr ($i) * ($sdr_north_south_width + $tile_x_space) + $tile_x_space + $sdr_corner_width] -y $y
  set_fixed_objects [get_cells sdr_n_x_${i}__sdr_n]
}

#create_bound -name tag_bound -boundary {{1007.3870 1817.7600} {1019.8440 1824.9600}} -type hard
#add_to_bound tag_bound [get_flat_cells btc_n*]

puts "BSG-info: Completed script [info script]\n"
