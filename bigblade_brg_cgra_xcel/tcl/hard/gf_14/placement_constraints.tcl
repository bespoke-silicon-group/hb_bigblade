################################################################################
## Create Bounds
################################################################################

current_design ${DESIGN_NAME}

# Start script fresh
set_locked_objects -unlock [get_cells -hier]
remove_edit_groups -all
remove_bounds -all

source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/tcl/hard/gf_14/adk.tcl

if {${DESIGN_NAME} == "brg_cgra_pod"} {

  #-------------------------------------------------------------------------
  # Floorplan variables
  #-------------------------------------------------------------------------
  
  # Power ring metal width and spacing
  
  #set M1_min_width   [get_attribute [get_layer M1] min_width]
  #set M1_min_spacing [get_attribute [get_layer M1] min_spacing]
  
  #set p_ring_width   [expr 48 * $M1_min_width];   # Arbitrary!
  #set p_ring_spacing [expr 24 * $M1_min_spacing]; # Arbitrary!
  
  # Core bounding box margins
  
  #set core_margin_t [expr ([llength $pwr_net_list] * ($p_ring_width + $p_ring_spacing)) + $p_ring_spacing]
  #set core_margin_b [expr ([llength $pwr_net_list] * ($p_ring_width + $p_ring_spacing)) + $p_ring_spacing]
  #set core_margin_r [expr ([llength $pwr_net_list] * ($p_ring_width + $p_ring_spacing)) + $p_ring_spacing]
  #set core_margin_l [expr ([llength $pwr_net_list] * ($p_ring_width + $p_ring_spacing)) + $p_ring_spacing]
  set core_margin_t 0
  set core_margin_b 0
  set core_margin_r 0
  set core_margin_l 0

  set array_margin 12
  set welltab_margin 3
  set reserved_width 52  

  set tile_height [core_height]
  set tile_width  [core_width]
  
  set keepout_margin_x [expr 6*[unit_width]]
  set keepout_margin_y [expr 1*[unit_height]]
  set keepout_margins [list $keepout_margin_x $keepout_margin_y $keepout_margin_x $keepout_margin_y]
  
  set reserved_width 56
  # set reserved_height 20

  # PE array
  set pe_width  [round_up_to_nearest 47 [unit_width]]
  set pe_height [round_up_to_nearest 85 [unit_height]]
  
  set pe_num_x 8
  set pe_num_y 8
  
  set pe_margin_x 2
  set pe_margin_y 2
  
  set pe_origin_x [expr $core_margin_l+$welltab_margin+$reserved_width+$array_margin]
  set pe_origin_y [expr $core_margin_b+$welltab_margin+$array_margin]
  
  set array_margin 12
  set welltab_margin 3
  
  set array_width  [expr $pe_num_x*$pe_width + ($pe_num_x-1)*$pe_margin_x]
  set array_height [expr $pe_num_y*$pe_height+ ($pe_num_y-1)*$pe_margin_y]
  
  set sp_lx [expr $core_margin_l+$welltab_margin+1]
  set sp_ly [expr $core_margin_b+$welltab_margin+$array_margin]
  set sp_rx [expr $sp_lx+$reserved_width]
  set sp_ry [expr $sp_ly+$array_margin+$array_height]
  
  set rf_width 54
  set rf_height 83
  set rf_margin [expr ($sp_ry-$sp_ly)/4-$rf_height]
  
  set total_width  [expr $core_margin_l+$core_margin_r+$welltab_margin*2+$reserved_width+$array_margin+$array_width]
  set total_height [expr $core_margin_b+$core_margin_t+$welltab_margin*2+$array_margin+$array_height+$array_margin]
  
  # Take all clock ports and place them center-left
  
  # createFence cgra_xcel/dpath/scratchpad $sp_lx $sp_ly $sp_rx $sp_ry
 
  set sram_mems [get_cells -hier -filter "ref_name=~gf14_* && full_name=~*brg_rf_1024_32"]
  set sram_ma [create_macro_array \
    -num_rows 4 \
    -num_cols 1 \
    -align left \
    -horizontal_channel_height [expr ($rf_height+$rf_margin)/2+$keepout_margin_y] \
    -vertical_channel_width [expr $keepout_margin_x] \
    -orientation [list FN N FN N] \
    $sram_mems
  ]

  create_keepout_margin -type hard -outer $keepout_margins $sram_mems

  set_macro_relative_location \
    -target_object $sram_ma \
    -target_corner bl \
    -target_orientation R0 \
    -anchor_corner bl \
    -offset [list $sp_lx $sp_ly]
   
  #for {set idx 0} {$idx < 4} {incr idx} {
  #  set cur_lx [expr $sp_lx]
  #  set cur_ly [expr $sp_ly+($rf_height+$rf_margin)*$idx]
  #  set cur_rx [expr $cur_lx+$rf_width]
  #  set cur_ry [expr $cur_ly+$rf_height]
  #  if {$idx > 0 && $idx < 3} {
  #    rotate_objects \
  #      [get_cells pod/hb_cgra_xcel/cgra_xcel/dpath/scratchpad/banks__$idx/sram/sram/brg_rf_1024_32] \
  #      -orient FN
  #  } else {
  #    rotate_objects \
  #      [get_cells pod/hb_cgra_xcel/cgra_xcel/dpath/scratchpad/banks__$idx/sram/sram/brg_rf_1024_32] \
  #      -orient N
  #  }
  #  create_bound pod/hb_cgra_xcel/cgra_xcel/dpath/scratchpad/banks__$idx/sram/sram/brg_rf_1024_32 \
  #    -name BANK_rc__$idx \
  #    -boundary [list [list $cur_lx $cur_ly] [list $cur_rx $cur_ry]] \
  #    -type soft
  #  #setObjFPlanBox Instance pod/hb_cgra_xcel/cgra_xcel/dpath/scratchpad/banks__$idx/sram/sram/brg_rf_1024_32 $cur_lx $cur_ly $cur_rx $cur_ry
  #}
}
