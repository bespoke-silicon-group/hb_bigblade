################################################################################
## Create Bounds
################################################################################

current_design ${DESIGN_NAME}

# Start script fresh
set_locked_objects -unlock [get_cells -hier]
remove_bounds -all
remove_edit_groups -all

set tile_width  [core_width]
set tile_height [core_height]

set keepout_margin_x [expr 6*[unit_width]]
set keepout_margin_y [expr 1*[unit_height]]
set keepout_margins [list $keepout_margin_x $keepout_margin_y $keepout_margin_x $keepout_margin_y]

# Switch to tile node
current_design bsg_blackparrot_multicore_tile_node

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

set icache_tag_mems [get_cells -hier -filter "ref_name=~gf14_* && full_name=~*/icache*tag_mem*"]
set icache_tag_ma [create_macro_array \
  -num_rows 2 \
  -num_cols 1 \
  -align bottom \
  -horizontal_channel_height [expr 2*$keepout_margin_y] \
  -vertical_channel_width [expr 2*$keepout_margin_x] \
  -orientation FN \
  $icache_tag_mems]

create_keepout_margin -type hard -outer $keepout_margins $icache_tag_mems

set_macro_relative_location \
  -target_object $icache_tag_ma \
  -target_corner bl \
  -target_orientation R0 \
  -anchor_object $icache_data_ma \
  -anchor_corner br \
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

set dcache_tag_mems [get_cells -hier -filter "ref_name=~gf14_* && full_name=~*/dcache*tag_mem*"]
set dcache_tag_ma [create_macro_array \
  -num_rows 2 \
  -num_cols 1 \
  -align bottom \
  -horizontal_channel_height [expr 2*$keepout_margin_y] \
  -vertical_channel_width [expr 2*$keepout_margin_x] \
  -orientation N \
  $dcache_tag_mems]

create_keepout_margin -type hard -outer $keepout_margins $dcache_tag_mems

set dcache_tag_margin 0
set_macro_relative_location \
  -target_object $dcache_tag_ma \
  -target_corner br \
  -target_orientation R0 \
  -anchor_object $dcache_data_ma \
  -anchor_corner bl \
  -offset [list 0 0]

#####################################
### CCE Directory
###

set directory_mems [get_cells -hier -filter "ref_name=~gf14_* && full_name=~*cce*directory*"]
set directory_mem_height [get_attribute -objects [index_collection $directory_mems 0] -name height]
set directory_mem_width [get_attribute -objects [index_collection $directory_mems 0] -name width]
set directory_ma [create_macro_array \
  -num_rows 2 \
  -num_cols 4 \
  -align bottom \
  -horizontal_channel_height [expr 2*$keepout_margin_y] \
  -vertical_channel_width [expr 2*$keepout_margin_x] \
  -orientation [list N N N N N N N N] \
  $directory_mems]

set_macro_relative_location \
  -target_object $directory_ma \
  -target_corner bl \
  -target_orientation R0 \
  -anchor_corner bl \
  -offset [list [expr $tile_width/2-2*$directory_mem_width-2*$keepout_margin_x] [expr 0]]

create_keepout_margin -type hard -outer $keepout_margins $directory_mems

###################################
#### FP RF
####

set fp_regfile_mems [get_cells -hier -filter "ref_name=~gf14_* && full_name=~*/fp_regfile/*"]
set fp_regfile_ma [create_macro_array \
  -num_rows 1 \
  -num_cols 3 \
  -align left \
  -horizontal_channel_height [expr 2*$keepout_margin_y] \
  -vertical_channel_width [expr 2*$keepout_margin_x] \
  -orientation FN \
  $fp_regfile_mems]

set_macro_relative_location \
  -target_object $fp_regfile_ma \
  -target_corner br \
  -target_orientation R0 \
  -anchor_object $directory_ma \
  -anchor_corner tr \
  -offset [list 0 0]

create_keepout_margin -type hard -outer $keepout_margins $fp_regfile_mems

#####################################
### INT RF
###

set int_regfile_mems [get_cells -hier -filter "ref_name=~gf14_* && full_name=~*/int_regfile/*"]
set int_regfile_ma [create_macro_array \
  -num_rows 1 \
  -num_cols 2 \
  -align left \
  -horizontal_channel_height [expr 2*$keepout_margin_y] \
  -vertical_channel_width [expr 2*$keepout_margin_x] \
  -orientation FN \
  $int_regfile_mems]

set_macro_relative_location \
  -target_object $int_regfile_ma \
  -target_corner br \
  -target_orientation R0 \
  -anchor_object $fp_regfile_ma \
  -anchor_corner bl \
  -offset [list 0 0]

create_keepout_margin -type hard -outer $keepout_margins $int_regfile_mems

#####################################
### CCE Instance
###

set cce_instr_ram [get_cells -hier -filter "ref_name=~gf14_* && full_name=~*cce/*inst_ram*"]
set cce_instr_ma [create_macro_array \
  -num_rows 1 \
  -num_cols 1 \
  -align bottom \
  -horizontal_channel_height [expr 2*$keepout_margin_y] \
  -vertical_channel_width [expr 2*$keepout_margin_x] \
  -orientation N \
  $cce_instr_ram]

set_macro_relative_location \
  -target_object $cce_instr_ma \
  -target_corner br \
  -target_orientation R0 \
  -anchor_object $fp_regfile_ma \
  -anchor_corner tr \
  -offset [list 0 0]

create_keepout_margin -type hard -outer $keepout_margins $cce_instr_ram

#####################################
### BTB Memory
###

set btb_mem [get_cells -hier -filter "ref_name=~gf14_* && full_name=~*/btb/*"]
set_macro_relative_location \
  -target_object $btb_mem \
  -target_corner tr \
  -target_orientation FN \
  -anchor_object $dcache_data_ma \
  -anchor_corner tl \
  -offset [list $keepout_margin_x -$keepout_margin_y]

create_keepout_margin -type hard -outer $keepout_margins $btb_mem

#####################################
### I CACHE STAT
###

set icache_stat_mem [get_cells -hier -filter "ref_name=~gf14_* && full_name=~*/icache*stat_mem/*"]
set icache_stat_margin 0
set_macro_relative_location \
  -target_object $icache_stat_mem \
  -target_corner tl \
  -target_orientation MY \
  -anchor_object $icache_tag_ma \
  -anchor_corner tr \
  -offset [list $keepout_margin_x $keepout_margin_y]

create_keepout_margin -type hard -outer $keepout_margins $icache_stat_mem

#####################################
### D CACHE STAT
###

set dcache_stat_mem [get_cells -hier -filter "ref_name=~gf14_* && full_name=~*/dcache*stat_mem*"]
set_macro_relative_location \
  -target_object $dcache_stat_mem \
  -target_corner br \
  -target_orientation R0 \
  -anchor_object $dcache_tag_ma \
  -anchor_corner tr \
  -offset [list -$keepout_margin_x $keepout_margin_y]

create_keepout_margin -type hard -outer $keepout_margins $dcache_stat_mem

current_design bsg_blackparrot_multicore_pod
