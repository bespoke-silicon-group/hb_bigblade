puts "BSG-info: Running script [info script]\n"

source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_common_variables.tcl
set_app_options -name plan.place.auto_generate_blockages -value false

# Uncomment if you are sourcing this file many times interactively.
#set_fixed_objects -unfix [get_flat_cells]


# pod offset
set pod_offset_x [expr $sdr_horiz_width + $tile_x_space]
set pod_offset_y [expr $sdr_vert_height + ($grid_height*0.5)]

# SOUTH SDRS
for {set p 0} {$p < $HB_NUM_PODS_X_P} {incr p} {
  set start_x [expr $pod_offset_x + ($tile_array_width+$grid_width)*$p]
  for {set i 0} {$i < $HB_NUM_TILES_X_P} {incr i} {
    set idx [expr $i + ($p*$HB_NUM_TILES_X_P)]
    set sdr_cell [get_cells "sdr_s_x_${idx}__sdr_s"]
    set x [expr $start_x + ($i*($sdr_vert_width+$tile_x_space))]
    move_object $sdr_cell -x $x -y 0
    set_fixed_objects $sdr_cell
  }
}



for {set j 0} {$j < $HB_NUM_PODS_X_P} {incr j} {
  set x [expr $pod_offset_x + $j*($vcache_array_width+$grid_width)]

  # BOTTOM VCACHE ARRAY
  set bot_vcache_array_cell [get_cells "podrow/px_${j}__pod/south_vc_x_0__south_vc_row"]
  move_object $bot_vcache_array_cell -x $x -y $pod_offset_y
  set_fixed_objects $bot_vcache_array_cell

  # TILE ARRAYS
  set y [expr $pod_offset_y + $vcache_array_height + ($grid_height*0.5)]
  for {set i 3} {$i >= 0} {incr i -1} {
    set tile_array_cell [get_cells "podrow/px_${j}__pod/mc_y_${i}__mc_x_0__mc"]
    move_object $tile_array_cell -x $x -y $y
    set_fixed_objects $tile_array_cell
    set y [expr $y + ($tile_array_height) + (0.5*$grid_height)]
  }

  # TOP VCACHE ARRAY
  set top_vcache_array_cell [get_cells "podrow/px_${j}__pod/north_vc_x_0__north_vc_row"]
  move_object $top_vcache_array_cell -x $x -y $y
  set_fixed_objects $top_vcache_array_cell
}


# NORTH SDRS
set y [expr $y + $vcache_array_height + (0.5*$grid_height)]
for {set p 0} {$p < $HB_NUM_PODS_X_P} {incr p} {
  set start_x [expr $pod_offset_x + ($tile_array_width+$grid_width)*$p]
  for {set i 0} {$i < $HB_NUM_TILES_X_P} {incr i} {
    set idx [expr $i + ($p*$HB_NUM_TILES_X_P)]
    set sdr_cell [get_cells "sdr_n_x_${idx}__sdr_n"]
    set x [expr $start_x + ($i*($sdr_vert_width+$tile_x_space))]
    move_object $sdr_cell -x $x -y $y
    set_fixed_objects $sdr_cell
  }
}

# SW/SE CORNER SDR
set sdr_sw_cell [get_cells "sdr_sw"]
set sdr_se_cell [get_cells "sdr_se"]
move_object $sdr_sw_cell -x 0 -y $pod_offset_y
move_object $sdr_se_cell -x [expr $pod_row_width-$sdr_corner_width] -y $pod_offset_y
set_fixed_objects $sdr_sw_cell
set_fixed_objects $sdr_se_cell

# SDR W/E
set y [expr $pod_offset_y + $vcache_array_height + ($grid_height*0.5)]
for {set i [expr $HB_NUM_TILES_Y_P-1]} {$i >= 0} {incr i -1} {
  set sdr_w_cell [get_cells sdr_w_y_${i}__sdr_w]
  set sdr_e_cell [get_cells sdr_e_y_${i}__sdr_e]
  move_object $sdr_w_cell -x 0 -y $y
  move_object $sdr_e_cell -x [expr $pod_row_width - $sdr_horiz_width] -y $y
  set_fixed_objects [get_cells sdr_w_y_${i}__sdr_w]
  set_fixed_objects [get_cells sdr_e_y_${i}__sdr_e]
  set y [expr $y + ($tile_height + $tile_y_space)]
}

# NW/NE CORNER SDR
set sdr_nw_cell [get_cells "sdr_nw"]
set sdr_ne_cell [get_cells "sdr_ne"]
move_object $sdr_nw_cell -x 0 -y $y
move_object $sdr_ne_cell -x [expr $pod_row_width-$sdr_corner_width] -y $y
set_fixed_objects $sdr_nw_cell
set_fixed_objects $sdr_ne_cell

#return
#remove_bounds -all

# bsg tag client bound
set llx [expr ($pod_row_width/2)]
set lly [expr $pod_row_height - $grid_height]
set urx [expr ($pod_row_width/2)+$grid_width]
set ury $pod_row_height
create_bound -name "tag_bound" -boundary [list [list $llx $lly] [list $urx $ury]] -type hard
add_to_bound "tag_bound" [get_flat_cells "tx_0__btc/*"]


# reset dff bound
set llx 0
set lly [expr $pod_row_height-($grid_height/4)]
set urx $pod_row_width
set ury $pod_row_height
create_bound -name "reset_dff_bound" -boundary [list [list $llx $lly] [list $urx $ury]] -type soft
add_to_bound "reset_dff_bound" [get_flat_cells "tx_0__reset_dff/*"]

puts "BSG-info: Completed script [info script]\n"
