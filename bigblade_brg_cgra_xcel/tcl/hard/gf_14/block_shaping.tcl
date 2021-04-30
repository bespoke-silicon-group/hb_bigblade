puts "BSG-info: Running script [info script]\n"

########################################
## Source common scripts
source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_common_variables.tcl

# constraints
set keepout_margin_x [expr 6*[unit_width]]
set keepout_margin_y [expr 1*[unit_height]]
set keepout_margins [list $keepout_margin_x $keepout_margin_y $keepout_margin_x $keepout_margin_y]

set core_margin_t 0
set core_margin_b 0
set core_margin_r 0
set core_margin_l 0

set array_margin 12
set welltab_margin 3
set reserved_width 76

# PE array
set pe_width  [round_up_to_nearest 47 [unit_width]]
set pe_height [round_up_to_nearest 85 [unit_height]]

set pe_num_x 8
set pe_num_y 8

set pe_margin_x 2
set pe_margin_y 2

set pe_origin_x [expr $core_margin_l+$welltab_margin+$reserved_width+$array_margin]
set pe_origin_y [expr $core_margin_b+$welltab_margin+$array_margin]

foreach {idx_x} {0 1 2 3 4 5 6 7} {
  foreach {idx_y} {7 6 5 4 3 2 1 0} {
    set id [expr $idx_x+$idx_y*$pe_num_x]
    append_to_collection pe_cells [get_cells pod/hb_cgra_xcel/cgra_xcel/dpath/cgra/dpath/PE_rc__$id]
  }
}

bsg_create_block_array_grid $pe_cells \
  -grid mib_placement_grid \
  -relative_to core \
  -x $pe_origin_x\
  -y $pe_origin_y \
  -rows $pe_num_y \
  -cols $pe_num_x \
  -min_channel [list $pe_margin_x  $pe_margin_y] \
  -width $pe_width \
  -height $pe_height

#for {set idx_y 0} {$idx_y < $pe_num_y} {incr idx_y} {
#  for {set idx_x 0} {$idx_x < $pe_num_x} {incr idx_x} {
#    set cur_lx [expr $pe_origin_x+($pe_width +$pe_margin_x)*$idx_y]
#    set cur_ly [expr $pe_origin_y+($pe_height+$pe_margin_y)*($pe_num_x-1-$idx_x)]
#    set cur_rx [expr $cur_lx+$pe_width]
#    set cur_ry [expr $cur_ly+$pe_height]
#
#      
#
#    set id [expr $idx_x+$idx_y*$pe_num_x]
#    # setObjFPlanBox Instance cgra_xcel/dpath/cgra/dpath/PE_rc__$id $cur_lx $cur_ly $cur_rx $cur_r
#    create_bound pod/hb_cgra_xcel/cgra_xcel/dpath/cgra/dpath/PE_rc__$id \
#      -name PE_rc__$id \
#      -boundary [list [list $cur_lx $cur_ly] [list $cur_rx $cur_ry]] \
#      -type soft
#    #createFence pod/hb_cgra_xcel/cgra_xcel/dpath/cgra/dpath/PE_rc__$id $cur_lx $cur_ly $cur_rx $cur_ry
#  }
#}


puts "BSG-info: Completed script [info script]\n"
