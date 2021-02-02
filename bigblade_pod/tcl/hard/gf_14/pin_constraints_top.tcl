source $::env(BSG_DESIGNS_TARGET_TCL_HARD_DIR)/hb_common_variables.tcl


##### local proc ####################

proc place_ports_k2_k4 {pins start_x y} {
  set curr_x $start_x
  set i 0

  while {$i < [sizeof_collection $pins]} {
    set pin [index_collection $pins $i]

    set layer ""
    if {$i % 2 == 0} {
      set layer "K2"
    } else {
      set layer "K4"
    }

    if { [bsg_pins_check_location $curr_x $y $layer] == 1 } {
      set_individual_pin_constraints -ports $pin -allowed_layers $layer -location "$curr_x $y"
      incr i
    }

    set curr_x [expr $curr_x + 0.128]
  }
}


proc place_ruche_ports_k1_k3 {pins start_y x going_up} {
  set i 0
  set curr_y $start_y

  while {$i < [sizeof_collection $pins]} {

    set pin [index_collection $pins $i]

    set layer ""
    if {$i % 2 == 0} {
      set layer "K1"
    } else {
      set layer "K3"
    }

    if { [bsg_pins_check_location $x $curr_y $layer] == 1} {
      set_individual_pin_constraints -ports $pin -allowed_layers $layer -location "$x $curr_y"
      incr i
    } else {
      set check_below [bsg_pins_check_location $x [expr $curr_y - 0.128] $layer]
      set check_above [bsg_pins_check_location $x [expr $curr_y + 0.128] $layer]
      if {$check_below == 1 || $check_above == 1} {
        set_individual_pin_constraints -ports $pin -allowed_layers $layer -location "$x $curr_y"
        incr i
      }
    }
    if {$going_up == 1} {
      set curr_y [expr $curr_y + 0.128]
    } else {
      set curr_y [expr $curr_y - 0.128]
    }
  }
}


proc place_wh_ports_k1_k3 {pins start_y x} {
  set i 0
  set curr_y $start_y
  set count 0


  while {$i < [sizeof_collection $pins]} {

    set pin [index_collection $pins $i]

    set layer ""
    if {$i % 2 == 0} {
      set layer "K1"
    } else {
      set layer "K3"
    }

    if { [bsg_pins_check_location $x $curr_y $layer] == 1} {
      set_individual_pin_constraints -ports $pin -allowed_layers $layer -location "$x $curr_y"
      incr i
      incr count
    }

    if {$count == 2} {
      set curr_y [expr $curr_y + 0.128*2]
      set count 0
    }

    set curr_y [expr $curr_y + 0.128]
  }

}



proc get_hor_link_idx {side y idx} {
  source $::env(BSG_DESIGNS_TARGET_DIR)/tcl/hb_design_constants.tcl
  # side is either "E" or "W"
  # y == tile coord
  # idx pin idx
  set retval -1000000
  if {$side == "E"} {
    set retval [expr $HB_NUM_TILES_Y_P*$HB_LINK_WIDTH_P]
  } elseif {$side == "W"} {
    set retval 0
  }
  set retval [expr $retval + ($y*$HB_LINK_WIDTH_P) + $idx]
  return $retval
}

proc get_ver_link_idx {side x idx} {
  source $::env(BSG_DESIGNS_TARGET_DIR)/tcl/hb_design_constants.tcl
  # side is either "N" or "S"
  # y == tile coord
  # idx pin idx
  set retval -1000000
  if {$side == "S"} {
    set retval [expr $HB_NUM_TILES_X_P*$HB_LINK_WIDTH_P]
  } elseif {$side == "N"} {
    set retval 0
  }
  set retval [expr $retval + ($x*$HB_LINK_WIDTH_P) + $idx]
  return $retval
}

proc get_ruche_link_idx {side y rf idx} {
  source $::env(BSG_DESIGNS_TARGET_DIR)/tcl/hb_design_constants.tcl
  # side is either "E" of "W"
  # y == tile coord
  # rf ruche factor
  # idx pin idx
  set retval -1000000
  if {$side == "E"} {
    set retval [expr $HB_NUM_TILES_Y_P*$HB_RUCHE_LINK_WIDTH_P*$HB_RUCHE_FACTOR_P]
  } elseif {$side == "W"} {
    set retval 0
  }
  set retval [expr $retval + ($y*$HB_RUCHE_LINK_WIDTH_P*$HB_RUCHE_FACTOR_P) + ($rf*$HB_RUCHE_LINK_WIDTH_P) + $idx]
  return $retval
}

proc get_wh_link_idx {side rf idx} {
  source $::env(BSG_DESIGNS_TARGET_DIR)/tcl/hb_design_constants.tcl
  # side is either "E" or "W"
  # rf ruche factor
  # idx pin idx
  set retval -100000
  if {$side == "E"} {
    set retval [expr $HB_WH_RUCHE_FACTOR_P*$HB_WH_LINK_WIDTH_P]
  } elseif {$side == "W"} {
    set retval 0
  }

  set retval [expr $retval + ($rf*$HB_WH_LINK_WIDTH_P) + $idx]
  return $retval
}


#####################################

# core area bound
set core_llx [get_attribute [get_core_area] bounding_box.ll_x]
set core_lly [get_attribute [get_core_area] bounding_box.ll_y]
set core_urx [get_attribute [get_core_area] bounding_box.ur_x]
set core_ury [get_attribute [get_core_area] bounding_box.ur_y]




# clock reset
set clk_pin   [get_ports -filter "name=~clk_i"]
#set reset_pin [get_ports -filter "name=~reset_i"]
set_individual_pin_constraints -ports $clk_pin   -allowed_layers "K4" -location "[expr $vcache_llx+(0.128*9306)] $vcache_ury"
#set_individual_pin_constraints -ports $reset_pin -allowed_layers "K4" -location "[expr $vcache_llx+(0.128*9310)] $vcache_ury"



# tile hor links
for {set y 0} {$y < $HB_NUM_TILES_Y_P} {incr y} {
  set curr_tile [get_cells "pod_mc_y_${y}__x_0__tile"]
  set tile_lly [get_attribute $curr_tile boundary_bounding_box.ll_y]


  # west output / east input
  set west_out_pins [list]
  for {set i 0} {$i < $HB_RUCHE_LINK_WIDTH_P} {incr i} {
    set idx [get_hor_link_idx "W" $y $i]
    append_to_collection west_out_pins [get_ports -filter "name=~hor_link_sif_o[${idx}]"]
    set idx [get_ruche_link_idx "W" $y 1 $i]
    append_to_collection west_out_pins [get_ports -filter "name=~ruche_link_o[${idx}]"]
    set idx [get_ruche_link_idx "W" $y 2 $i]
    append_to_collection west_out_pins [get_ports -filter "name=~ruche_link_o[${idx}]"]
    set idx [get_ruche_link_idx "W" $y 0 $i]
    append_to_collection west_out_pins [get_ports -filter "name=~ruche_link_o[${idx}]"]
  }

  for {set i $HB_RUCHE_LINK_WIDTH_P} {$i < $HB_LINK_WIDTH_P} {incr i} {
    set idx [get_hor_link_idx "W" $y $i]
    append_to_collection west_out_pins [get_ports -filter "name=~hor_link_sif_o[${idx}]"]
  }

  set east_in_pins [list]
  for {set i 0} {$i < $HB_RUCHE_LINK_WIDTH_P} {incr i} {
    set idx [get_hor_link_idx "E" $y $i]
    append_to_collection east_in_pins [get_ports -filter "name=~hor_link_sif_i[${idx}]"]
    set idx [get_ruche_link_idx "E" $y 1 $i]
    append_to_collection east_in_pins [get_ports -filter "name=~ruche_link_i[${idx}]"]
    set idx [get_ruche_link_idx "E" $y 2 $i]
    append_to_collection east_in_pins [get_ports -filter "name=~ruche_link_i[${idx}]"]
    set idx [get_ruche_link_idx "E" $y 0 $i]
    append_to_collection east_in_pins [get_ports -filter "name=~ruche_link_i[${idx}]"]
  }

  for {set i $HB_RUCHE_LINK_WIDTH_P} {$i < $HB_LINK_WIDTH_P} {incr i} {
    set idx [get_hor_link_idx "E" $y $i]
    append_to_collection east_in_pins [get_ports -filter "name=~hor_link_sif_i[${idx}]"]
  }

  place_ruche_ports_k1_k3 $west_out_pins [expr $tile_lly+$TILE_WEST_OUTPUT_OFFSET] $core_llx 1
  place_ruche_ports_k1_k3 $east_in_pins  [expr $tile_lly+$TILE_WEST_OUTPUT_OFFSET] $core_urx 1


  # west input / east output
  set west_in_pins [list]
  for {set i 0} {$i < $HB_RUCHE_LINK_WIDTH_P} {incr i} {
    set idx [get_hor_link_idx "W" $y $i]
    append_to_collection west_in_pins [get_ports -filter "name=~hor_link_sif_i[${idx}]"]
    set idx [get_ruche_link_idx "W" $y 1 $i]
    append_to_collection west_in_pins [get_ports -filter "name=~ruche_link_i[${idx}]"]
    set idx [get_ruche_link_idx "W" $y 2 $i]
    append_to_collection west_in_pins [get_ports -filter "name=~ruche_link_i[${idx}]"]
    set idx [get_ruche_link_idx "W" $y 0 $i]
    append_to_collection west_in_pins [get_ports -filter "name=~ruche_link_i[${idx}]"]
  }

  for {set i $HB_RUCHE_LINK_WIDTH_P} {$i < $HB_LINK_WIDTH_P} {incr i} {
    set idx [get_hor_link_idx "W" $y $i]
    append_to_collection west_in_pins [get_ports -filter "name=~hor_link_sif_i[${idx}]"]
  }

  set east_out_pins [list]
  for {set i 0} {$i < $HB_RUCHE_LINK_WIDTH_P} {incr i} {
    set idx [get_hor_link_idx "E" $y $i]
    append_to_collection east_out_pins [get_ports -filter "name=~hor_link_sif_o[${idx}]"]
    set idx [get_ruche_link_idx "E" $y 1 $i]
    append_to_collection east_out_pins [get_ports -filter "name=~ruche_link_o[${idx}]"]
    set idx [get_ruche_link_idx "E" $y 2 $i]
    append_to_collection east_out_pins [get_ports -filter "name=~ruche_link_o[${idx}]"]
    set idx [get_ruche_link_idx "E" $y 0 $i]
    append_to_collection east_out_pins [get_ports -filter "name=~ruche_link_o[${idx}]"]
  }

  for {set i $HB_RUCHE_LINK_WIDTH_P} {$i < $HB_LINK_WIDTH_P} {incr i} {
    set idx [get_hor_link_idx "E" $y $i]
    append_to_collection east_out_pins [get_ports -filter "name=~hor_link_sif_o[${idx}]"]
  }

  place_ruche_ports_k1_k3 $west_in_pins  [expr $tile_lly+$TILE_WEST_INPUT_OFFSET] $core_llx 1
  place_ruche_ports_k1_k3 $east_out_pins [expr $tile_lly+$TILE_WEST_INPUT_OFFSET] $core_urx 1
}





## Ver links
for {set x 0} {$x < $HB_NUM_TILES_X_P} {incr x} {
  set curr_tile [get_cells "pod_mc_y_0__x_${x}__tile"]
  set tile_llx [get_attribute $curr_tile boundary_bounding_box.ll_x]


  ## north input // south output
  set north_in_pins [list]
  set south_out_pins [list]
  for {set i 0} {$i < $HB_LINK_WIDTH_P} {incr i} {
    set idx [get_ver_link_idx "N" $x $i]
    append_to_collection north_in_pins [get_ports -filter "name=~ver_link_sif_i[$idx]"]
  }
  for {set i 0} {$i < $HB_LINK_WIDTH_P} {incr i} {
    set idx [get_ver_link_idx "S" $x $i]
    append_to_collection south_out_pins [get_ports -filter "name=~ver_link_sif_o[$idx]"]
  }

  place_ports_k2_k4 $north_in_pins  [expr $tile_llx+$NORTH_INPUT_OFFSET] $core_ury
  place_ports_k2_k4 $south_out_pins [expr $tile_llx+$NORTH_INPUT_OFFSET] $core_lly


  ## north output // south input
  set north_out_pins [list]
  set south_in_pins [list]
  for {set i 0} {$i < $HB_LINK_WIDTH_P} {incr i} {
    set idx [get_ver_link_idx "N" $x $i]
    append_to_collection north_out_pins [get_ports -filter "name=~ver_link_sif_o[$idx]"]
  }
  for {set i 0} {$i < $HB_LINK_WIDTH_P} {incr i} {
    set idx [get_ver_link_idx "S" $x $i]
    append_to_collection south_in_pins [get_ports -filter "name=~ver_link_sif_i[$idx]"]
  }

  place_ports_k2_k4 $north_out_pins [expr $tile_llx+$NORTH_OUTPUT_OFFSET] $core_ury
  place_ports_k2_k4 $south_in_pins  [expr $tile_llx+$NORTH_OUTPUT_OFFSET] $core_lly
}



# north vcache wh link
set curr_vcache [get_cells "pod_north_vc_row_vc_x_0__vc"]
set vcache_lly  [get_attribute $curr_vcache boundary_bounding_box.ll_y]

# west out // east in
set west_out_pins [list]
set east_in_pins [list]
for {set i 0} {$i < $HB_WH_LINK_WIDTH_P} {incr i} {
  set idx [get_wh_link_idx "W" 0 $i]
  append_to_collection west_out_pins [get_ports -filter "name=~north_wh_link_sif_o[$idx]"]
  set idx [get_wh_link_idx "W" 1 $i]
  append_to_collection west_out_pins [get_ports -filter "name=~north_wh_link_sif_o[$idx]"]
  set idx [get_wh_link_idx "E" 0 $i]
  append_to_collection east_in_pins [get_ports -filter "name=~north_wh_link_sif_i[$idx]"]
  set idx [get_wh_link_idx "E" 1 $i]
  append_to_collection east_in_pins [get_ports -filter "name=~north_wh_link_sif_i[$idx]"]
}

place_wh_ports_k1_k3 $west_out_pins [expr $vcache_lly + $VCACHE_WEST_OUTPUT_OFFSET] $core_llx
place_wh_ports_k1_k3 $east_in_pins  [expr $vcache_lly + $VCACHE_WEST_OUTPUT_OFFSET] $core_urx

# west in // east out
set west_in_pins [list]
set east_out_pins [list]
for {set i 0} {$i < $HB_WH_LINK_WIDTH_P} {incr i} {
  set idx [get_wh_link_idx "W" 0 $i]
  append_to_collection west_in_pins [get_ports -filter "name=~north_wh_link_sif_i[$idx]"]
  set idx [get_wh_link_idx "W" 1 $i]
  append_to_collection west_in_pins [get_ports -filter "name=~north_wh_link_sif_i[$idx]"]
  set idx [get_wh_link_idx "E" 0 $i]
  append_to_collection east_out_pins [get_ports -filter "name=~north_wh_link_sif_o[$idx]"]
  set idx [get_wh_link_idx "E" 1 $i]
  append_to_collection east_out_pins [get_ports -filter "name=~north_wh_link_sif_o[$idx]"]
}

place_wh_ports_k1_k3 $west_in_pins  [expr $vcache_lly + $VCACHE_WEST_INPUT_OFFSET] $core_llx
place_wh_ports_k1_k3 $east_out_pins [expr $vcache_lly + $VCACHE_WEST_INPUT_OFFSET] $core_urx



# south vcache wh link
set curr_vcache [get_cells "pod_south_vc_row_vc_x_0__vc"]
set vcache_lly  [get_attribute $curr_vcache boundary_bounding_box.ll_y]

# west out // east in
set west_out_pins [list]
set east_in_pins [list]
for {set i 0} {$i < $HB_WH_LINK_WIDTH_P} {incr i} {
  set idx [get_wh_link_idx "W" 0 $i]
  append_to_collection west_out_pins [get_ports -filter "name=~south_wh_link_sif_o[$idx]"]
  set idx [get_wh_link_idx "W" 1 $i]
  append_to_collection west_out_pins [get_ports -filter "name=~south_wh_link_sif_o[$idx]"]
  set idx [get_wh_link_idx "E" 0 $i]
  append_to_collection east_in_pins [get_ports -filter "name=~south_wh_link_sif_i[$idx]"]
  set idx [get_wh_link_idx "E" 1 $i]
  append_to_collection east_in_pins [get_ports -filter "name=~south_wh_link_sif_i[$idx]"]
}

place_wh_ports_k1_k3 $west_out_pins [expr $vcache_lly + $VCACHE_WEST_OUTPUT_OFFSET] $core_llx
place_wh_ports_k1_k3 $east_in_pins  [expr $vcache_lly + $VCACHE_WEST_OUTPUT_OFFSET] $core_urx

# west in // east out
set west_in_pins [list]
set east_out_pins [list]
for {set i 0} {$i < $HB_WH_LINK_WIDTH_P} {incr i} {
  set idx [get_wh_link_idx "W" 0 $i]
  append_to_collection west_in_pins [get_ports -filter "name=~south_wh_link_sif_i[$idx]"]
  set idx [get_wh_link_idx "W" 1 $i]
  append_to_collection west_in_pins [get_ports -filter "name=~south_wh_link_sif_i[$idx]"]
  set idx [get_wh_link_idx "E" 0 $i]
  append_to_collection east_out_pins [get_ports -filter "name=~south_wh_link_sif_o[$idx]"]
  set idx [get_wh_link_idx "E" 1 $i]
  append_to_collection east_out_pins [get_ports -filter "name=~south_wh_link_sif_o[$idx]"]
}

place_wh_ports_k1_k3 $west_in_pins  [expr $vcache_lly + $VCACHE_WEST_INPUT_OFFSET] $core_llx
place_wh_ports_k1_k3 $east_out_pins [expr $vcache_lly + $VCACHE_WEST_INPUT_OFFSET] $core_urx




# north vcache cord
set north_vc_cord_pins [list]
append_to_collection north_vc_cord_pins [get_ports "north_bsg_tag_i*"]
append_to_collection north_vc_cord_pins [get_ports "north_vcache_pod_*_i*"]
place_ports_k2_k4 $north_vc_cord_pins [expr $core_llx + (8049*0.128)] $core_ury

# south vcache cord
set south_vc_cord_pins [list]
append_to_collection south_vc_cord_pins [get_ports "south_bsg_tag_i*"]
append_to_collection south_vc_cord_pins [get_ports "south_vcache_pod_*_i*"]
place_ports_k2_k4 $south_vc_cord_pins [expr $core_llx + (8049*0.128)] $core_lly


# pod cord
set pod_cord_pins [get_ports pod_*_i*]
place_ports_k2_k4 $pod_cord_pins [expr $core_llx + (10500*0.128)] $core_lly


