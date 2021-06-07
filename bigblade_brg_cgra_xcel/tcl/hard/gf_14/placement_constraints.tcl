################################################################################
## Create Bounds
################################################################################

current_design ${DESIGN_NAME}

# Start script fresh
set_locked_objects -unlock [get_cells -hier]
remove_placement_blockages -all
remove_edit_groups -all
remove_bounds -all

source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/tcl/hard/gf_14/adk.tcl

if {${DESIGN_NAME} == "brg_cgra_pod"} {

  #-------------------------------------------------------------------------
  # Floorplan variables
  #-------------------------------------------------------------------------
  
  set tile_height [core_height]
  set tile_width  [core_width]
  
  set keepout_margin_x [expr 6*[unit_width]]
  set keepout_margin_y [expr 1*[unit_height]]
  set keepout_margins [list $keepout_margin_x $keepout_margin_y $keepout_margin_x $keepout_margin_y]

  # PE array
  set master_pe "PE_rc__0"
  set pe_width [get_attribute [get_cell -hier $master_pe] width]
  set pe_height [get_attribute [get_cell -hier $master_pe] height]
  
  set pe_num_x 8
  set pe_num_y 8
  
  set pe_margin_x 3.276
  set pe_margin_y 9.12
  
  set array_height [expr ($pe_margin_y + $pe_height) * $pe_num_y - $pe_margin_y]
  set array_width  [expr ($pe_margin_x + $pe_width) * $pe_num_x - $pe_margin_x]
  set pe_origin_x [expr $tile_width - $array_width - 3.276]
  set pe_origin_y $keepout_margin_y
  
  set sp_lx [expr 15+$keepout_margin_x]
  set sp_ly [expr $pe_origin_y + 1*$array_height/16]
  set sp_ry [expr $pe_origin_y + 15*$array_height/16]
  
  set rf_width 54
  set rf_height 83
  set rf_margin_y [expr ($sp_ry-$sp_ly-4*$rf_height)/3]
  
  set sram_mems [get_cells -hier -filter "ref_name=~gf14_* && full_name=~*brg_rf_1024_32"]
  set sram_ma [create_macro_array \
    -num_rows 4 \
    -num_cols 1 \
    -align left \
    -horizontal_channel_height [expr $rf_margin_y] \
    -vertical_channel_width [expr $keepout_margin_x] \
    -orientation FN \
    $sram_mems
  ]
  create_keepout_margin -type hard -outer $keepout_margins $sram_mems

  set_macro_relative_location \
    -target_object $sram_ma \
    -target_corner bl \
    -target_orientation R0 \
    -anchor_corner bl \
    -offset [list $sp_lx $sp_ly]

  set isdr_bound [create_bound -name "isdr" -type soft -boundary {{0 0} {5 757.4}}]
  set osdr_bound [create_bound -name "osdr" -type soft -boundary {{0 0} {5 757.4}}]
  add_to_bound $isdr_bound [get_cells -hier -filter "full_name=~*/isdr_phy/*"]
  add_to_bound $osdr_bound [get_cells -hier -filter "full_name=~*/osdr_phy/*"]

  ##### Broadcast placement
  foreach {idx_x} {0 1 2 3 4 5 6 7} {
    foreach {idx_y} {0 1 2 3 4 5 6 7} {
      set id [expr $idx_y + $pe_num_y * $idx_x]
      set cell [get_cells -hier col_broadcast_${idx_x}__row_broadcast_${idx_y}__r_buf_*]
      set x [expr [get_attribute [get_cell -hier "PE_rc__${id}"] bounding_box.ll_x] - $pe_margin_x/2]
      set y [expr [get_attribute [get_cell -hier "PE_rc__${id}"] bounding_box.ur_y]]
      move_objects $cell -x $x -y $y
      set_attribute $cell -name physical_status -value placed
    }
    set id [expr $pe_num_y/2-1 + $pe_num_x*$idx_x]
    set cell [get_cells -hier col_broadcast_${idx_x}__c_buf_*]
    set x [expr [get_attribute [get_cell -hier "PE_rc__${id}"] bounding_box.ll_x] - $pe_margin_x/2]
    set y [expr [get_attribute [get_cell -hier "PE_rc__${id}"] bounding_box.ll_y]]
    move_objects $cell -x $x -y $y
    set_attribute $cell -name physical_status -value placed
  }
  set id 28
  set cell [get_cells -hier cter_buf_*]
  set x [expr [get_attribute [get_cell -hier "PE_rc__${id}"] bounding_box.ll_x] + $pe_width/2]
  set y [expr [get_attribute [get_cell -hier "PE_rc__${id}"] bounding_box.ur_y] + $pe_margin_y/2]
  move_objects $cell -x $x -y $y
  set_attribute $cell -name physical_status -value placed

  ##### Reduction placement
  foreach {idx_x} {0 1 2 3 4 5 6 7} {
    set id [expr 1+$pe_num_y*$idx_x]
    set cell [get_cells -hier "row_reduce_${idx_x}__rb8_b0123_*"]
    set x [expr [get_attribute [get_cell -hier "PE_rc__${id}"] bounding_box.ll_x] - $pe_margin_x/2]
    set y [expr [get_attribute [get_cell -hier "PE_rc__${id}"] bounding_box.ll_y] - $pe_margin_y/2]
    move_objects $cell -x $x -y $y
    set_attribute $cell -name physical_status -value placed

    set id [expr 3+$pe_num_y*$idx_x]
    set cell [get_cells -hier "row_reduce_${idx_x}__rb8_b01234567_*"]
    set x [expr [get_attribute [get_cell -hier "PE_rc__${id}"] bounding_box.ll_x] - $pe_margin_x/2]
    set y [expr [get_attribute [get_cell -hier "PE_rc__${id}"] bounding_box.ll_y] - $pe_margin_y/2]
    move_objects $cell -x $x -y $y
    set_attribute $cell -name physical_status -value placed

    set id [expr 5+$pe_num_y*$idx_x]
    set cell [get_cells -hier "row_reduce_${idx_x}__rb8_b4567_*"]
    set x [expr [get_attribute [get_cell -hier "PE_rc__${id}"] bounding_box.ll_x] - $pe_margin_x/2]
    set y [expr [get_attribute [get_cell -hier "PE_rc__${id}"] bounding_box.ll_y] - $pe_margin_y/2]
    move_objects $cell -x $x -y $y
    set_attribute $cell -name physical_status -value placed
  }

  set id 12
  set cell [get_cells -hier "col_rb8_b0123_*"]
  set x [expr [get_attribute [get_cell -hier "PE_rc__${id}"] bounding_box.ll_x] - $pe_width/2]
  set y [expr [get_attribute [get_cell -hier "PE_rc__${id}"] bounding_box.ll_y] - $pe_margin_y/2]
  move_objects $cell -x $x -y $y
  set_attribute $cell -name physical_status -value placed
   
  set id 44
  set cell [get_cells -hier "col_rb8_b4567_*"]
  set x [expr [get_attribute [get_cell -hier "PE_rc__${id}"] bounding_box.ll_x] - $pe_width/2]
  set y [expr [get_attribute [get_cell -hier "PE_rc__${id}"] bounding_box.ll_y] - $pe_margin_y/2]
  move_objects $cell -x $x -y $y
  set_attribute $cell -name physical_status -value placed

  set id 28
  set cell [get_cells -hier "col_rb8_b01234567_*"]
  set x [expr [get_attribute [get_cell -hier "PE_rc__${id}"] bounding_box.ll_x] - $pe_width/2]
  set y [expr [get_attribute [get_cell -hier "PE_rc__${id}"] bounding_box.ll_y] - $pe_margin_y/2]
  move_objects $cell -x $x -y $y
  set_attribute $cell -name physical_status -value placed

  ### Blockages
  set llx [get_attribute [get_cell -hier "PE_rc__7" ] bounding_box.ll_x]
  #set lly [get_attribute [get_cell -hier "PE_rc__7" ] bounding_box.ll_y]
  set lly 0
  #set urx [get_attribute [get_cell -hier "PE_rc__56"] bounding_box.ur_x]
  set urx $tile_width
  set ury [get_attribute [get_cell -hier "PE_rc__56"] bounding_box.ur_y]

  create_placement_blockage -name "cgra_blockage" -type allow_buffer_only -blocked_percentage 100 -boundary [list [list $llx $lly] [list $urx $ury]]
  #create_placement_blockage -name "cgra_blockage" -type hard -boundary [list [list $llx $lly] [list $urx $ury]]

  set ko [list $keepout_margin_x $keepout_margin_y $pe_margin_x $keepout_margin_y]
  set PEs [get_cells -hier "PE_rc__*"]
  #create_keepout_margin -type hard -outer $ko $PEs
  #create_keepout_margin -type hard -inner $keepout_margins $PEs

  #set tag_bound [create_bound -name "btx" -type soft \
  #      -boundary [list [list 0 [expr $tile_height - 100]] [list $llx $tile_height]]]
  #add_to_bound $tag_bound [get_cells btm]
  #add_to_bound $tag_bound [get_cells btc*]

  ### Placement bounds
  #set osdr_bound [create_bound -name "osdr" -type soft -boundary {{0 0} {5 757.4}}]
  #add_to_bound $isdr_bound [get_cells -hier -filter "full_name=~*/isdr_phy/*"]
#  set ce_bound [create_bound -name "ce" \
#    -type soft \
#    -boundary [list [list [expr $pe_origin_x - 15.628] 0] [list $tile_width 11.68]]]
#  add_to_bound $ce_bound [get_cells -hier CE_e__*]
#
#  set me_s_bound [create_bound -name "me_s" \
#    -type soft \
#    -boundary [list [list [expr $pe_origin_x - 40] 0] [list [expr $pe_origin_x] $tile_height]]]
#  add_to_bound $me_s_bound [get_cells -hier CE_s]
#  foreach {i} {0 1 2 3 4 5 6 7} {
#    add_to_bound $me_s_bound [get_cells -hier ME__${i}]
#  }
#
#  set me_n_bound [create_bound -name "me_n" \
#    -type soft \
#    -boundary [list [list [expr $pe_origin_x - 15.628] [expr $tile_height-17.76]] [list $tile_width $tile_height]]]
#  foreach {i} {8 9 10 11 12 13 14 15} {
#    add_to_bound $me_n_bound [get_cells -hier ME__${i}]
#  }
#}
