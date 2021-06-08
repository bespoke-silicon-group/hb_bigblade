puts "BSG-info: Running script [info script]\n"

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
set pod_gap    [expr 13.5*$grid_height]

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

for {set i 0} {$i < 4} {incr i} {
  set row [expr 4-1-$i]
  set                pod_row_cell [get_cells "core_complex_core_${row}__podrow"]
  move_object       $pod_row_cell -x $pod_row_start_x -y [expr $pod_row_start_y+$i*($pod_height+$pod_gap)]
  set_attribute     $pod_row_cell orientation "R0"
  set_fixed_objects $pod_row_cell
}
# FIXME: remove for loop below when real accelerator is added
for {set i 0} {$i < 4} {incr i} {
  set lly [expr $pod_row_start_y+$i*($pod_height+$pod_gap)]
  set ury [expr $pod_row_start_y+$i*($pod_height+$pod_gap)+$pod_height]
  create_placement_blockage -name "pb_pod_west_${i}" -boundary "{{[expr $pod_row_start_x-4*[unit_width]] $lly} {$pod_row_start_x $ury}}"
  create_placement_blockage -name "pb_pod_east_${i}" -boundary "{{[expr $pod_row_start_x+$pod_width] $lly} {[expr $pod_row_start_x+$pod_width+4*[unit_width]] $ury}}"
}


# clk gen placement
set clk_gen_start_x [expr $pod_row_start_x+[round_down_to_nearest [expr $pod_width/2.0] $grid_width]-2*$grid_width]
set clk_gen_start_y [expr $pod_row_start_y+$pod_height+0.5*$grid_height]

for {set i 0} {$i < 4} {incr i} {
  set row [expr 4-1-$i]
  set                clk_gen_cell [get_cells "core_complex_core_${row}__clk_gen"]
  move_object       $clk_gen_cell -x $clk_gen_start_x -y [expr $clk_gen_start_y+$i*($pod_height+$pod_gap)]
  set_attribute     $clk_gen_cell orientation "R0"
  set_fixed_objects $clk_gen_cell
}


# bp blockages
set bp_start_x [expr $core_llx+[round_down_to_nearest $hor_gap $grid_width]]
#for {set i 0} {$i < 4} {incr i} {
#  set lly [expr $pod_row_start_y+$i*($pod_height+$pod_gap)+$sdr_vert_row_height+$vcache_array_height]
#  set ury [expr $pod_row_start_y+$i*($pod_height+$pod_gap)+$sdr_vert_row_height+$vcache_array_height+3.5*$tile_array_height+2*$grid_height]
#  set blockage_dim "{{$bp_start_x $lly} {[expr $pod_row_start_x-0.5*$grid_width] $ury}}"
#  create_placement_blockage -name "pb_bp_block_${i}" -boundary $blockage_dim
#  create_routing_blockage -name rb_bp_block -net_types signal -layers [get_layers] -boundary $blockage_dim
#}


# cgra blockages
set cgra_start_x [expr $pod_row_start_x+$pod_width+0.5*$grid_width]
#for {set i 0} {$i < 4} {incr i} {
#  set lly [expr $core_lly+$bottom_ver_gap+$i*($pod_height+$pod_gap)+$sdr_vert_row_height+$vcache_array_height]
#  set ury [expr $core_lly+$bottom_ver_gap+$i*($pod_height+$pod_gap)+$pod_height-$sdr_vert_row_height-$vcache_array_height]
#  set blockage_dim "{{$cgra_start_x $lly} {[expr $core_urx-$hor_gap] $ury}}"
#  create_placement_blockage -name "pb_cgra_block_${i}" -boundary $blockage_dim
#  create_routing_blockage -name rb_cgra_block -net_types signal -layers [get_layers] -boundary $blockage_dim
#}



# tag_cell placement
set tag_cell_list [get_cells -of_object [get_nets -of_object [get_ports "pad_CT0_1_i_int"]]]
set idx 0
foreach_in_collection tag_cell $tag_cell_list {
  # RESIZE CELL
  size_cell $tag_cell -lib_cell [get_lib_cells */SC7P5T_CKAN2X16_SSC14R]
  set_attribute     $tag_cell orientation R0
  move_object       $tag_cell \
      -x [expr $core_llx+[round_down_to_nearest [expr 5112.742+$idx*5] [unit_width]]] \
      -y [expr $core_lly+[round_down_to_nearest [expr $core_height-2*[unit_height]] [unit_height]]]
  set_fixed_objects $tag_cell
  incr idx
}

# mux placement
set mux_cell_list [get_cells -hier -filter "full_name=~*mux*BSG_DONT_TOUCH*"]
set idx 0
foreach_in_collection mux_cell $mux_cell_list {
  set_attribute     $mux_cell orientation R0
  move_object       $mux_cell \
      -x [expr $core_llx+[round_down_to_nearest [expr 5112.742+$idx*5] [unit_width]]] \
      -y [expr $core_lly+[round_down_to_nearest [expr $core_height-10*[unit_height]] [unit_height]]]
  set_fixed_objects $mux_cell
  incr idx
}


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
    move_object       $mem_cell -x $offset_x -y [expr $core_lly+[round_up_to_nearest [expr $bottom_ver_gap+(3-$j)*($pod_height+$pod_gap)-0.5*$pod_gap-0.5*$noc_mem_height] $grid_height]]
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
move_object       $io_cell -x [expr $core_llx+[round_up_to_nearest 5100 $grid_width]] -y [expr $core_lly+[round_up_to_nearest [expr $core_height-140] $grid_height]]
set_attribute     $io_cell orientation R0
set_fixed_objects $io_cell



# ===============================================
# Create ESD and CDMM cells
# ===============================================

for {set j 0} {$j < 5} {incr j} {
  for {set i 0} {$i < 62} {incr i} {
    create_keepout_margin [create_cell bsg_esd_row_${j}_col_${i} IN12LP_GPIO18_13M9S30P/IN12LP_GPIO18_13M9S30P_CORE_ESDCELL] -outer {0.512 0.512 0.512 0.512}
  }

  for {set i 0} {$i < 5} {incr i} {
    create_keepout_margin [create_cell bsg_cdmm_row_${j}_col_${i} */CDMMTYPE2_32422] -outer {0.2 0.2 0.2 0.2}
  }
}

# ===============================================
# place the esd cells
# ===============================================

set esd_width  72.00
set esd_height 53.00

set esd_start_x    [expr $pod_row_start_x + 162.3]
set esd_step_x     147.84
set esd_start_y    [expr $pod_row_start_y - $esd_height - 10*[unit_height]]
set esd_step_y     [expr $pod_height+$pod_gap]

set esd_curr_y $esd_start_y
for {set j 0} {$j < 5} {incr j} {
  set esd_curr_x $esd_start_x
  for {set i 0} {$i < 62} {incr i} {
    move_object [get_cell bsg_esd_row_${j}_col_${i}] -x $esd_curr_x -y $esd_curr_y
    set esd_curr_x [expr $esd_curr_x + $esd_step_x]
    if {$i == 14 || $i == 15 || $i == 45 || $i == 46} {
      set esd_curr_x [expr $esd_curr_x + 6.72]
    }
    if {$i == 30} {
      set esd_curr_x [expr $esd_curr_x + $esd_step_x + 13.44]
    }
  }
  set esd_curr_y [expr $esd_curr_y + $esd_step_y]
}
set_fixed_objects [get_cells bsg_esd_row_*_col_*]

# ===============================================
# place the cdmm cells
# ===============================================

set cdmm_start_x   $pod_row_start_x
set cdmm_start_y   [expr $pod_row_start_y - 30.94]
set cdmm_step_y    [expr $pod_height+$pod_gap]

set cdmm_curr_y $cdmm_start_y
for {set j 0} {$j < 5} {incr j} {
  move_object [get_cell bsg_cdmm_row_${j}_col_0] -x [expr $cdmm_start_x + 62.05]   -y $cdmm_curr_y
  move_object [get_cell bsg_cdmm_row_${j}_col_1] -x [expr $cdmm_start_x + 2342.84] -y $cdmm_curr_y
  move_object [get_cell bsg_cdmm_row_${j}_col_2] -x [expr $cdmm_start_x + 4805.66] -y $cdmm_curr_y
  move_object [get_cell bsg_cdmm_row_${j}_col_3] -x [expr $cdmm_start_x + 7255.16] -y $cdmm_curr_y
  move_object [get_cell bsg_cdmm_row_${j}_col_4] -x [expr $cdmm_start_x + 9549.27] -y $cdmm_curr_y
  set cdmm_curr_y [expr $cdmm_curr_y + $cdmm_step_y]
}
set_fixed_objects [get_cells bsg_cdmm_row_*_col_*]


puts "BSG-info: Completed script [info script]\n"
