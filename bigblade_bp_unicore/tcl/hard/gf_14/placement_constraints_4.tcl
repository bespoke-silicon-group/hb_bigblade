################################################################################
## Create Bounds
################################################################################

current_design ${DESIGN_NAME}

# Start script fresh
set_locked_objects -unlock [get_cells -hier]
remove_bounds -all
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
  -horizontal_channel_height [expr 2*$keepout_margin_x] \
  -vertical_channel_width [expr 2*$keepout_margin_y] \
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
  -horizontal_channel_height [expr 2*$keepout_margin_x] \
  -vertical_channel_width [expr 2*$keepout_margin_y] \
  -orientation N \
  $dcache_data_mems_east]

create_keepout_margin -type hard -outer $keepout_margins $dcache_data_mems_east

set_macro_relative_location \
  -target_object $dcache_data_ma_east \
  -target_corner bl \
  -target_orientation R0 \
  -anchor_corner br \
  -anchor_object $dcache_data_ma_west \
  -offset [list [expr 2*$keepout_margin_x] 0]

#####################################
### BTB Memory
###

set_macro_relative_location \
  -target_object $btb_mem \
  -target_corner tl \
  -target_orientation N \
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
  -orientation FN \
  $fp_regfile_mems]

set_macro_relative_location \
  -target_object $fp_regfile_ma \
  -target_corner bl \
  -target_orientation R0 \
  -anchor_corner bl \
  -offset [list [expr ($tile_width - 3*$freg_mem_width - 2*$ireg_mem_width)/2] \
                [expr ($tile_height - $freg_mem_height)/2]]
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
  -orientation N \
  $int_regfile_mems]

set_macro_relative_location \
  -target_object $int_regfile_ma \
  -target_corner tl \
  -target_orientation R0 \
  -anchor_object $fp_regfile_ma \
  -anchor_corner tr \
  -offset [list $keepout_margin_x 0]
#  -offset [list [expr 1.5*$freg_mem_width - $ireg_mem_width]  0]

create_keepout_margin -type hard -outer $keepout_margins $int_regfile_mems

#####################################
### I CACHE STAT
###

set_macro_relative_location \
  -target_object $icache_stat_mem \
  -target_corner bl \
  -target_orientation FN \
  -anchor_object $icache_tag_ma \
  -anchor_corner br \
  -offset [list [expr 2*$keepout_margin_x] 0]

create_keepout_margin -type hard -outer $keepout_margins $icache_stat_mem

#####################################
### D CACHE STAT
###

set_macro_relative_location \
  -target_object $dcache_stat_mem \
  -target_corner tl \
  -target_orientation FN \
  -anchor_object $dcache_tag_ma \
  -anchor_corner tr \
  -offset [list $keepout_margin_x 0]

create_keepout_margin -type hard -outer $keepout_margins $dcache_stat_mem

#####################################
### GUI setup
###
#gui_explore_logic_hierarchy -create [get_cells -hier *bp_be_*]
#change_selection [gui_explore_logic_hierarchy -expand]
