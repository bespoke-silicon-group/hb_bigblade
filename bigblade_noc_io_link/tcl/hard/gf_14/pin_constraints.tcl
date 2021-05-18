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


# tag
set clk_reset_tag_ports [list]
append_to_collection clk_reset_tag_ports [get_ports "tag_clk_i"]
append_to_collection clk_reset_tag_ports [get_ports "tag_data_i"]
for {set i 0} {$i < 10} {incr i} {append_to_collection clk_reset_tag_ports [get_ports "tag_node_id_offset_i[$i]"]}
# clock reset
append_to_collection clk_reset_tag_ports [get_ports "ext_io_clk_i"]
append_to_collection clk_reset_tag_ports [get_ports "ext_noc_clk_i"]
append_to_collection clk_reset_tag_ports [get_ports "async_output_disable_i"]

place_pins_k2_k4 $clk_reset_tag_ports [expr $core_llx+(0.128*50)] $core_lly


# place mc links
set mc_input_ports [list]
set mc_output_ports [list]
                                                    append_to_collection mc_input_ports  [get_ports "mc_rev_link_clk_i"]
for {set i 0} {$i < $HB_REV_PACKET_WIDTH} {incr i} {append_to_collection mc_input_ports  [get_ports "mc_rev_link_data_i[$i]"]}
                                                    append_to_collection mc_input_ports  [get_ports "mc_rev_link_v_i"]
                                                    append_to_collection mc_input_ports  [get_ports "mc_rev_link_token_o"]
                                                    append_to_collection mc_output_ports [get_ports "mc_fwd_link_clk_o"]
for {set i 0} {$i < $HB_FWD_PACKET_WIDTH} {incr i} {append_to_collection mc_output_ports [get_ports "mc_fwd_link_data_o[$i]"]}
                                                    append_to_collection mc_output_ports [get_ports "mc_fwd_link_v_o"]
                                                    append_to_collection mc_output_ports [get_ports "mc_fwd_link_token_i"]

# io (west)
place_pins_k2_k4 $mc_input_ports   [expr 200*0.128] $core_lly
place_pins_k2_k4 $mc_output_ports  [expr 400*0.128] $core_lly


set mc_input_ports [list]
set mc_output_ports [list]
                                                    append_to_collection mc_input_ports  [get_ports "mc_fwd_link_clk_i"]
for {set i 0} {$i < $HB_FWD_PACKET_WIDTH} {incr i} {append_to_collection mc_input_ports  [get_ports "mc_fwd_link_data_i[$i]"]}
                                                    append_to_collection mc_input_ports  [get_ports "mc_fwd_link_v_i"]
                                                    append_to_collection mc_input_ports  [get_ports "mc_fwd_link_token_o"]
                                                    append_to_collection mc_output_ports [get_ports "mc_rev_link_clk_o"]
for {set i 0} {$i < $HB_REV_PACKET_WIDTH} {incr i} {append_to_collection mc_output_ports [get_ports "mc_rev_link_data_o[$i]"]}
                                                    append_to_collection mc_output_ports [get_ports "mc_rev_link_v_o"]
                                                    append_to_collection mc_output_ports [get_ports "mc_rev_link_token_i"]

# io (east)
place_pins_k2_k4 $mc_input_ports   [expr 1000*0.128] $core_lly
place_pins_k2_k4 $mc_output_ports  [expr 1200*0.128] $core_lly


set matching_ports [list]
append_to_collection matching_ports [get_ports "io_link_*"]
bsg_create_macro_matching_ports $matching_ports false



puts "BSG-info: Completed script [info script]\n"
