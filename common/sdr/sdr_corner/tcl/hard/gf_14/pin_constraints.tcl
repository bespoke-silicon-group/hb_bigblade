puts "BSG-info: Running script [info script]\n"

source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_common_variables.tcl

remove_individual_pin_constraints
remove_block_pin_constraints
set_block_pin_constraints -allowed_layers {C4 C5 K1 K2 K3 K4}


proc place_pins_k2_k4 {pins start_x y} {
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
      #puts $curr_x
      set_individual_pin_constraints -ports $pin -allowed_layers $layer -location "$curr_x $y"
      incr i
    }

    set curr_x [expr $curr_x + 0.128]
  }
}

proc place_pins_c5 {pins start_x y} {
  set curr_x $start_x
  set i 0

  while {$i < [sizeof_collection $pins]} {
    set pin [index_collection $pins $i]

    set layer "C5"

    if { [bsg_pins_check_location $curr_x $y $layer] == 1 } {
      #puts $curr_x
      set_individual_pin_constraints -ports $pin -allowed_layers $layer -location "$curr_x $y"
      incr i
    }

    set curr_x [expr $curr_x + 0.16]
  }
}

proc place_wh_pins_k1_k3 {pins start_y x} {
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


# core boundary
set core_llx [get_attribute [get_core_area] bounding_box.ll_x]
set core_lly [get_attribute [get_core_area] bounding_box.ll_y]
set core_urx [get_attribute [get_core_area] bounding_box.ur_x]
set core_ury [get_attribute [get_core_area] bounding_box.ur_y]


# group pins

set core_ver_link_input_ports [list]
set core_ver_link_output_ports [list]
for {set i 0} {$i < $HB_LINK_WIDTH_P} {incr i} {
  append_to_collection core_ver_link_input_ports [get_ports "core_ver_link_sif_i[$i]"]
  append_to_collection core_ver_link_output_ports [get_ports "core_ver_link_sif_o[$i]"]
}

set core_wh_link_input_ports [list]
set core_wh_link_output_ports [list]
for {set i 0} {$i < $HB_WH_LINK_WIDTH_P} {incr i} {
  set idx [expr $i+($HB_WH_LINK_WIDTH_P*0)]
  append_to_collection core_wh_link_input_ports [get_ports "core_wh_link_sif_i[$idx]"]
  append_to_collection core_wh_link_output_ports [get_ports "core_wh_link_sif_o[$idx]"]
  set idx [expr $i+($HB_WH_LINK_WIDTH_P*1)]
  append_to_collection core_wh_link_input_ports [get_ports "core_wh_link_sif_i[$idx]"]
  append_to_collection core_wh_link_output_ports [get_ports "core_wh_link_sif_o[$idx]"]
}

set io_ver_input_ports [list]
set io_ver_output_ports [list]
append_to_collection io_ver_input_ports [get_ports "io_rev_link_clk_i"]
append_to_collection io_ver_input_ports [get_ports "io_rev_link_data_i"]
append_to_collection io_ver_input_ports [get_ports "io_rev_link_v_i"]
append_to_collection io_ver_input_ports [get_ports "io_rev_link_token_o"]
append_to_collection io_ver_input_ports [get_ports "io_fwd_link_clk_i"]
append_to_collection io_ver_input_ports [get_ports "io_fwd_link_data_i"]
append_to_collection io_ver_input_ports [get_ports "io_fwd_link_v_i"]
append_to_collection io_ver_input_ports [get_ports "io_fwd_link_token_o"]
append_to_collection io_ver_output_ports [get_ports "io_rev_link_clk_o"]
append_to_collection io_ver_output_ports [get_ports "io_rev_link_data_o"]
append_to_collection io_ver_output_ports [get_ports "io_rev_link_v_o"]
append_to_collection io_ver_output_ports [get_ports "io_rev_link_token_i"]
append_to_collection io_ver_output_ports [get_ports "io_fwd_link_clk_o"]
append_to_collection io_ver_output_ports [get_ports "io_fwd_link_data_o"]
append_to_collection io_ver_output_ports [get_ports "io_fwd_link_v_o"]
append_to_collection io_ver_output_ports [get_ports "io_fwd_link_token_i"]


set io_wh_input_ports [list]
set io_wh_output_ports [list]
append_to_collection io_wh_input_ports [get_ports "io_wh_link_clk_i"]
append_to_collection io_wh_input_ports [get_ports "io_wh_link_data_i"]
append_to_collection io_wh_input_ports [get_ports "io_wh_link_v_i"]
append_to_collection io_wh_input_ports [get_ports "io_wh_link_token_o"]
append_to_collection io_wh_output_ports [get_ports "io_wh_link_clk_o"]
append_to_collection io_wh_output_ports [get_ports "io_wh_link_data_o"]
append_to_collection io_wh_output_ports [get_ports "io_wh_link_v_o"]
append_to_collection io_wh_output_ports [get_ports "io_wh_link_token_i"]


# place ver links
if {$::env(SOUTH_NOT_NORTH) == 1} {
  # core (north)
  place_pins_k2_k4 $core_ver_link_input_ports  [expr 0.128*58]  $core_ury
  place_pins_c5    $core_ver_link_output_ports [expr 0.08*66]   $core_ury
  # io (south)
  place_pins_k2_k4 $io_ver_output_ports [expr 0.128*58] $core_lly
  place_pins_c5    $io_ver_input_ports  [expr 0.08*66]  $core_lly
} else {
  # io (north)
  place_pins_k2_k4 $io_ver_input_ports [expr 0.128*58] $core_ury
  place_pins_c5    $io_ver_output_ports  [expr 0.08*66]  $core_ury
  # core (south)
  place_pins_k2_k4 $core_ver_link_output_ports  [expr 0.128*58]  $core_lly
  place_pins_c5    $core_ver_link_input_ports [expr 0.08*66]   $core_lly
}



# place wh links
if {$::env(EAST_NOT_WEST) == 1} {
 # core (west)
 place_wh_pins_k1_k3 $core_wh_link_input_ports  $VCACHE_WEST_INPUT_OFFSET  $core_llx
 place_wh_pins_k1_k3 $core_wh_link_output_ports $VCACHE_WEST_OUTPUT_OFFSET $core_llx
 # io (east)
 place_wh_pins_k1_k3 $io_wh_output_ports  $VCACHE_WEST_INPUT_OFFSET  $core_urx
 place_wh_pins_k1_k3 $io_wh_input_ports   $VCACHE_WEST_OUTPUT_OFFSET $core_urx
} else {
 # core (east)
 place_wh_pins_k1_k3 $core_wh_link_output_ports  $VCACHE_WEST_INPUT_OFFSET  $core_urx
 place_wh_pins_k1_k3 $core_wh_link_input_ports   $VCACHE_WEST_OUTPUT_OFFSET $core_urx
 # io (west)
 place_wh_pins_k1_k3 $io_wh_input_ports    $VCACHE_WEST_INPUT_OFFSET  $core_llx
 place_wh_pins_k1_k3 $io_wh_output_ports   $VCACHE_WEST_OUTPUT_OFFSET $core_llx
}



# core_clk pin
set core_clk_pin [get_ports "core_clk_i"]
if {$::env(EAST_NOT_WEST) == 1} {
  set_individual_pin_constraints -ports $core_clk_pin -allowed_layers "K1" -location "$core_llx 75.264"
} else {
  set_individual_pin_constraints -ports $core_clk_pin -allowed_layers "K1" -location "$core_urx 75.264"
}




set tag_ports [list]
append_to_collection tag_ports [get_ports "tag_clk_i"]
append_to_collection tag_ports [get_ports "tag_data_i"]
append_to_collection tag_ports [get_ports "tag_node_id_offset_i"]

set disable_ports [get_ports "async_*_disable_i*"]

if {$::env(EAST_NOT_WEST) == 1} {
  if {$::env(SOUTH_NOT_NORTH) == 1} {
    # SE
    set north_misc_ports [list]
    append_to_collection north_misc_ports [get_ports "core_reset_i"]
    append_to_collection north_misc_ports [sort_collection [get_ports "core_global_*_i*"] name]
    set south_misc_ports [list]
    append_to_collection south_misc_ports [sort_collection [get_ports "async_*_reset_o"] name]
    append_to_collection south_misc_ports [get_ports "core_reset_o"]
    append_to_collection south_misc_ports [sort_collection [get_ports "core_global_*_o*"] name]
    append_to_collection south_misc_ports $tag_ports
    append_to_collection south_misc_ports $disable_ports
    
    place_pins_k2_k4 $north_misc_ports [expr 0.128*311] $core_ury
    place_pins_k2_k4 $south_misc_ports [expr 0.128*311] $core_lly
  } else {
    # NE
    set north_misc_ports [list]
    append_to_collection north_misc_ports [get_ports "core_reset_i"]
    append_to_collection north_misc_ports [sort_collection [get_ports "core_global_*_i*"] name]
    append_to_collection north_misc_ports $tag_ports
    append_to_collection north_misc_ports $disable_ports
    set south_misc_ports [list]
    append_to_collection south_misc_ports [sort_collection [get_ports "async_*_reset_o"] name]
    append_to_collection south_misc_ports [get_ports "core_reset_o"]
    append_to_collection south_misc_ports [sort_collection [get_ports "core_global_*_o*"] name]
    
    place_pins_k2_k4 $north_misc_ports [expr 0.128*311] $core_ury
    place_pins_k2_k4 $south_misc_ports [expr 0.128*311] $core_lly
  }
} else {
  if {$::env(SOUTH_NOT_NORTH) == 1} {
    # SW
    set north_misc_ports [list]
    append_to_collection north_misc_ports [sort_collection [get_ports "async_*_reset_o"] name]
    append_to_collection north_misc_ports [get_ports "core_reset_i"]
    append_to_collection north_misc_ports [sort_collection [get_ports "core_global_*_i*"] name]
    set south_misc_ports [list]
    append_to_collection south_misc_ports [get_ports "core_reset_o"]
    append_to_collection south_misc_ports [sort_collection [get_ports "core_global_*_o*"] name]
    append_to_collection south_misc_ports $tag_ports
    append_to_collection south_misc_ports $disable_ports
    
    place_pins_k2_k4 $north_misc_ports [expr 0.128*8] $core_ury
    place_pins_k2_k4 $south_misc_ports [expr 0.128*8] $core_lly
  } else {
    # NW
    set north_misc_ports [list]
    append_to_collection north_misc_ports [get_ports "core_reset_i"]
    append_to_collection north_misc_ports [sort_collection [get_ports "core_global_*_i*"] name]
    append_to_collection north_misc_ports $tag_ports
    append_to_collection north_misc_ports $disable_ports
    append_to_collection north_misc_ports [sort_collection [get_ports "async_*_reset_o"] name]
    set south_misc_ports [list]
    append_to_collection south_misc_ports [get_ports "core_reset_o"]
    append_to_collection south_misc_ports [sort_collection [get_ports "core_global_*_o*"] name]
    
    place_pins_k2_k4 $north_misc_ports [expr 0.128*8] $core_ury
    place_pins_k2_k4 $south_misc_ports [expr 0.128*8] $core_lly
  }
}



puts "BSG-info: Completed script [info script]\n"
