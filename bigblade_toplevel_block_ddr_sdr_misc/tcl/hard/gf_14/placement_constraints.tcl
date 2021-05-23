puts "BSG-info: Running script [info script]\n"

source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_common_variables.tcl
#set_app_options -name plan.place.auto_generate_blockages -value false

# Uncomment if you are sourcing this file many times interactively.
#set_fixed_objects -unfix [get_flat_cells]



# core area 
set core_llx [get_attribute [get_core_area] bounding_box.ll_x]
set core_lly [get_attribute [get_core_area] bounding_box.ll_y]
set core_urx [get_attribute [get_core_area] bounding_box.ur_x]
set core_ury [get_attribute [get_core_area] bounding_box.ur_y]



# block dimensions
set bp_width   295.68
set cgra_width 510.72
set pod_width  9612.46

set pod_height 1865.28
set pod_gap    134.72

set noc_mem_width  107.52
set noc_mem_height 155.52

set core_width  [expr $core_urx-$core_llx]
set core_height [expr $core_ury-$core_lly]

set hor_gap [expr ($core_width-$bp_width-$cgra_width-$pod_width)/2]
set ver_gap [expr ($core_height-4*$pod_height-3*$pod_gap)/2]



# pod blockages
set blockage_dim "{{[expr $core_llx+$hor_gap+$bp_width] [expr $core_lly+$ver_gap]} {[expr $core_urx-$hor_gap-$cgra_width] [expr $core_ury-$ver_gap]}}"
create_placement_blockage -boundary $blockage_dim
create_routing_blockage -layers [get_layers] -boundary $blockage_dim

# bp blockages
for {set i 0} {$i < 4} {incr i} {
  set lly [expr $core_lly+$ver_gap+$i*($pod_height+$pod_gap)+$vcache_height]
  set ury [expr $core_lly+$ver_gap+$i*($pod_height+$pod_gap)+$pod_height-$vcache_height-$tile_height]
  set blockage_dim "{{[expr $core_llx+$hor_gap] $lly} {[expr $core_llx+$hor_gap+$bp_width] $ury}}"
  create_placement_blockage -boundary $blockage_dim
  create_routing_blockage -layers [get_layers] -boundary $blockage_dim
}

# cgra blockages
for {set i 0} {$i < 4} {incr i} {
  set lly [expr $core_lly+$ver_gap+$i*($pod_height+$pod_gap)+$vcache_height]
  set ury [expr $core_lly+$ver_gap+$i*($pod_height+$pod_gap)+$pod_height-$vcache_height]
  set blockage_dim "{{[expr $core_urx-$hor_gap-$cgra_width] $lly} {[expr $core_urx-$hor_gap] $ury}}"
  create_placement_blockage -boundary $blockage_dim
  create_routing_blockage -layers [get_layers] -boundary $blockage_dim
}



# tag_cell placement
set                TAG_cell [get_cells -of_object [get_nets -of_object [get_ports "pad_ML0_1_i_int"]]]
set_attribute     $TAG_cell orientation R0
move_object       $TAG_cell \
    -x [expr $core_llx+[round_down_to_nearest 1404.742 [unit_width]]] \
    -y [expr $core_lly+[round_down_to_nearest [expr $core_height-2*[unit_height]] [unit_height]]]
set_fixed_objects $TAG_cell



# noc_mem placement
set noc_mem_west_x [expr $core_llx+[round_up_to_nearest $hor_gap $grid_width]]
set noc_mem_east_x [expr $core_llx+[round_down_to_nearest [expr $core_width-$hor_gap] $grid_width]-0.5*$grid_width]

for {set i 0} {$i < 2} {incr i} {

  set offset_x [expr {$i == 0} ? {$noc_mem_west_x} : {$noc_mem_east_x}]
  set ori [expr {$i == 0} ? {"R0"} : {"MY"}]
  set                mem_cell [get_cells "mem_link_[expr 0+$i*4]__link"]
  move_object       $mem_cell -x $offset_x -y [expr $core_lly+[round_up_to_nearest [expr $core_height-10*$grid_height-$noc_mem_height] $grid_height]]
  set_attribute     $mem_cell orientation $ori
  set_fixed_objects $mem_cell

  for {set j 1} {$j < 3} {incr j} {
    set                mem_cell [get_cells "mem_link_[expr $j+$i*4]__link"]
    move_object       $mem_cell -x $offset_x -y [expr $core_lly+[round_up_to_nearest [expr $ver_gap+(3-$j)*($pod_height+$pod_gap)-0.5*$pod_gap-0.5*$noc_mem_height] $grid_height]]
    set_attribute     $mem_cell orientation $ori
    set_fixed_objects $mem_cell
  }

  set offset_x [expr {$i == 0} ? {[expr $core_llx+100.5*$grid_width]} : {[expr $core_llx+667*$grid_width]}]
  set ori [expr {$i == 0} ? {"MY"} : {"R0"}]
  set                mem_cell [get_cells "mem_link_[expr 3+$i*4]__link"]
  move_object       $mem_cell -x $offset_x -y [expr $core_lly+10*$grid_height]
  set_attribute     $mem_cell orientation $ori
  set_fixed_objects $mem_cell
}



# noc_io placement
set                io_cell [get_cells "io_link"]
move_object       $io_cell -x [expr $core_llx+[round_up_to_nearest 5000 $grid_width]] -y [expr $core_lly+[round_up_to_nearest [expr $core_height-160] $grid_height]]
set_attribute     $io_cell orientation R0
set_fixed_objects $io_cell



# sdr placement
set noc_io_west_x  [expr $core_llx+[round_down_to_nearest [expr $hor_gap+$bp_width+$noc_mem_width-$grid_width] $grid_width]]
set noc_io_east_x  [expr $core_llx+[round_up_to_nearest [expr $core_width-$hor_gap-$cgra_width-$noc_mem_width+$grid_width] $grid_width]]

set                WEST_cell [get_cells "west_link"]
move_object       $WEST_cell -x [expr $noc_io_west_x-$noc_mem_width] -y [expr $core_lly+[round_up_to_nearest [expr $core_height-$ver_gap-$vcache_height-$tile_height+$grid_height] $grid_height]]
set_attribute     $WEST_cell orientation R0
set_fixed_objects $WEST_cell

set                NORTH_cell [get_cells "north_link"]
move_object       $NORTH_cell -x [expr $core_llx+300*$grid_width] -y [expr $core_lly+[round_up_to_nearest [expr $core_height-$ver_gap+$grid_height] $grid_height]]
set_attribute     $NORTH_cell orientation R0
set_fixed_objects $NORTH_cell



for {set i 0} {$i < 2} {incr i} {

  set offset_x [expr {$i == 0} ? {$noc_io_west_x} : {$noc_io_east_x}]
  set ori [expr {$i == 0} ? {"MY"} : {"R0"}]
  set                wh_cell [get_cells "wh_link_[expr 0+$i*5]__link"]
  move_object       $wh_cell -x $offset_x -y [expr $core_lly+[round_up_to_nearest [expr $core_height-$ver_gap-$vcache_height+2*$grid_height] $grid_height]]
  set_attribute     $wh_cell orientation $ori
  set_fixed_objects $wh_cell

  for {set j 1} {$j < 4} {incr j} {
    set                wh_cell [get_cells "wh_link_[expr $j+$i*5]__link"]
    move_object       $wh_cell -x $offset_x -y [expr $core_lly+[round_up_to_nearest [expr $ver_gap+(4-$j)*($pod_height+$pod_gap)-0.5*$pod_gap-0.5*$noc_mem_height] $grid_height]]
    set_attribute     $wh_cell orientation $ori
    set_fixed_objects $wh_cell
  }

  set                wh_cell [get_cells "wh_link_[expr 4+$i*5]__link"]
  move_object       $wh_cell -x $offset_x -y [expr $core_lly+[round_down_to_nearest [expr $ver_gap+$vcache_height-$noc_mem_height-$grid_height] $grid_height]]
  set_attribute     $wh_cell orientation $ori
  set_fixed_objects $wh_cell
}


puts "BSG-info: Completed script [info script]\n"
