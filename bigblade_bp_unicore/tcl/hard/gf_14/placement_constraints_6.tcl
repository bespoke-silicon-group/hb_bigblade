################################################################################
## Create Bounds
################################################################################

current_design ${DESIGN_NAME}

# Start script fresh
set_locked_objects -unlock [get_cells -hier]
remove_edit_groups -all

set tile_height [core_height]
set tile_width  [core_width]

set keepout_margin_x [expr 6*[unit_width]]
set keepout_margin_y [expr 1*[unit_height]]
set keepout_margins [list $keepout_margin_x $keepout_margin_y $keepout_margin_x $keepout_margin_y]
set keepout_margins_2x [list [expr 2*$keepout_margin_x] [expr 2*$keepout_margin_y] [expr 2*$keepout_margin_x] [expr 2*$keepout_margin_y]]

set icache_tag_mems [get_cells -hier -filter "ref_name=~gf14_* && full_name=~*icache*tag_mem*"]
set icache_data_mems_west [index_collection [get_cells -hier -filter "ref_name=~gf14_* && full_name=~*icache*data_mem*"] 0 3]
set icache_data_mems_east [index_collection [get_cells -hier -filter "ref_name=~gf14_* && full_name=~*icache*data_mem*"] 4 7]
set int_regfile_mems [get_cells -hier -filter "ref_name=~gf14_* && full_name=~*/int_regfile/*"]
set fp_regfile_mems [get_cells -hier -filter "ref_name=~gf14_* && full_name=~*/fp_regfile/*"]
set icache_stat_mem [get_cells -hier -filter "ref_name=~gf14_* && full_name=~*/icache*stat_mem*"]
set dcache_data_mems_east [index_collection [get_cells -hier -filter "ref_name=~gf14_* && full_name=~*dcache*data_mem*"] 4 7]
set dcache_data_mems_west [index_collection [get_cells -hier -filter "ref_name=~gf14_* && full_name=~*dcache*data_mem*"] 0 3]
set data_mem_width    [lindex [get_attribute [get_cell -hier $dcache_data_mems_west] width ] 0]
set data_mem_height   [lindex [get_attribute [get_cell -hier $dcache_data_mems_west] height] 0]
set dcache_stat_mem [get_cells -hier -filter "ref_name=~gf14_* && full_name=~*dcache*stat_mem*"]
set btb_mem [get_cells -hier -filter "ref_name=~gf14_* && full_name=~*btb*tag_mem*"]
set dcache_tag_mems [get_cells -hier -filter "ref_name=~gf14_* && full_name=~*dcache*tag_mem*"]
set tag_mem_width     [lindex [get_attribute [get_cell -hier $dcache_tag_mems] width ] 0]

set ireg_mem_height   [lindex [get_attribute [get_cell -hier $int_regfile_mems] height ] 0]
set ireg_mem_width    [lindex [get_attribute [get_cell -hier $int_regfile_mems] width ] 0]
set freg_mem_height   [lindex [get_attribute [get_cell -hier $fp_regfile_mems] height ] 0]
set freg_mem_width    [lindex [get_attribute [get_cell -hier $fp_regfile_mems] width ] 0]
set stat_mem_width    [lindex [get_attribute [get_cell -hier $dcache_stat_mem] width ] 0]
set btb_mem_height    [lindex [get_attribute [get_cell -hier $btb_mem] height] 0]
set btb_mem_width     [lindex [get_attribute [get_cell -hier $btb_mem] width] 0]


#####################################
### I CACHE TAG
###

set icache_tag_ma [create_macro_array \
  -num_rows 2 \
  -num_cols 1 \
  -align bottom \
  -horizontal_channel_height [expr 4*$keepout_margin_x] \
  -vertical_channel_width [expr 4*$keepout_margin_y] \
  -orientation FN \
  $icache_tag_mems]

create_keepout_margin -type hard -outer $keepout_margins $icache_tag_mems

set_macro_relative_location \
  -target_object $icache_tag_ma \
  -target_corner tl \
  -target_orientation R0 \
  -anchor_corner tl \
  -offset [list $keepout_margin_x -$keepout_margin_y]

#####################################
### I CACHE DATA
###

set icache_data_ma_west [create_macro_array \
  -num_rows 2 \
  -num_cols 2 \
  -align bottom \
  -horizontal_channel_height [expr 2*$keepout_margin_x] \
  -vertical_channel_width [expr 2*$keepout_margin_y] \
  -orientation FN \
  $icache_data_mems_west]

create_keepout_margin -type hard -outer $keepout_margins $icache_data_mems_west

set_macro_relative_location \
  -target_object $icache_data_ma_west \
  -target_corner tl \
  -target_orientation R0 \
  -anchor_corner tr \
  -anchor_object $icache_tag_ma \
  -offset [list $keepout_margin_x 0]

set icache_data_ma_east [create_macro_array \
  -num_rows 2 \
  -num_cols 2 \
  -align bottom \
  -horizontal_channel_height [expr 2*$keepout_margin_x] \
  -vertical_channel_width [expr 2*$keepout_margin_y] \
  -orientation N \
  $icache_data_mems_east]

create_keepout_margin -type hard -outer $keepout_margins $icache_data_mems_east

set_macro_relative_location \
  -target_object $icache_data_ma_east \
  -target_corner tl \
  -target_orientation R0 \
  -anchor_corner tr \
  -anchor_object $icache_data_ma_west \
  -offset [list $keepout_margin_x 0]

#####################################
### D CACHE TAG
###

set dcache_tag_ma [create_macro_array \
  -num_rows 2 \
  -num_cols 1 \
  -align bottom \
  -horizontal_channel_height [expr 4*$keepout_margin_x] \
  -vertical_channel_width [expr 4*$keepout_margin_y] \
  -orientation FN \
  $dcache_tag_mems]

create_keepout_margin -type hard -outer $keepout_margins $dcache_tag_mems

set_macro_relative_location \
  -target_object $dcache_tag_ma \
  -target_corner bl \
  -target_orientation R0 \
  -anchor_corner bl \
  -offset [list $keepout_margin_x $keepout_margin_y]

#####################################
### D CACHE DATA
###

set dcache_data_ma_west [create_macro_array \
  -num_rows 2 \
  -num_cols 2 \
  -align bottom \
  -horizontal_channel_height [expr 4*$keepout_margin_x] \
  -vertical_channel_width [expr 4*$keepout_margin_y] \
  -orientation FN \
  $dcache_data_mems_west]

create_keepout_margin -type hard -outer $keepout_margins $dcache_data_mems_west

set_macro_relative_location \
  -target_object $dcache_data_ma_west \
  -target_corner bl \
  -target_orientation R0 \
  -anchor_corner br \
  -anchor_object $dcache_tag_ma \
  -offset [list $keepout_margin_x 0]

set dcache_data_ma_east [create_macro_array \
  -num_rows 2 \
  -num_cols 2 \
  -align bottom \
  -horizontal_channel_height [expr 4*$keepout_margin_x] \
  -vertical_channel_width [expr 4*$keepout_margin_y] \
  -orientation N \
  $dcache_data_mems_east]

create_keepout_margin -type hard -outer $keepout_margins $dcache_data_mems_east

set_macro_relative_location \
  -target_object $dcache_data_ma_east \
  -target_corner bl \
  -target_orientation R0 \
  -anchor_corner br \
  -anchor_object $dcache_data_ma_west \
  -offset [list [expr 4*$keepout_margin_x] 0]

#####################################
### BTB Memory
###

set_macro_relative_location \
  -target_object $btb_mem \
  -target_corner tl \
  -target_orientation FN \
  -anchor_corner tr \
  -anchor_object $icache_data_ma_east \
  -offset [list $keepout_margin_x 0]
#  -offset [list [expr $tile_width/2 - $btb_mem_width/2 - 2*$ireg_mem_width/2 - 3*$freg_mem_width/2] [expr -$tile_height/2 + $btb_mem_height/2]]

create_keepout_margin -type hard -outer $keepout_margins $btb_mem

#####################################
### INT + FP RF
###

set fp_regfile_ma [create_macro_array \
  -num_rows 1 \
  -num_cols 3 \
  -align left \
  -horizontal_channel_height [expr 4*$keepout_margin_x] \
  -vertical_channel_width [expr 2*$keepout_margin_y] \
  -orientation N \
  $fp_regfile_mems]

set_macro_relative_location \
  -target_object $fp_regfile_ma \
  -target_corner bl \
  -target_orientation R0 \
  -anchor_corner bl \
  -offset [list [expr ($tile_width - 3*$freg_mem_width + 2*$ireg_mem_width)/2] \
                [expr ($tile_height - $freg_mem_height)/2]]
#  -offset [list [expr ($tile_width - 2*$freg_mem_width)/2] \
#                [expr ($tile_height - 1.25*$freg_mem_height)/2]]
#  -offset [list 0 [expr -$tile_width/2 + 2*$data_mem_height - $freg_mem_height + $ireg_mem_height/2]]
#  -offset [list $keepout_margin_x [expr -0.5*$btb_mem_height + 0.5*$freg_mem_height]]
#  -offset [list -$keepout_margin_x [expr -$tile_height/2 + 0.5*$freg_mem_height + 0.5*$ireg_mem_height]]
#  -offset [list [expr $tile_width/2 - 1.5*$freg_mem_width - 1*$ireg_mem_width] [expr $tile_height/2 - 0.5*$freg_mem_height]]
#  -offset [list [tile_width/2 - 1.5*$freg_mem_width] [expr $tile_height/2 - 0.25*$freg_mem_width]]

create_keepout_margin -type hard -outer $keepout_margins $fp_regfile_mems

set int_regfile_ma [create_macro_array \
  -num_rows 1 \
  -num_cols 2 \
  -align left \
  -horizontal_channel_height [expr 4*$keepout_margin_x] \
  -vertical_channel_width [expr 2*$keepout_margin_y] \
  -orientation FN \
  $int_regfile_mems]

set_macro_relative_location \
  -target_object $int_regfile_ma \
  -target_corner tr \
  -target_orientation R0 \
  -anchor_object $fp_regfile_ma \
  -anchor_corner tl \
  -offset [list [expr -2*$keepout_margin_x] 0]
#  -offset [list [expr 1.5*$freg_mem_width - $ireg_mem_width]  0]

create_keepout_margin -type hard -outer $keepout_margins $int_regfile_mems

#####################################
### I CACHE STAT
###

set_macro_relative_location \
  -target_object $icache_stat_mem \
  -target_corner tl \
  -target_orientation FN \
  -anchor_object $icache_data_ma_west \
  -anchor_corner bl \
  -offset [list 0 -$keepout_margin_y]

create_keepout_margin -type hard -outer $keepout_margins $icache_stat_mem

#####################################
### D CACHE STAT
###

set_macro_relative_location \
  -target_object $dcache_stat_mem \
  -target_corner bl \
  -target_orientation FN \
  -anchor_object $dcache_data_ma_west \
  -anchor_corner tl \
  -offset [list [expr 2*$keepout_margin_x] [expr 2*$keepout_margin_y]]

create_keepout_margin -type hard -outer $keepout_margins $dcache_stat_mem

#####################################
### GUI setup
###
#gui_explore_logic_hierarchy -create -cycle [get_cells -hier *bp_be_*]
#gui_explore_logic_hierarchy -create -cycle [get_cells -hier *bp_fe_*]
#gui_explore_logic_hierarchy -create -cycle [get_cells -hier *io_router*]
#
#####################################
### Placement bounds
###
remove_bounds -all

#set core_bound [create_bound -name "core_bound" -exclusive -boundary \
#    [list [list 0 0] [list $router_x $tile_height]]]
#set core_bound [create_bound -name "core_bound" -exclusive -boundary \
#    [list [list 22 100] [list 290 475]]]
##    [list [list 22 166] [list 295 400]]]
#
#add_to_bound $core_bound [get_cells -hier -filter "full_name=~*blackparrot*"]
#remove_from_bound $core_bound [get_cells -hier -filter "full_name=~*blackparrot*2__cmd_fifo*"]
#remove_from_bound $core_bound [get_cells -hier -filter "full_name=~*blackparrot*cfg*"]
#remove_from_bound $core_bound [get_cells -hier -filter "full_name=~*blackparrot*clint*"]
#remove_from_bound $core_bound [get_cells -hier -filter "full_name=~*blackparrot*loopback*"]
#remove_from_bound $core_bound [get_cells -hier -filter "full_name=~*blackparrot*__resp_fifo*"]
#remove_from_bound $core_bound [get_cells -hier -filter "full_name=~*blackparrot*__resp_select*"]
#add_to_bound $core_bound [get_cells -hier -filter "full_name=~*tile*dram_splitter"]
#add_to_bound $core_bound [get_cells -hier -filter "full_name=~*tile*host_link"]
#add_to_bound $core_bound [get_cells -hier -filter "full_name=~*tile*dram_link"]
#remove_from_bound $core_bound [get_cells -hier -filter "full_name=~*blackparrot_endpoint*"]


set router_bound [create_bound -name "router_bound" -type hard -exclusive -boundary \
    [list [list 260 0] [list $tile_width [expr $tile_height/2]]]]

add_to_bound $router_bound [get_cells -hier -filter "full_name=~*rof2_*__fwd_cdc"]
add_to_bound $router_bound [get_cells -hier -filter "full_name=~*rof2_*__rev_cdc"]
add_to_bound $router_bound [get_cells -hier -filter "full_name=~*io_routers*"]
#add_to_bound $router_bound [get_cells -hier -filter "full_name=~*tile*host_link"]
#add_to_bound $router_bound [get_cells -hier -filter "full_name=~*tile*dram_link"]
#add_to_bound $router_bound [get_cells -hier -filter "full_name=~*blackparrot*2__cmd_fifo*"]
#add_to_bound $router_bound [get_cells -hier -filter "full_name=~*blackparrot*2__resp_fifo*"]

#add_to_bound $core_bound [get_cells -hier -filter "full_name=~*core_minimal*"]
#add_to_bound $core_bound [get_cells -hier -filter "full_name=~*icache_uce*"]
#add_to_bound $core_bound [get_cells -hier -filter "full_name=~*dcache_uce*"]
#add_to_bound $core_bound [get_cells -hier -filter "full_name=~*cmd_fifo*"]
#add_to_bound $core_bound [get_cells -hier -filter "full_name=~*resp_fifo*"]

#remove_from_bound $core_bound [get_cells -hier -filter "full_name=~*blackparrot*__cmd_fifo*"]
#remove_from_bound $core_bound [get_cells -hier -filter "full_name=~*blackparrot*__resp_fifo*"]
#remove_from_bound $core_bound [get_cells -hier -filter "full_name=~*blackparrot*__resp_select*"]
#remove_from_bound $core_bound [get_cells -hier -filter "full_name=~*blackparrot*loopback*"]

#add_to_bound $core_bound [get_cells -hier -filter "full_name=~*tile*"]
#add_to_bound $core_bound [get_cells -hier -filter "full_name=~*core_minimal*"]
#add_to_bound $core_bound [get_cells -hier -filter "full_name=~*cache_uce*"]
#add_to_bound $core_bound [get_cells -hier -filter "full_name=~*clint*"]
#add_to_bound $core_bound [get_cells -hier -filter "full_name=~*cfg*"]
#add_to_bound $core_bound [get_cells -hier -filter "full_name=~*loopback*"]

#set core_bound [create_bound -name "core_bound" -type soft -boundary \
#    [list [list 0 0] [list $router_x $tile_height]]]
#add_to_bound $core_bound [get_cells -hier -filter "full_name=~*tile*"]
#remove_from_bound $core_bound [get_cells -hier -filter "full_name=~*tile*link*"]
#
#set router_bound [create_bound -name "router_bound" -type soft -boundary \
#    [list [list $router_x 0] [list $tile_width $tile_height]]]
#add_to_bound $router_bound [get_cells -hier -filter "full_name!~*tile*"]
#add_to_bound $router_bound [get_cells -hier -filter "full_name=~*link*"]

