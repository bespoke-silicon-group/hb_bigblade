puts "BSG-info: Running script [info script]\n"

########################################
## Source common scripts
source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_common_variables.tcl

# constraints
set keepout_margin_x [expr 6*[unit_width]]
set keepout_margin_y [expr 1*[unit_height]]
set keepout_margins [list $keepout_margin_x $keepout_margin_y $keepout_margin_x $keepout_margin_y]

set tile_width  [core_width]
set tile_height [core_height]

# PE array
set pe_width  [round_up_to_nearest 37 [unit_width]]
set pe_height [round_up_to_nearest 83 [unit_height]]

set pe_num_x 8
set pe_num_y 8

# This is variable depending on PE size MIB alignment
set pe_margin_x 3.276
set pe_margin_y 9.12

set array_height [expr ($pe_margin_y + $pe_height) * $pe_num_y - $pe_margin_y]
set array_width  [expr ($pe_margin_x + $pe_width) * $pe_num_x - $pe_margin_x]
set pe_origin_y 3.276
set pe_origin_x [expr $tile_width - $array_width - $keepout_margin_x]

foreach {idx_x} {7 6 5 4 3 2 1 0} {
  foreach {idx_y} {0 1 2 3 4 5 6 7} {
    set id [expr $idx_x+$idx_y*$pe_num_x]
    append_to_collection pe_cells [get_cells pod/hb_cgra_xcel/cgra_xcel/dpath/cgra_dpath_PE_rc__$id]
  }
}

bsg_create_block_array_grid $pe_cells \
  -grid mib_placement_grid \
  -relative_to core \
  -x $pe_origin_x \
  -y $pe_origin_y \
  -min_channel [list $pe_margin_x $pe_margin_y] \
  -rows $pe_num_y \
  -cols $pe_num_x \
  -width $pe_width \
  -height $pe_height

puts "BSG-info: Completed script [info script]\n"
