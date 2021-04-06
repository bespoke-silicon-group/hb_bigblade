puts "BSG-info: Running script [info script]\n"


source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_common_variables.tcl

set_app_options -name plan.place.auto_generate_blockages -value false

# SRAM margin
set margin_x [expr 6*[unit_width]]
set margin_y [expr 1*[unit_height]]


# VCACHE TILE
set data_mem_path "cache/data_mem/macro_mem"
set tag_mem_path "cache/tag_mem/macro_mem"
set stat_mem_path "cache/stat_mem/macro_mem"


set data_mem_cell [get_cells -hier -filter "full_name=~$data_mem_path"]
create_keepout_margin -type hard -outer "$margin_x $margin_y $margin_x $margin_y" $data_mem_cell
set_macro_relative_location -target_object $data_mem_cell -target_corner bl -target_orientation MY \
                                                          -anchor_corner bl \
                                                          -offset "$margin_x [expr $margin_y*1]"

set tag_mem_cell [get_cells -hier -filter "full_name=~$tag_mem_path"]
create_keepout_margin -type hard -outer "$margin_x $margin_y $margin_x $margin_y" $tag_mem_cell
set_macro_relative_location -target_object $tag_mem_cell -target_corner br -target_orientation R0 \
                                                         -anchor_corner br \
                                                         -offset "-$margin_x [expr $margin_y*1]"

set stat_mem_cell [get_cells -hier -filter "full_name=~$stat_mem_path"]
create_keepout_margin -type hard -outer "$margin_x $margin_y $margin_x $margin_y" $stat_mem_cell
set_macro_relative_location -target_object $stat_mem_cell -target_corner br -target_orientation R0 \
                                                          -anchor_object $tag_mem_cell \
                                                          -anchor_corner tr -offset "0 [expr $margin_y*1]"

puts "BSG-info: Completed script [info script]\n"
