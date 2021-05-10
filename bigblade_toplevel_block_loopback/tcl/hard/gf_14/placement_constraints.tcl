puts "BSG-info: Running script [info script]\n"

source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_common_variables.tcl
#set_app_options -name plan.place.auto_generate_blockages -value false

# Uncomment if you are sourcing this file many times interactively.
#set_fixed_objects -unfix [get_flat_cells]


# grid_width  = 13.44
# grid_height = 5.76

set core_llx [get_attribute [get_core_area] bounding_box.ll_x]
set core_lly [get_attribute [get_core_area] bounding_box.ll_y]
set core_urx [get_attribute [get_core_area] bounding_box.ur_x]
set core_ury [get_attribute [get_core_area] bounding_box.ur_y]

set edge_offset          237
set io_link_ch_len       1680

set io_link_gap          [expr 10*$grid_width]
set io_link_west_offset  $io_link_gap
set io_link_south_offset $io_link_gap
set io_link_east_offset  [expr $grid_width*(floor(($core_urx-$io_link_gap)/$grid_width-0.5)+0.5)]
set io_link_north_offset [expr $grid_height*(floor(($core_ury-$io_link_gap)/$grid_height-0.5)+0.5)]


# placement blockages
create_placement_blockage -boundary {{369.63 512.44} {9938.87 8013.56}}
create_placement_blockage -boundary {{87.13 657.88 } {369.63 2232.28}}
create_placement_blockage -boundary {{87.13 2523.16} {369.63 4097.56}}
create_placement_blockage -boundary {{87.13 4388.44} {369.63 5962.84}}
create_placement_blockage -boundary {{87.13 6253.72} {369.63 7828.12}}
create_placement_blockage -boundary {{9938.87 657.88 } {10438.87 2232.28}}
create_placement_blockage -boundary {{9938.87 2523.16} {10438.87 4097.56}}
create_placement_blockage -boundary {{9938.87 4388.44} {10438.87 5962.84}}
create_placement_blockage -boundary {{9938.87 6253.72} {10438.87 7828.12}}


create_routing_blockage -layers [get_layers] -boundary {{369.63 512.44} {9938.87 8013.56}}
create_routing_blockage -layers [get_layers] -boundary {{87.13 657.88 } {369.63 2232.28}}
create_routing_blockage -layers [get_layers] -boundary {{87.13 2523.16} {369.63 4097.56}}
create_routing_blockage -layers [get_layers] -boundary {{87.13 4388.44} {369.63 5962.84}}
create_routing_blockage -layers [get_layers] -boundary {{87.13 6253.72} {369.63 7828.12}}
create_routing_blockage -layers [get_layers] -boundary {{9938.87 657.88 } {10438.87 2232.28}}
create_routing_blockage -layers [get_layers] -boundary {{9938.87 2523.16} {10438.87 4097.56}}
create_routing_blockage -layers [get_layers] -boundary {{9938.87 4388.44} {10438.87 5962.84}}
create_routing_blockage -layers [get_layers] -boundary {{9938.87 6253.72} {10438.87 7828.12}}


set                DL01_cell [get_cells "mem_link_0__link"]
move_object       $DL01_cell -x $io_link_west_offset -y [round_up_to_nearest [expr 7828.12+10*$grid_height] $grid_height]
set_attribute     $DL01_cell orientation R0
set_fixed_objects $DL01_cell

set                DL23_cell [get_cells "mem_link_1__link"]
move_object       $DL23_cell -x $io_link_west_offset -y [round_up_to_nearest [expr 4097.56+10*$grid_height] $grid_height]
set_attribute     $DL23_cell orientation R0
set_fixed_objects $DL23_cell

set                DL45_cell [get_cells "mem_link_2__link"]
move_object       $DL45_cell -x $io_link_west_offset -y [round_up_to_nearest [expr 2232.28+10*$grid_height] $grid_height]
set_attribute     $DL45_cell orientation R0
set_fixed_objects $DL45_cell

set                DL67_cell [get_cells "mem_link_3__link"]
move_object       $DL67_cell -x $io_link_west_offset -y [round_up_to_nearest [expr 367.00+10*$grid_height] $grid_height]
set_attribute     $DL67_cell orientation R0
set_fixed_objects $DL67_cell

set                DR01_cell [get_cells "mem_link_4__link"]
move_object       $DR01_cell -x $io_link_east_offset -y [round_up_to_nearest [expr 7828.12+10*$grid_height] $grid_height]
set_attribute     $DR01_cell orientation MY
set_fixed_objects $DR01_cell

set                DR23_cell [get_cells "mem_link_5__link"]
move_object       $DR23_cell -x $io_link_east_offset -y [round_up_to_nearest [expr 4097.56+10*$grid_height] $grid_height]
set_attribute     $DR23_cell orientation MY
set_fixed_objects $DR23_cell

set                DR45_cell [get_cells "mem_link_6__link"]
move_object       $DR45_cell -x $io_link_east_offset -y [round_up_to_nearest [expr 2232.28+10*$grid_height] $grid_height]
set_attribute     $DR45_cell orientation MY
set_fixed_objects $DR45_cell

set                DR67_cell [get_cells "mem_link_7__link"]
move_object       $DR67_cell -x $io_link_east_offset -y [round_up_to_nearest [expr 367.00+10*$grid_height] $grid_height]
set_attribute     $DR67_cell orientation MY
set_fixed_objects $DR67_cell

set                IT01_cell [get_cells "io_link"]
move_object       $IT01_cell -x [round_up_to_nearest 5000 $grid_width] -y [round_up_to_nearest 8250 $grid_height]
set_attribute     $IT01_cell orientation R0
set_fixed_objects $IT01_cell

puts "BSG-info: Completed script [info script]\n"