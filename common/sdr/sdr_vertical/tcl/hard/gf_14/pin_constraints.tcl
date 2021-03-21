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


proc place_pins_k1_k3 {pins start_y x} {
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
    }

    set curr_y [expr $curr_y + 0.128]
  }
}


set core_llx [get_attribute [get_core_area] bounding_box.ll_x]
set core_lly [get_attribute [get_core_area] bounding_box.ll_y]
set core_urx [get_attribute [get_core_area] bounding_box.ur_x]
set core_ury [get_attribute [get_core_area] bounding_box.ur_y]



# async reset
set reset_in_ports [list]
append_to_collection reset_in_ports [get_ports "async_uplink_reset_i"]
append_to_collection reset_in_ports [get_ports "async_downlink_reset_i"]
append_to_collection reset_in_ports [get_ports "async_downstream_reset_i"]
append_to_collection reset_in_ports [get_ports "async_token_reset_i"]
set reset_out_ports [list]
append_to_collection reset_out_ports [get_ports "async_uplink_reset_o"]
append_to_collection reset_out_ports [get_ports "async_downlink_reset_o"]
append_to_collection reset_out_ports [get_ports "async_downstream_reset_o"]
append_to_collection reset_out_ports [get_ports "async_token_reset_o"]

place_pins_k1_k3 $reset_in_ports [expr $core_ury/2] $core_llx
place_pins_k1_k3 $reset_out_ports [expr $core_ury/2] $core_urx


# manycore links
set core_link_in_ports [list]
set core_link_out_ports [list]
for {set i 0} {$i < $HB_LINK_WIDTH_P} {incr i} {
  append_to_collection core_link_in_ports  [get_ports "core_link_sif_i[$i]"]
  append_to_collection core_link_out_ports [get_ports "core_link_sif_o[$i]"]
}


# sdr links
set sdr_in_ports [list]
set sdr_out_ports [list]
append_to_collection sdr_in_ports [get_ports "io_rev_link_v_i"]
append_to_collection sdr_in_ports [get_ports "io_rev_link_token_o"]
for {set i 0} {$i < [expr $HB_REV_PACKET_WIDTH/2]} {incr i} {
  append_to_collection sdr_in_ports [get_ports "io_rev_link_data_i[$i]"]
}
append_to_collection sdr_in_ports [get_ports "io_rev_link_clk_i"]
for {set i [expr $HB_REV_PACKET_WIDTH/2]} {$i < $HB_REV_PACKET_WIDTH} {incr i} {
  append_to_collection sdr_in_ports [get_ports "io_rev_link_data_i[$i]"]
}

append_to_collection sdr_in_ports [get_ports "io_fwd_link_v_i"]
append_to_collection sdr_in_ports [get_ports "io_fwd_link_token_o"]
for {set i 0} {$i < [expr $HB_FWD_PACKET_WIDTH/2]} {incr i} {
  append_to_collection sdr_in_ports [get_ports "io_fwd_link_data_i[$i]"]
}
append_to_collection sdr_in_ports [get_ports "io_fwd_link_clk_i"]
for {set i [expr $HB_FWD_PACKET_WIDTH/2]} {$i < $HB_FWD_PACKET_WIDTH} {incr i} {
  append_to_collection sdr_in_ports [get_ports "io_fwd_link_data_i[$i]"]
}

append_to_collection sdr_out_ports [get_ports "io_rev_link_v_o"]
append_to_collection sdr_out_ports [get_ports "io_rev_link_token_i"]
for {set i 0} {$i < [expr $HB_REV_PACKET_WIDTH/2]} {incr i} {
  append_to_collection sdr_out_ports [get_ports "io_rev_link_data_o[$i]"]
}
append_to_collection sdr_out_ports [get_ports "io_rev_link_clk_o"]
for {set i [expr $HB_REV_PACKET_WIDTH/2]} {$i < $HB_REV_PACKET_WIDTH} {incr i} {
  append_to_collection sdr_out_ports [get_ports "io_rev_link_data_o[$i]"]
}

append_to_collection sdr_out_ports [get_ports "io_fwd_link_v_o"]
append_to_collection sdr_out_ports [get_ports "io_fwd_link_token_i"]
for {set i 0} {$i < [expr $HB_FWD_PACKET_WIDTH/2]} {incr i} {
  append_to_collection sdr_out_ports [get_ports "io_fwd_link_data_o[$i]"]
}
append_to_collection sdr_out_ports [get_ports "io_fwd_link_clk_o"]
for {set i [expr $HB_FWD_PACKET_WIDTH/2]} {$i < $HB_FWD_PACKET_WIDTH} {incr i} {
  append_to_collection sdr_out_ports [get_ports "io_fwd_link_data_o[$i]"]
}

# core clock
set clk_ports [get_ports "core_clk_i"]

# cord reset pins
set cord_reset_in_pins [list]
append_to_collection cord_reset_in_pins [get_ports "core_reset_i"]
append_to_collection cord_reset_in_pins [sort_collection [get_ports "core_global_*_i*"] name]
place_pins_k2_k4 $cord_reset_in_pins [expr $core_llx+(0.128*234)] $core_ury

set cord_reset_out_pins [list]
append_to_collection cord_reset_out_pins [get_ports "core_reset_o"]
append_to_collection cord_reset_out_pins [sort_collection [get_ports "core_global_*_o*"] name]
place_pins_k2_k4 $cord_reset_out_pins [expr $core_llx+(0.128*234)] $core_lly


if {$::env(SOUTH_NOT_NORTH) == 1} {
  place_pins_k2_k4 $core_link_in_ports  $NORTH_INPUT_OFFSET $core_ury
  place_pins_k2_k4 $core_link_out_ports $NORTH_OUTPUT_OFFSET $core_ury
  set_individual_pin_constraints -ports $clk_ports -allowed_layers "K4" -location "[expr 0.128*552] $core_ury"

  place_pins_k2_k4 $sdr_out_ports       $NORTH_INPUT_OFFSET $core_lly
  place_pins_k2_k4 $sdr_in_ports        $NORTH_OUTPUT_OFFSET $core_lly
} else {
  place_pins_k2_k4 $core_link_in_ports  $NORTH_OUTPUT_OFFSET $core_lly
  place_pins_k2_k4 $core_link_out_ports $NORTH_INPUT_OFFSET $core_lly
  set_individual_pin_constraints -ports $clk_ports -allowed_layers "K4" -location "[expr 0.128*552] $core_lly"

  place_pins_k2_k4 $sdr_out_ports       $NORTH_OUTPUT_OFFSET $core_ury
  place_pins_k2_k4 $sdr_in_ports        $NORTH_INPUT_OFFSET  $core_ury
}






puts "BSG-info: Completed script [info script]\n"
