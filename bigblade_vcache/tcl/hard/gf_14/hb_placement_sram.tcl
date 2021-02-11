puts "BSG-info: Running script [info script]\n"


# SRAM margin
set margin_x [expr 6*[unit_width]]
set margin_y [expr 1*[unit_height]]

## MANYCORE TILES
set master_tile [get_cells "pod_mc_y_0__x_0__tile"]
set icache_path "*/proc/h_z/vcore/icache0/imem_0/macro_mem"
set dmem_path   "*/proc/h_z/vcore/dmem/macro_mem"


set icache_cell [get_cell -hier -of ${master_tile} -filter "full_name=~$icache_path"]
create_keepout_margin -type hard -outer "$margin_x $margin_y $margin_x $margin_y" $icache_cell
set_macro_relative_location -target_object $icache_cell -target_corner bl -target_orientation MY \
                                                        -anchor_corner bl \
                                                        -offset "$margin_x $margin_y"

set dmem_cell [get_cell -hier -of ${master_tile} -filter "full_name=~$dmem_path"]
create_keepout_margin -type hard -outer "$margin_x $margin_y $margin_x $margin_y" $dmem_cell
set_macro_relative_location -target_object $dmem_cell -target_corner tr -target_orientation R0 \
                                                      -anchor_corner tr \
                                                      -offset "-$margin_x -$margin_y"



# VCACHE TILE
set master_vcache [get_cells "pod_north_vc_row_vc_x_0__vc"]

set data_mem_path "*/cache/data_mem/macro_mem"
set tag_mem_path "*/cache/tag_mem/macro_mem"
set stat_mem_path "*/cache/stat_mem/macro_mem"


set data_mem_cell [get_cells -hier -of $master_vcache -filter "full_name=~$data_mem_path"]
create_keepout_margin -type hard -outer "$margin_x $margin_y $margin_x $margin_y" $data_mem_cell
set_macro_relative_location -target_object $data_mem_cell -target_corner br -target_orientation R0 \
                                                          -anchor_corner br \
                                                          -offset "-$margin_x [expr $margin_y*1]"

set tag_mem_cell [get_cells -hier -of $master_vcache -filter "full_name=~$tag_mem_path"]
create_keepout_margin -type hard -outer "$margin_x $margin_y $margin_x $margin_y" $tag_mem_cell
set_macro_relative_location -target_object $tag_mem_cell -target_corner bl -target_orientation MY \
                                                         -anchor_corner bl \
                                                         -offset "$margin_x [expr $margin_y*1]"

set stat_mem_cell [get_cells -hier -of $master_vcache -filter "full_name=~$stat_mem_path"]
create_keepout_margin -type hard -outer "$margin_x $margin_y $margin_x $margin_y" $stat_mem_cell
set_macro_relative_location -target_object $stat_mem_cell -target_corner bl -target_orientation MY \
                                                          -anchor_object $tag_mem_cell \
                                                          -anchor_corner tl -offset "0 [expr $margin_y*1]"


puts "BSG-info: Completed script [info script]\n"
