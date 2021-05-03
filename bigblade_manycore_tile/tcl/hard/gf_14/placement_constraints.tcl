puts "BSG-info: Running script [info script]\n"

set_app_options -name plan.place.auto_generate_blockages -value false

# SRAM margin
set margin_x [expr 1*[unit_width]]
set margin_y [expr 1*[unit_height]]
set boundary_cell_width 0.672
set boundary_cell_height 0.48


## MANYCORE TILES
set icache_path "proc/h_z/vcore/icache0/imem_0/macro_mem"
set dmem_path   "proc/h_z/vcore/dmem/macro_mem"


set icache_cell [get_cell -hier  -filter "full_name=~$icache_path"]
create_keepout_margin -type hard -outer "$margin_x $margin_y $margin_x $margin_y" $icache_cell
set_macro_relative_location -target_object $icache_cell -target_corner bl -target_orientation MY \
                                                        -anchor_corner bl \
                                                        -offset "[expr $margin_x+$boundary_cell_width] [expr $margin_y+$boundary_cell_height]"

set dmem_cell [get_cell -hier -filter "full_name=~$dmem_path"]
create_keepout_margin -type hard -outer "$margin_x $margin_y $margin_x $margin_y" $dmem_cell
set_macro_relative_location -target_object $dmem_cell -target_corner tr -target_orientation R0 \
                                                      -anchor_corner tr \
                                                      -offset "[expr -$margin_x-$boundary_cell_width] [expr -$margin_y-$boundary_cell_height]"



puts "BSG-info: Completed script [info script]\n"
