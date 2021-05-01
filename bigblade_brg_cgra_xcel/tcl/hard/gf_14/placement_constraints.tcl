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
  
  set tile_height [core_height]
  set tile_width  [core_width]
  
  set keepout_margin_x [expr 6*[unit_width]]
  set keepout_margin_y [expr 1*[unit_height]]
  set keepout_margins [list $keepout_margin_x $keepout_margin_y $keepout_margin_x $keepout_margin_y]

  # PE array
  set pe_width  [round_up_to_nearest 37 [unit_width]]
  set pe_height [round_up_to_nearest 82 [unit_height]]
  
  set pe_num_x 8
  set pe_num_y 8
  
  set pe_margin_x 3.276
  set pe_margin_y 4.32
  
  set array_height [expr ($pe_margin_y + $pe_height) * $pe_num_y - $pe_margin_y]
  set array_width  [expr ($pe_margin_x + $pe_width) * $pe_num_x - $pe_margin_x]
  set pe_origin_y [expr ($tile_height - $array_height) / 2]
  set pe_origin_x [expr $tile_width - $array_width - $keepout_margin_x]
  
  set sp_lx [expr 5+$keepout_margin_x]
  set sp_ly [expr $pe_origin_y + 1*$array_height/4]
  set sp_ry [expr $pe_origin_y + 3*$array_height/4]
  
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
  add_to_bound ${isdr_bound} [get_cells -hier -filter "full_name=~*/isdr_phy/*"]
  add_to_bound ${osdr_bound} [get_cells -hier -filter "full_name=~*/osdr_phy/*"]

}
