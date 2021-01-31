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

#####################################
### I CACHE DATA
###

set icache_data_mems [get_cells -hier -filter "ref_name=~gf14_* && full_name=~*icache*data_mems_*"]
set icache_data_ma [create_macro_array \
  -num_rows 8 \
  -num_cols 1 \
  -align bottom \
  -horizontal_channel_height [expr $keepout_margin_y] \
  -vertical_channel_width [expr $keepout_margin_x] \
  -orientation FN \
  $icache_data_mems]

create_keepout_margin -type hard -outer $keepout_margins $icache_data_mems

set_macro_relative_location \
  -target_object $icache_data_ma \
  -target_corner bl \
  -target_orientation R0 \
  -anchor_corner bl \
  -offset [list 0 0]

#####################################
### I CACHE TAG
###

set icache_tag_mems [get_cells -hier -filter "ref_name=~gf14_* && full_name=~*icache*tag_mem*"]
set icache_tag_ma [create_macro_array \
  -num_rows 2 \
  -num_cols 1 \
  -align bottom \
  -horizontal_channel_height [expr $keepout_margin_y] \
  -vertical_channel_width [expr $keepout_margin_x] \
  -orientation FN \
  $icache_tag_mems]

create_keepout_margin -type hard -outer $keepout_margins $icache_tag_mems

set_macro_relative_location \
  -target_object $icache_tag_ma \
  -target_corner tl \
  -target_orientation R0 \
  -anchor_object $icache_data_ma \
  -anchor_corner tr \
  -offset [list 0 0]

#####################################
### D CACHE DATA
###

set dcache_data_mems [get_cells -hier -filter "ref_name=~gf14_* && full_name=~*dcache*data_mem_*"]
set dcache_data_ma [create_macro_array \
  -num_rows 8 \
  -num_cols 1 \
  -align bottom \
  -horizontal_channel_height [expr $keepout_margin_y] \
  -vertical_channel_width [expr $keepout_margin_x] \
  -orientation N \
  $dcache_data_mems]

create_keepout_margin -type hard -outer $keepout_margins $dcache_data_mems

set_macro_relative_location \
  -target_object $dcache_data_ma \
  -target_corner br \
  -target_orientation R0 \
  -anchor_corner br \
  -offset [list 0 0]

#####################################
### D CACHE TAG
###

set dcache_tag_mems [get_cells -hier -filter "ref_name=~gf14_* && full_name=~*dcache*tag_mem*"]
set dcache_tag_ma [create_macro_array \
  -num_rows 2 \
  -num_cols 1 \
  -align bottom \
  -horizontal_channel_height [expr $keepout_margin_y] \
  -vertical_channel_width [expr $keepout_margin_x] \
  -orientation N \
  $dcache_tag_mems]

create_keepout_margin -type hard -outer $keepout_margins $dcache_tag_mems

set_macro_relative_location \
  -target_object $dcache_tag_ma \
  -target_corner br \
  -target_orientation R0 \
  -anchor_object $dcache_data_ma \
  -anchor_corner bl \
  -offset [list 0 0]

#####################################
### INT + FP RF
###

set int_regfile_mems [get_cells -hier -filter "ref_name=~gf14_* && full_name=~*/int_regfile/*"]
set fp_regfile_mems [get_cells -hier -filter "ref_name=~gf14_* && full_name=~*/fp_regfile/*"]
set ireg_mem_height   [lindex [get_attribute [get_cell -hier $int_regfile_mems] height ] 0]
set ireg_mem_width    [lindex [get_attribute [get_cell -hier $int_regfile_mems] width ] 0]
set freg_mem_height   [lindex [get_attribute [get_cell -hier $fp_regfile_mems] height ] 0]
set freg_mem_width    [lindex [get_attribute [get_cell -hier $fp_regfile_mems] width ] 0]

set fp_regfile_ma [create_macro_array \
  -num_rows 3 \
  -num_cols 1 \
  -align left \
  -horizontal_channel_height [expr $keepout_margin_y] \
  -vertical_channel_width [expr $keepout_margin_x] \
  -orientation FN \
  $fp_regfile_mems]

set_macro_relative_location \
  -target_object $fp_regfile_ma \
  -target_corner bl \
  -target_orientation R0 \
  -anchor_object $icache_data_ma \
  -anchor_corner br \
  -offset [list 0 0]

create_keepout_margin -type hard -outer $keepout_margins $fp_regfile_mems

set int_regfile_ma [create_macro_array \
  -num_rows 2 \
  -num_cols 1 \
  -align left \
  -horizontal_channel_height [expr $keepout_margin_y] \
  -vertical_channel_width [expr $keepout_margin_x] \
  -orientation FN \
  $int_regfile_mems]

set_macro_relative_location \
  -target_object $int_regfile_ma \
  -target_corner bl \
  -target_orientation R0 \
  -anchor_object $fp_regfile_ma \
  -anchor_corner br \
  -offset [list 0 0]

create_keepout_margin -type hard -outer $keepout_margins $int_regfile_mems

#####################################
### BTB Memory
###

set btb_mem [get_cells -hier -filter "ref_name=~gf14_* && full_name=~*btb*tag_mem*"]
set_macro_relative_location \
  -target_object $btb_mem \
  -target_corner tr \
  -target_orientation N \
  -anchor_object $dcache_data_ma \
  -anchor_corner tl \
  -offset [list -$keepout_margin_x -$keepout_margin_y]

create_keepout_margin -type hard -outer $keepout_margins $btb_mem

#####################################
### I CACHE STAT
###

set icache_stat_mem [get_cells -hier -filter "ref_name=~gf14_* && full_name=~*/icache*stat_mem/*"]
set_macro_relative_location \
  -target_object $icache_stat_mem \
  -target_corner tl \
  -target_orientation MY \
  -anchor_object $icache_tag_ma \
  -anchor_corner tr \
  -offset [list $keepout_margin_x -$keepout_margin_y]

create_keepout_margin -type hard -outer $keepout_margins $icache_stat_mem

#####################################
### D CACHE STAT
###

set dcache_stat_mem [get_cells -hier -filter "ref_name=~gf14_* && full_name=~*dcache*stat_mem*"]
set_macro_relative_location \
  -target_object $dcache_stat_mem \
  -target_corner br \
  -target_orientation R0 \
  -anchor_object $dcache_tag_ma \
  -anchor_corner bl \
  -offset [list -$keepout_margin_x $keepout_margin_y]

create_keepout_margin -type hard -outer $keepout_margins $dcache_stat_mem

