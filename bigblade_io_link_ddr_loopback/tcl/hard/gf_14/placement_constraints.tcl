puts "BSG-info: Running script [info script]\n"

source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_common_variables.tcl
#set_app_options -name plan.place.auto_generate_blockages -value false

# Uncomment if you are sourcing this file many times interactively.
#set_fixed_objects -unfix [get_flat_cells]


# grid_width  = 13.44
# grid_height = 5.76

set edge_offset          237
set die_width            11000
set die_height           9000

set io_link_ch_len       1680
set io_link_ch_half_len  [expr $io_link_ch_len/2]

set io_link_west_offset  [round_up_to_nearest $edge_offset $grid_width]
set io_link_south_offset [round_up_to_nearest $edge_offset $grid_height]
set io_link_east_offset  [expr $grid_width*(floor(($die_width-$edge_offset)/$grid_width-0.5)+0.5)]
set io_link_north_offset [expr $grid_height*(floor(($die_height-$edge_offset)/$grid_height-0.5)+0.5)]



#set                DL5_cell [get_cells "mem_link_5__link"]
#move_object       $DL5_cell -x $io_link_west_offset -y [round_down_to_nearest [expr 252.0+$io_link_ch_half_len] $grid_height]
#set_attribute     $DL5_cell orientation R0
#set_fixed_objects $DL5_cell
#set                DL4_cell [get_cells "mem_link_4__link"]
#move_object       $DL4_cell -x $io_link_west_offset -y [round_down_to_nearest [expr 1956.0+$io_link_ch_half_len] $grid_height]
#set_attribute     $DL4_cell orientation R0
#set_fixed_objects $DL4_cell
#set                DL3_cell [get_cells "mem_link_3__link"]
#move_object       $DL3_cell -x $io_link_west_offset -y [round_down_to_nearest [expr 3660.0+$io_link_ch_half_len] $grid_height]
#set_attribute     $DL3_cell orientation R0
#set_fixed_objects $DL3_cell
#set                DL2_cell [get_cells "mem_link_2__link"]
#move_object       $DL2_cell -x $io_link_west_offset -y [round_down_to_nearest [expr 5364.0+$io_link_ch_half_len] $grid_height]
#set_attribute     $DL2_cell orientation R0
#set_fixed_objects $DL2_cell
#set                DL1_cell [get_cells "mem_link_1__link"]
#move_object       $DL1_cell -x $io_link_west_offset -y [round_down_to_nearest [expr 7068.0+$io_link_ch_half_len] $grid_height]
#set_attribute     $DL1_cell orientation R0
#set_fixed_objects $DL1_cell
#
#
#
#set                DL0_cell [get_cells "mem_link_0__link"]
#move_object       $DL0_cell -y $io_link_north_offset -x [round_down_to_nearest [expr 1769.5+$io_link_ch_half_len] $grid_width]
#set_attribute     $DL0_cell orientation MX
#set_fixed_objects $DL0_cell
#set                IT0_cell [get_cells "io_link_0__link"]
#move_object       $IT0_cell -y $io_link_north_offset -x [round_down_to_nearest [expr 3461.5+$io_link_ch_half_len] $grid_width]
#set_attribute     $IT0_cell orientation MX
#set_fixed_objects $IT0_cell
#set                IT1_cell [get_cells "io_link_1__link"]
#move_object       $IT1_cell -y $io_link_north_offset -x [round_down_to_nearest [expr 5999.5+$io_link_ch_half_len] $grid_width]
#set_attribute     $IT1_cell orientation MX
#set_fixed_objects $IT1_cell
#set                DR0_cell [get_cells "mem_link_8__link"]
#move_object       $DR0_cell -y $io_link_north_offset -x [round_down_to_nearest [expr 7691.5+$io_link_ch_half_len] $grid_width]
#set_attribute     $DR0_cell orientation MX
#set_fixed_objects $DR0_cell
#
#
#
#set                DR1_cell [get_cells "mem_link_9__link"]
#move_object       $DR1_cell -x $io_link_east_offset -y [round_down_to_nearest [expr 8748.0-$io_link_ch_half_len] $grid_height]
#set_attribute     $DR1_cell orientation MY
#set_fixed_objects $DR1_cell
#set                DR2_cell [get_cells "mem_link_10__link"]
#move_object       $DR2_cell -x $io_link_east_offset -y [round_down_to_nearest [expr 7044.0-$io_link_ch_half_len] $grid_height]
#set_attribute     $DR2_cell orientation MY
#set_fixed_objects $DR2_cell
#set                DR3_cell [get_cells "mem_link_11__link"]
#move_object       $DR3_cell -x $io_link_east_offset -y [round_down_to_nearest [expr 5340.0-$io_link_ch_half_len] $grid_height]
#set_attribute     $DR3_cell orientation MY
#set_fixed_objects $DR3_cell
#set                DR4_cell [get_cells "mem_link_12__link"]
#move_object       $DR4_cell -x $io_link_east_offset -y [round_down_to_nearest [expr 3636.0-$io_link_ch_half_len] $grid_height]
#set_attribute     $DR4_cell orientation MY
#set_fixed_objects $DR4_cell
#set                DR5_cell [get_cells "mem_link_13__link"]
#move_object       $DR5_cell -x $io_link_east_offset -y [round_down_to_nearest [expr 1932.0-$io_link_ch_half_len] $grid_height]
#set_attribute     $DR5_cell orientation MY
#set_fixed_objects $DR5_cell
#
#
#
#set                DR6_cell [get_cells "mem_link_14__link"]
#move_object       $DR6_cell -y $io_link_south_offset -x [round_down_to_nearest [expr 9230.5-$io_link_ch_half_len] $grid_width]
#set_attribute     $DR6_cell orientation R0
#set_fixed_objects $DR6_cell
#set                DR7_cell [get_cells "mem_link_15__link"]
#move_object       $DR7_cell -y $io_link_south_offset -x [round_down_to_nearest [expr 7538.5-$io_link_ch_half_len] $grid_width]
#set_attribute     $DR7_cell orientation R0
#set_fixed_objects $DR7_cell
#set                DL7_cell [get_cells "mem_link_7__link"]
#move_object       $DL7_cell -y $io_link_south_offset -x [round_down_to_nearest [expr 5000.5-$io_link_ch_half_len] $grid_width]
#set_attribute     $DL7_cell orientation R0
#set_fixed_objects $DL7_cell
#set                DL6_cell [get_cells "mem_link_6__link"]
#move_object       $DL6_cell -y $io_link_south_offset -x [round_down_to_nearest [expr 3308.5-$io_link_ch_half_len] $grid_width]
#set_attribute     $DL6_cell orientation R0
#set_fixed_objects $DL6_cell


set                DL01_cell [get_cells "mem_link_0__link"]
move_object       $DL01_cell -y $io_link_north_offset -x [round_down_to_nearest [expr 1769.5] $grid_width]
set_attribute     $DL01_cell orientation MX
set_fixed_objects $DL01_cell

set                DL23_cell [get_cells "mem_link_1__link"]
move_object       $DL23_cell -x $io_link_west_offset -y [round_down_to_nearest [expr 5364.0] $grid_height]
set_attribute     $DL23_cell orientation R0
set_fixed_objects $DL23_cell

set                DL45_cell [get_cells "mem_link_2__link"]
move_object       $DL45_cell -x $io_link_west_offset -y [round_down_to_nearest [expr 1956.0] $grid_height]
set_attribute     $DL45_cell orientation R0
set_fixed_objects $DL45_cell

set                DL67_cell [get_cells "mem_link_3__link"]
move_object       $DL67_cell -y $io_link_south_offset -x [round_down_to_nearest [expr 3308.5] $grid_width]
set_attribute     $DL67_cell orientation R0
set_fixed_objects $DL67_cell

set                DR01_cell [get_cells "mem_link_4__link"]
move_object       $DR01_cell -y $io_link_north_offset -x [round_down_to_nearest [expr 7691.5+$io_link_ch_len] $grid_width]
set_attribute     $DR01_cell orientation MX
set_fixed_objects $DR01_cell

set                DR23_cell [get_cells "mem_link_5__link"]
move_object       $DR23_cell -x $io_link_east_offset -y [round_down_to_nearest [expr 5340.0] $grid_height]
set_attribute     $DR23_cell orientation MY
set_fixed_objects $DR23_cell

set                DR45_cell [get_cells "mem_link_6__link"]
move_object       $DR45_cell -x $io_link_east_offset -y [round_down_to_nearest [expr 1932.0] $grid_height]
set_attribute     $DR45_cell orientation MY
set_fixed_objects $DR45_cell

set                DR67_cell [get_cells "mem_link_7__link"]
move_object       $DR67_cell -y $io_link_south_offset -x [round_down_to_nearest [expr 7538.5] $grid_width]
set_attribute     $DR67_cell orientation R0
set_fixed_objects $DR67_cell

# placement blockages
create_placement_blockage -boundary {{715.36 749.44} {10284.64 8250.56}}


puts "BSG-info: Completed script [info script]\n"
