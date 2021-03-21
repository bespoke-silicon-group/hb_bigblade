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


set core_llx [get_attribute [get_core_area] bounding_box.ll_x]
set core_lly [get_attribute [get_core_area] bounding_box.ll_y]
set core_urx [get_attribute [get_core_area] bounding_box.ur_x]
set core_ury [get_attribute [get_core_area] bounding_box.ur_y]

# ver link
set north_input_pins [list]
set south_input_pins [list]
set north_output_pins [list]
set south_output_pins [list]
for {set i 0} {$i < $HB_LINK_WIDTH_P} {incr i} {
  set idx [expr $i + ($HB_LINK_WIDTH_P*0)]
  append_to_collection north_input_pins [get_ports "core_ver_link_sif_i[$idx]"]
  set idx [expr $i + ($HB_LINK_WIDTH_P*1)]
  append_to_collection south_output_pins [get_ports "core_ver_link_sif_o[$idx]"]
  set idx [expr $i + ($HB_LINK_WIDTH_P*0)]
  append_to_collection north_output_pins [get_ports "core_ver_link_sif_o[$idx]"]
  set idx [expr $i + ($HB_LINK_WIDTH_P*1)]
  append_to_collection south_input_pins [get_ports "core_ver_link_sif_i[$idx]"]
}

place_pins_k2_k4 $north_input_pins  [expr 0.128*58] $core_ury 
place_pins_k2_k4 $south_output_pins [expr 0.128*58] $core_lly

place_pins_c5 $north_output_pins  [expr 0.08*66] $core_ury 
place_pins_c5 $south_input_pins   [expr 0.08*66] $core_lly




# hor link
if {$::env(EAST_NOT_WEST) == 1} {
  source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/tcl/hard/gf_14/hor_pin_constraints_east.tcl
} else {
  source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/tcl/hard/gf_14/hor_pin_constraints_west.tcl
}

# misc pins
set north_misc_pins [list]
append_to_collection north_misc_pins [sort_collection [get_ports async_*_reset_i*] name]
append_to_collection north_misc_pins [get_ports core_reset_i]
append_to_collection north_misc_pins [sort_collection [get_ports core_global_*_i*] name]
append_to_collection north_misc_pins [get_ports core_clk_i]
place_pins_k2_k4 $north_misc_pins [expr $core_urx-0.128*56] $core_ury

set south_misc_pins [list]
append_to_collection south_misc_pins [sort_collection [get_ports async_*_reset_o*] name]
append_to_collection south_misc_pins [get_ports core_reset_o]
append_to_collection south_misc_pins [sort_collection [get_ports core_global_*_o*] name]
place_pins_k2_k4 $south_misc_pins [expr $core_urx-0.128*56] $core_lly




puts "BSG-info: Completed script [info script]\n"
