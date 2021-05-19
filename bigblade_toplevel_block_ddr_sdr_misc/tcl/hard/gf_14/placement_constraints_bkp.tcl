puts "BSG-info: Running script [info script]\n"

source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_common_variables.tcl
#set_app_options -name plan.place.auto_generate_blockages -value false

# Uncomment if you are sourcing this file many times interactively.
#set_fixed_objects -unfix [get_flat_cells]


# grid_width  = 13.44
# grid_height = 5.76

# core_width  10526.04
# core_height 8526.24

set core_llx [get_attribute [get_core_area] bounding_box.ll_x]
set core_lly [get_attribute [get_core_area] bounding_box.ll_y]
set core_urx [get_attribute [get_core_area] bounding_box.ur_x]
set core_ury [get_attribute [get_core_area] bounding_box.ur_y]

set edge_offset          237
set io_link_ch_len       1680

set io_link_gap          [expr 5*$grid_width]
set io_link_west_offset  $io_link_gap
set io_link_south_offset $io_link_gap
set io_link_east_offset  [expr $grid_width*(floor(($core_urx-$io_link_gap)/$grid_width-0.5)+0.5)]
set io_link_north_offset [expr $grid_height*(floor(($core_ury-$io_link_gap)/$grid_height-0.5)+0.5)]


# placement blockages
create_placement_blockage -boundary {{349.44 328.32} {9972.62 8193.60}}
create_placement_blockage -boundary {{53.76  463.04} {349.44 2058.88}}
create_placement_blockage -boundary {{53.76 2463.04} {349.44 4058.88}}
create_placement_blockage -boundary {{53.76 4463.04} {349.44 6058.88}}
create_placement_blockage -boundary {{53.76 6463.04} {349.44 7868.80}}
create_placement_blockage -boundary {{9972.62  463.04} {10472.62 2058.88}}
create_placement_blockage -boundary {{9972.62 2463.04} {10472.62 4058.88}}
create_placement_blockage -boundary {{9972.62 4463.04} {10472.62 6058.88}}
create_placement_blockage -boundary {{9972.62 6463.04} {10472.62 8058.88}}


create_routing_blockage -layers [get_layers] -boundary {{349.44 328.32} {9972.62 8193.60}}
create_routing_blockage -layers [get_layers] -boundary {{53.76  463.04} {349.44 2058.88}}
create_routing_blockage -layers [get_layers] -boundary {{53.76 2463.04} {349.44 4058.88}}
create_routing_blockage -layers [get_layers] -boundary {{53.76 4463.04} {349.44 6058.88}}
create_routing_blockage -layers [get_layers] -boundary {{53.76 6463.04} {349.44 7868.80}}
create_routing_blockage -layers [get_layers] -boundary {{9972.62  463.04} {10472.62 2058.88}}
create_routing_blockage -layers [get_layers] -boundary {{9972.62 2463.04} {10472.62 4058.88}}
create_routing_blockage -layers [get_layers] -boundary {{9972.62 4463.04} {10472.62 6058.88}}
create_routing_blockage -layers [get_layers] -boundary {{9972.62 6463.04} {10472.62 8058.88}}


# FIXME: cell name is hardcoded
set                TAG_AND_cell [get_cells -of_object [get_nets -of_object [get_ports "pad_ML0_1_i_int"]]]
move_object       $TAG_AND_cell -x [round_down_to_nearest 1335.27 [unit_width]] -y [round_down_to_nearest [expr $core_ury-2*[unit_height]] [unit_height]]
set_attribute     $TAG_AND_cell orientation R0
set_fixed_objects $TAG_AND_cell


set                DL01_cell [get_cells "mem_link_0__link"]
move_object       $DL01_cell -x $io_link_west_offset -y [round_up_to_nearest [expr $core_ury-40*$grid_height] $grid_height]
set_attribute     $DL01_cell orientation R0
set_fixed_objects $DL01_cell

set                DL23_cell [get_cells "mem_link_1__link"]
move_object       $DL23_cell -x $io_link_west_offset -y [round_up_to_nearest [expr 4058.88+15*$grid_height] $grid_height]
set_attribute     $DL23_cell orientation R0
set_fixed_objects $DL23_cell

set                DL45_cell [get_cells "mem_link_2__link"]
move_object       $DL45_cell -x $io_link_west_offset -y [round_up_to_nearest [expr 2058.88+15*$grid_height] $grid_height]
set_attribute     $DL45_cell orientation R0
set_fixed_objects $DL45_cell

set                DL67_cell [get_cells "mem_link_3__link"]
move_object       $DL67_cell -x [expr 100.5*$grid_width] -y [expr 10*$grid_height]
set_attribute     $DL67_cell orientation MY
set_fixed_objects $DL67_cell

set                DR01_cell [get_cells "mem_link_4__link"]
move_object       $DR01_cell -x $io_link_east_offset -y [round_up_to_nearest [expr $core_ury-40*$grid_height] $grid_height]
set_attribute     $DR01_cell orientation MY
set_fixed_objects $DR01_cell

set                DR23_cell [get_cells "mem_link_5__link"]
move_object       $DR23_cell -x $io_link_east_offset -y [round_up_to_nearest [expr 4058.88+15*$grid_height] $grid_height]
set_attribute     $DR23_cell orientation MY
set_fixed_objects $DR23_cell

set                DR45_cell [get_cells "mem_link_6__link"]
move_object       $DR45_cell -x $io_link_east_offset -y [round_up_to_nearest [expr 2058.88+15*$grid_height] $grid_height]
set_attribute     $DR45_cell orientation MY
set_fixed_objects $DR45_cell

set                DR67_cell [get_cells "mem_link_7__link"]
move_object       $DR67_cell -x [expr 667*$grid_width] -y [expr 10*$grid_height]
set_attribute     $DR67_cell orientation R0
set_fixed_objects $DR67_cell

set                IT01_cell [get_cells "io_link"]
move_object       $IT01_cell -x [round_up_to_nearest 5000 $grid_width] -y [round_up_to_nearest 8364.96 $grid_height]
set_attribute     $IT01_cell orientation R0
set_fixed_objects $IT01_cell


set wh_link_west_offset  [expr $io_link_west_offset+8*$grid_width+20*$grid_width]
set wh_link_east_offset  [expr $io_link_east_offset-8*$grid_width-35*$grid_width]

set                WEST_wh_cell [get_cells "west_link"]
move_object       $WEST_wh_cell -x [expr 25*$grid_width] -y [round_up_to_nearest [expr 7868.80+1*$grid_height] $grid_height]
set_attribute     $WEST_wh_cell orientation R0
set_fixed_objects $WEST_wh_cell

set                NORTH_wh_cell [get_cells "north_link"]
move_object       $NORTH_wh_cell -x [expr 300*$grid_width] -y [round_up_to_nearest [expr 8193.60+1*$grid_height] $grid_height]
set_attribute     $NORTH_wh_cell orientation R0
set_fixed_objects $NORTH_wh_cell

set                DL0_wh_cell [get_cells "wh_link_0__link"]
move_object       $DL0_wh_cell -x $wh_link_west_offset -y [round_up_to_nearest [expr 8058.88+2*$grid_height] $grid_height]
set_attribute     $DL0_wh_cell orientation MY
set_fixed_objects $DL0_wh_cell

set                DL12_wh_cell [get_cells "wh_link_1__link"]
move_object       $DL12_wh_cell -x $wh_link_west_offset -y [round_up_to_nearest [expr 6058.88+15*$grid_height] $grid_height]
set_attribute     $DL12_wh_cell orientation MY
set_fixed_objects $DL12_wh_cell

set                DL34_wh_cell [get_cells "wh_link_2__link"]
move_object       $DL34_wh_cell -x $wh_link_west_offset -y [round_up_to_nearest [expr 4058.88+15*$grid_height] $grid_height]
set_attribute     $DL34_wh_cell orientation MY
set_fixed_objects $DL34_wh_cell

set                DL56_wh_cell [get_cells "wh_link_3__link"]
move_object       $DL56_wh_cell -x $wh_link_west_offset -y [round_up_to_nearest [expr 2058.88+15*$grid_height] $grid_height]
set_attribute     $DL56_wh_cell orientation MY
set_fixed_objects $DL56_wh_cell

set                DL7_wh_cell [get_cells "wh_link_4__link"]
move_object       $DL7_wh_cell -x $wh_link_west_offset -y [round_up_to_nearest [expr 463.04-37*$grid_height] $grid_height]
set_attribute     $DL7_wh_cell orientation MY
set_fixed_objects $DL7_wh_cell

set                DR0_wh_cell [get_cells "wh_link_5__link"]
move_object       $DR0_wh_cell -x $wh_link_east_offset -y [round_up_to_nearest [expr 8058.88+2*$grid_height] $grid_height]
set_attribute     $DR0_wh_cell orientation R0
set_fixed_objects $DR0_wh_cell

set                DR12_wh_cell [get_cells "wh_link_6__link"]
move_object       $DR12_wh_cell -x $wh_link_east_offset -y [round_up_to_nearest [expr 6058.88+15*$grid_height] $grid_height]
set_attribute     $DR12_wh_cell orientation R0
set_fixed_objects $DR12_wh_cell

set                DR34_wh_cell [get_cells "wh_link_7__link"]
move_object       $DR34_wh_cell -x $wh_link_east_offset -y [round_up_to_nearest [expr 4058.88+15*$grid_height] $grid_height]
set_attribute     $DR34_wh_cell orientation R0
set_fixed_objects $DR34_wh_cell

set                DR56_wh_cell [get_cells "wh_link_8__link"]
move_object       $DR56_wh_cell -x $wh_link_east_offset -y [round_up_to_nearest [expr 2058.88+15*$grid_height] $grid_height]
set_attribute     $DR56_wh_cell orientation R0
set_fixed_objects $DR56_wh_cell

set                DR7_wh_cell [get_cells "wh_link_9__link"]
move_object       $DR7_wh_cell -x $wh_link_east_offset -y [round_up_to_nearest [expr 463.04-37*$grid_height] $grid_height]
set_attribute     $DR7_wh_cell orientation R0
set_fixed_objects $DR7_wh_cell

puts "BSG-info: Completed script [info script]\n"