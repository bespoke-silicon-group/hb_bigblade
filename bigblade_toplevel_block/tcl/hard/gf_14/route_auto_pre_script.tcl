puts "BSG-info running [info script]"

derive_pin_access_routing_guides -cells [get_cells "mem_link_*__link"] -layers {K1 K3} -x_width [expr 0.084*4] -y_width 0.001

#derive_pin_access_routing_guides -cells [get_cells "io_link"] -layers {K1 K3} -x_width [expr 0.084*4] -y_width 0.001
#derive_pin_access_routing_guides -cells [get_cells "io_link"] -layers {K2 K4} -x_width 0.001 -y_width [expr 0.084*4]

derive_pin_access_routing_guides -cells [get_cells "core_complex_core_0__podrow"] -layers {K1 K3} -x_width [expr 0.084*4] -y_width 0.001




source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_common_variables.tcl
set_app_options -name plan.place.auto_generate_blockages -value false

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
set pod_width  $pod_row_width

set pod_height $pod_row_height
set pod_gap    [expr 17.5*$grid_height]

set noc_mem_width  [expr 8*$grid_width]
set noc_mem_height [expr 27*$grid_height]

set core_width  [expr $core_urx-$core_llx]
set core_height [expr $core_ury-$core_lly]

set ver_shift 0
set hor_gap [expr ($core_width-$bp_width-$cgra_width-$pod_width)/2]
set bottom_ver_gap [expr ($core_height-4*$pod_height-3*$pod_gap)/2-$ver_shift]


# pod row placement
set pod_row_start_x [expr $core_llx+[round_down_to_nearest [expr $hor_gap+$bp_width] $grid_width]]
set pod_row_start_y [expr $core_lly+[round_down_to_nearest $bottom_ver_gap $grid_height]]

for {set i 1} {$i < 4} {incr i} {
  set lly [expr $pod_row_start_y+$i*($pod_height+$pod_gap)-$pod_gap]
  set ury [expr $pod_row_start_y+$i*($pod_height+$pod_gap)]
  # gap routing blockages
  #create_routing_blockage -name rb_pod_gap -layers [get_layers {M2 C4 K1 K3 H1 G1}] -boundary "{{$pod_row_start_x $lly} {[expr $pod_row_start_x+0.5*$pod_width-200] $ury}}"
  # gap placement blockages
  create_placement_blockage -name "pb_pod_gap_${i}_start" -boundary "{{$pod_row_start_x $lly} {[expr $pod_row_start_x+39] $ury}}"
  set curr_llx [expr $pod_row_start_x+95]
  for {set j 0} {$j < 64} {incr j} {
    create_placement_blockage -name "pb_pod_gap_${i}_${j}" -boundary "{{$curr_llx $lly} {[expr $curr_llx+60] $ury}}"
    set curr_llx [expr $curr_llx+11*$grid_width]
    if {[expr $j%16] == 15} { set curr_llx [expr $curr_llx+$grid_width] }
  }
  create_placement_blockage -name "pb_pod_gap_${i}_end" -boundary "{{[expr $pod_row_start_x+$pod_width-42] $lly} {[expr $pod_row_start_x+$pod_width] $ury}}"
  #create_routing_blockage -name rb_clk_gen -layers [get_layers] -boundary "{{5225 $lly} {5269 $ury}}"
}


# bp blockages
set bp_start_x [expr $core_llx+[round_down_to_nearest $hor_gap $grid_width]]
for {set i 0} {$i < 4} {incr i} {
  set lly [expr $pod_row_start_y+$i*($pod_height+$pod_gap)+$sdr_vert_row_height+$vcache_array_height]
  set ury [expr $pod_row_start_y+$i*($pod_height+$pod_gap)+$sdr_vert_row_height+$vcache_array_height+3.5*$tile_array_height+2*$grid_height]
  # gap routing blockages
  create_routing_blockage -name rb_bp_gap -layers [get_layers {M3 C5 K2 K4 H2 G2}] -boundary "{{[expr $pod_row_start_x-0.5*$grid_width] $lly} {$pod_row_start_x $ury}}"
}


# cgra blockages
set cgra_start_x [expr $pod_row_start_x+$pod_width+0.5*$grid_width]
for {set i 0} {$i < 4} {incr i} {
  set lly [expr $core_lly+$bottom_ver_gap+$i*($pod_height+$pod_gap)+$sdr_vert_row_height+$vcache_array_height]
  set ury [expr $core_lly+$bottom_ver_gap+$i*($pod_height+$pod_gap)+$pod_height-$sdr_vert_row_height-$vcache_array_height]
  # gap routing blockages
  create_routing_blockage -name rb_cgra_gap -layers [get_layers {M3 C5 K2 K4 H2 G2}] -boundary "{{[expr $cgra_start_x-0.5*$grid_width] $lly} {$cgra_start_x $ury}}"
}



#set esd_width  72.00
#set esd_height 53.00
#
#set esd_start_x    [expr $pod_row_start_x + 162.3]
#set esd_step_x     147.84
#set esd_start_y    [expr $pod_row_start_y - ($pod_gap+$esd_height)/2]
#set esd_step_y     [expr $pod_height+$pod_gap]
#
#set esd_curr_y $esd_start_y
#for {set j 0} {$j < 5} {incr j} {
#  set esd_curr_x $esd_start_x
#  for {set i 0} {$i < 62} {incr i} {
#    set esd_curr_x [expr $esd_curr_x + $esd_step_x]
#    if {$i == 14 || $i == 15 || $i == 45 || $i == 46} {
#      set esd_curr_x [expr $esd_curr_x + 6.72]
#    }
#    if {$i == 30} {
#      set esd_curr_x [expr $esd_curr_x + $esd_step_x + 13.44]
#    }
#  }
#  create_routing_blockage -layers [get_layers {M2 C4 K1 K3 H1 G1}] -boundary "{{$esd_start_x $esd_curr_y} {[expr $esd_curr_x-$esd_step_x+$esd_width] [expr $esd_curr_y+$esd_height]}}"
#  set esd_curr_y [expr $esd_curr_y + $esd_step_y]
#}



set TCL_USER_ROUTE_AUTO_SCRIPT "$::env(BSG_DESIGNS_TARGET_TCL_HARD_DIR)/user_route_auto_script.tcl"
set REDUNDANT_VIA_INSERTION 0
set ROUTE_AUTO_CREATE_SHIELDS "none"

puts "BSG-info finished [info script]"
