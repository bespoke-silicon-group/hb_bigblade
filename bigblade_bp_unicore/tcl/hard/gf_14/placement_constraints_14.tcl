################################################################################
## Create Bounds
################################################################################

current_design ${DESIGN_NAME}

# Start script fresh
set_locked_objects -unlock [get_cells -hier]
remove_edit_groups -all
remove_bounds -all
remove_placement_blockages -all

set tile_height [core_height]
set tile_width  [core_width]

set keepout_margin_x [expr 6*[unit_width]]
set keepout_margin_y [expr 1*[unit_height]]
# left, bottom, right top
set keepout_margins [list $keepout_margin_x $keepout_margin_y $keepout_margin_x $keepout_margin_y]

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
set bht_mem [get_cells -hier -filter "ref_name=~gf14_* && full_name=~*bht*mem*"]

set ireg_mem_height   [lindex [get_attribute [get_cell -hier $int_regfile_mems] height ] 0]
set ireg_mem_width    [lindex [get_attribute [get_cell -hier $int_regfile_mems] width ] 0]
set freg_mem_height   [lindex [get_attribute [get_cell -hier $fp_regfile_mems] height ] 0]
set freg_mem_width    [lindex [get_attribute [get_cell -hier $fp_regfile_mems] width ] 0]
set stat_mem_width    [lindex [get_attribute [get_cell -hier $dcache_stat_mem] width ] 0]
set btb_mem_height    [lindex [get_attribute [get_cell -hier $btb_mem] height] 0]
set btb_mem_width     [lindex [get_attribute [get_cell -hier $btb_mem] width] 0]

# Set up boundary cells
set bound_width 0.672
set bound_height 0.480

set bound_to_rf_pin  0.058
set bound_to_rf_side 0.020
set bound_to_rf_top  0.140
set bound_to_rf_bot  0.140

create_bound -name "outer_bound" -boundary [list [list [expr $bound_width] [expr $bound_height]] [list [expr $tile_width-$bound_width] [expr $tile_height-$bound_height]]]
create_bound -name "bound_bound" -boundary [list [list [expr $bound_width+$bound_to_rf_side] [expr $bound_height+$bound_to_rf_bot]] [list [expr $tile_width-$bound_width-$bound_to_rf_side] [expr $tile_height-$bound_height-$bound_to_rf_top]]]
set bound_bound [get_bounds "bound_bound"]

set sram_front_to_back 0.084
set sram_top_to_bot 0.000

#####################################
### I CACHE TAG
###

set icache_tag_ma [create_macro_array \
  -num_rows 2 \
  -num_cols 1 \
  -align bottom \
  -horizontal_channel_height [expr $sram_top_to_bot] \
  -vertical_channel_width [expr $sram_front_to_back] \
  -orientation FN \
  $icache_tag_mems]

set ko [list $bound_to_rf_side $keepout_margin_y $keepout_margin_x $bound_to_rf_top]
create_keepout_margin -type hard -outer $ko $icache_tag_mems 

set_macro_relative_location \
  -target_object $icache_tag_ma \
  -target_corner tl \
  -target_orientation R0 \
  -anchor_corner tl \
  -anchor_object $bound_bound \
  -offset [list -$bound_to_rf_side $bound_to_rf_top]
#-$bound_to_rf_top]]

#####################################
### I CACHE DATA
###

set icache_data_ma_west [create_macro_array \
  -num_rows 2 \
  -num_cols 2 \
  -align bottom \
  -horizontal_channel_height [expr $sram_top_to_bot] \
  -vertical_channel_width [expr $sram_front_to_back] \
  -orientation FN \
  $icache_data_mems_west]

set ko [list $keepout_margin_x $keepout_margin_y $keepout_margin_x $bound_to_rf_top]
create_keepout_margin -type hard -outer $ko $icache_data_mems_west

set_macro_relative_location \
  -target_object $icache_data_ma_west \
  -target_corner tl \
  -target_orientation R0 \
  -anchor_corner tr \
  -anchor_object $icache_tag_ma \
  -offset [list [expr -2*$keepout_margin_x+$sram_front_to_back] 0]

set icache_data_ma_east [create_macro_array \
  -num_rows 2 \
  -num_cols 2 \
  -align bottom \
  -horizontal_channel_height [expr $sram_top_to_bot] \
  -vertical_channel_width [expr $sram_front_to_back] \
  -orientation N \
  $icache_data_mems_east]

set ko [list $keepout_margin_x $keepout_margin_y $bound_to_rf_side $bound_to_rf_top]
create_keepout_margin -type hard -outer $ko $icache_data_mems_east

set_macro_relative_location \
  -target_object $icache_data_ma_east \
  -target_corner tr \
  -target_orientation R0 \
  -anchor_corner tr \
  -anchor_object $bound_bound \
  -offset [list $bound_to_rf_side $bound_to_rf_top]

#####################################
### D CACHE TAG
###

set dcache_tag_ma [create_macro_array \
  -num_rows 2 \
  -num_cols 1 \
  -align bottom \
  -horizontal_channel_height [expr $sram_top_to_bot] \
  -vertical_channel_width [expr $sram_front_to_back] \
  -orientation FN \
  $dcache_tag_mems]

set ko [list $bound_to_rf_side $bound_to_rf_top $keepout_margin_x $bound_to_rf_top]
create_keepout_margin -type hard -outer $ko $dcache_tag_mems

set_macro_relative_location \
  -target_object $dcache_tag_ma \
  -target_corner bl \
  -target_orientation R0 \
  -anchor_corner bl \
  -anchor_object $bound_bound \
  -offset [list -$bound_to_rf_side -$bound_to_rf_top]

#####################################
### D CACHE DATA
###

set dcache_data_ma_west [create_macro_array \
  -num_rows 2 \
  -num_cols 2 \
  -align bottom \
  -horizontal_channel_height [expr $sram_top_to_bot] \
  -vertical_channel_width [expr $sram_front_to_back] \
  -orientation FN \
  $dcache_data_mems_west]

set ko [list $keepout_margin_x $bound_to_rf_top [expr 10.68/2] $keepout_margin_y]
create_keepout_margin -type hard -outer $ko $dcache_data_mems_west

set_macro_relative_location \
  -target_object $dcache_data_ma_west \
  -target_corner bl \
  -target_orientation R0 \
  -anchor_corner br \
  -anchor_object $dcache_tag_ma \
  -offset [list [expr -2*$keepout_margin_x+$sram_front_to_back] 0]

set dcache_data_ma_east [create_macro_array \
  -num_rows 2 \
  -num_cols 2 \
  -align bottom \
  -horizontal_channel_height [expr $sram_top_to_bot] \
  -vertical_channel_width [expr $sram_front_to_back] \
  -orientation N \
  $dcache_data_mems_east]

set ko [list [expr 10.68/2] $bound_to_rf_top $bound_to_rf_side $keepout_margin_y]
create_keepout_margin -type hard -outer $ko $dcache_data_mems_east

set_macro_relative_location \
  -target_object $dcache_data_ma_east \
  -target_corner br \
  -target_orientation R0 \
  -anchor_corner br \
  -anchor_object $bound_bound \
  -offset [list $bound_to_rf_side -$bound_to_rf_top]

#####################################
### BTB Memory
###

set_macro_relative_location \
  -target_object $btb_mem \
  -target_corner tl \
  -target_orientation FN \
  -anchor_corner bl \
  -anchor_object $icache_data_ma_west \
  -offset [list $keepout_margin_x [expr $keepout_margin_y-$sram_top_to_bot]]

create_keepout_margin -type hard -outer $keepout_margins $btb_mem

#####################################
### INT + FP RF
###

set fp_regfile_ma [create_macro_array \
  -num_rows 1 \
  -num_cols 3 \
  -align left \
  -horizontal_channel_height [expr $sram_top_to_bot] \
  -vertical_channel_width [expr $sram_front_to_back] \
  -orientation FN \
  $fp_regfile_mems]

set_macro_relative_location \
  -target_object $fp_regfile_ma \
  -target_corner bl \
  -target_orientation R0 \
  -anchor_object $dcache_data_ma_west \
  -anchor_corner tl \
  -offset [list 0 [expr -2*$keepout_margin_y+$sram_top_to_bot]]

create_keepout_margin -type hard -outer $keepout_margins $fp_regfile_mems

set int_regfile_ma [create_macro_array \
  -num_rows 1 \
  -num_cols 2 \
  -align left \
  -horizontal_channel_height [expr $sram_top_to_bot] \
  -vertical_channel_width [expr $sram_front_to_back] \
  -orientation N \
  $int_regfile_mems]

set_macro_relative_location \
  -target_object $int_regfile_ma \
  -target_corner br \
  -target_orientation R0 \
  -anchor_corner tr \
  -anchor_object $dcache_data_ma_east \
  -offset [list 0 [expr -2*$keepout_margin_y+$sram_top_to_bot]]

create_keepout_margin -type hard -outer $keepout_margins $int_regfile_mems

#####################################
### I CACHE STAT
###

set_macro_relative_location \
  -target_object $icache_stat_mem \
  -target_corner tl \
  -target_orientation FN \
  -anchor_object $btb_mem \
  -anchor_corner tr \
  -offset [list [expr $sram_front_to_back] 0]

create_keepout_margin -type hard -outer $keepout_margins $icache_stat_mem

#####################################
### D CACHE STAT
###

set_macro_relative_location \
  -target_object $dcache_stat_mem \
  -target_corner tl \
  -target_orientation FN \
  -anchor_object $icache_stat_mem \
  -anchor_corner bl \
  -offset [list 0 [expr 0]]

create_keepout_margin -type hard -outer $keepout_margins $dcache_stat_mem

##################################
### BHT
###

set_macro_relative_location \
  -target_object $bht_mem \
  -target_corner tr \
  -target_orientation N \
  -anchor_object $icache_data_ma_east \
  -anchor_corner br \
  -offset [list -$bound_to_rf_side [expr $keepout_margin_y+$sram_top_to_bot]]

set ko [list $keepout_margin_x $keepout_margin_y $bound_to_rf_side $sram_top_to_bot]
create_keepout_margin -type hard -outer $ko $bht_mem

# create temporary placement blockages for I/O
#create_placement_blockage -name sdr_place_blockage_0 -boundary {{158.08 165.6} {240.408 169.54}}
#create_placement_blockage -name sdr_place_blockage_1 -boundary {{240.408 246.24} {282.24 248.74}}
#create_placement_blockage -name sdr_place_blockage_2 -boundary {{161.023 401.8} {282.24 399.84}}
#create_placement_blockage -name sdr_place_blockage_3 -boundary {{237.908 167.04} {240.408 246.24}}
#create_placement_blockage -name sdr_place_blockage_4 -boundary {{279.74 246.24} {282.24 399.84}}


#####################################
### GUI setup
###
#gui_explore_logic_hierarchy -create -cycle [get_cells -hier *bp_be_*]
#gui_explore_logic_hierarchy -create -cycle [get_cells -hier *bp_fe_*]
#gui_explore_logic_hierarchy -create -cycle [get_cells -hier *io_router*]

#set isdr_bound [create_bound -name "isdr" -type soft -boundary {{277.5360 0} {282.576 567.36}}]
#set osdr_bound [create_bound -name "osdr" -type soft -boundary {{277.5360 0} {282.576 567.36}}]
#add_to_bound ${isdr_bound} [get_cells -hier -filter "full_name=~*/isdr_phy/*"]
#add_to_bound ${osdr_bound} [get_cells -hier -filter "full_name=~*/osdr_phy/*"]
