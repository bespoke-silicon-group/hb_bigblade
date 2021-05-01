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

    set layer "K4"
    #if {$i % 2 == 0} {
    #  set layer "K2"
    #} else {
    #  set layer "K4"
    #}

    if { [bsg_pins_check_location $curr_x $y $layer] == 1 } {
      #puts $curr_x
      set_individual_pin_constraints -ports $pin -allowed_layers $layer -location "$curr_x $y"
      incr i
      set curr_x [expr $curr_x + 40]
    } else {
      set curr_x [expr $curr_x + 0.128]
    }

  }
}


proc place_pins_k1_k3 {pins start_y x} {
  set i 0
  set curr_y $start_y


  while {$i < [sizeof_collection $pins]} {

    set pin [index_collection $pins $i]

    set layer "K3"
    #if {$i % 2 == 0} {
    #  set layer "K1"
    #} else {
    #  set layer "K3"
    #}

    if { [bsg_pins_check_location $x $curr_y $layer] == 1} {
      set_individual_pin_constraints -ports $pin -allowed_layers $layer -location "$x $curr_y"
      incr i
      set curr_y [expr $curr_y + 40]
    } else {
      set curr_y [expr $curr_y + 0.128]
    }

  }
}


set core_llx [get_attribute [get_core_area] bounding_box.ll_x]
set core_lly [get_attribute [get_core_area] bounding_box.ll_y]
set core_urx [get_attribute [get_core_area] bounding_box.ur_x]
set core_ury [get_attribute [get_core_area] bounding_box.ur_y]


set edge_offset          237
set io_link_ch_len       1680


# tag
set tag_ports [list]
append_to_collection tag_ports [get_ports "tag_clk_i"]
append_to_collection tag_ports [get_ports "tag_data_i"]
append_to_collection tag_ports [get_ports "tag_en_i"]
place_pins_k2_k4 $tag_ports [expr $core_llx+1517.5-$edge_offset] $core_ury

# clock reset
append_to_collection clk_reset_ports [get_ports "ext_io_clk_i"]
append_to_collection clk_reset_ports [get_ports "ext_noc_clk_i"]
append_to_collection clk_reset_ports [get_ports "async_output_disable_i"]
place_pins_k2_k4 $clk_reset_ports [expr $core_llx+5150.5-$edge_offset] $core_ury

# links
set IO_LINK_CHANNEL_WIDTH   16
set io_link_ports_0  [list]
set io_link_ports_1  [list]
set io_link_ports_2  [list]
set io_link_ports_3  [list]
set io_link_ports_4  [list]
set io_link_ports_5  [list]
set io_link_ports_6  [list]
set io_link_ports_7  [list]
set io_link_ports_8  [list]
set io_link_ports_9  [list]
set io_link_ports_10 [list]
set io_link_ports_11 [list]
set io_link_ports_12 [list]
set io_link_ports_13 [list]
set io_link_ports_14 [list]
set io_link_ports_15 [list]

for {set j 0} {$j < 16} {incr j} {
  set start_idx [expr $j*$IO_LINK_CHANNEL_WIDTH]
  set end_idx [expr $start_idx+$IO_LINK_CHANNEL_WIDTH]
  append_to_collection "io_link_ports_${j}" [get_ports "io_link_clk_i[$j]"]
  append_to_collection "io_link_ports_${j}" [get_ports "io_link_v_i[$j]"]
  append_to_collection "io_link_ports_${j}" [get_ports "io_link_token_o[$j]"]
  for {set i $start_idx} {$i < $end_idx} {incr i} {append_to_collection "io_link_ports_${j}" [get_ports "io_link_data_i[$i]"]}
  append_to_collection "io_link_ports_${j}" [get_ports "io_link_clk_o[$j]"]
  append_to_collection "io_link_ports_${j}" [get_ports "io_link_v_o[$j]"]
  append_to_collection "io_link_ports_${j}" [get_ports "io_link_token_i[$j]"]
  for {set i $start_idx} {$i < $end_idx} {incr i} {append_to_collection "io_link_ports_${j}" [get_ports "io_link_data_o[$i]"]}
}

# DL0~DL7
place_pins_k2_k4 $io_link_ports_0 [expr $core_llx+1769.5-$edge_offset] $core_ury
place_pins_k1_k3 $io_link_ports_1 [expr $core_lly+7068.0-$edge_offset] $core_llx
place_pins_k1_k3 $io_link_ports_2 [expr $core_lly+5364.0-$edge_offset] $core_llx
place_pins_k1_k3 $io_link_ports_3 [expr $core_lly+3660.0-$edge_offset] $core_llx
place_pins_k1_k3 $io_link_ports_4 [expr $core_lly+1956.0-$edge_offset] $core_llx
place_pins_k1_k3 $io_link_ports_5 [expr $core_lly+252.00-$edge_offset] $core_llx
place_pins_k2_k4 $io_link_ports_6 [expr $core_llx+3308.5-$io_link_ch_len-$edge_offset] $core_lly
place_pins_k2_k4 $io_link_ports_7 [expr $core_llx+5000.5-$io_link_ch_len-$edge_offset] $core_lly

# DR0~DR7
place_pins_k2_k4 $io_link_ports_8  [expr $core_llx+7691.5-$edge_offset] $core_ury
place_pins_k1_k3 $io_link_ports_9  [expr $core_lly+8748.0-$io_link_ch_len-$edge_offset] $core_urx
place_pins_k1_k3 $io_link_ports_10 [expr $core_lly+7044.0-$io_link_ch_len-$edge_offset] $core_urx
place_pins_k1_k3 $io_link_ports_11 [expr $core_lly+5340.0-$io_link_ch_len-$edge_offset] $core_urx
place_pins_k1_k3 $io_link_ports_12 [expr $core_lly+3636.0-$io_link_ch_len-$edge_offset] $core_urx
place_pins_k1_k3 $io_link_ports_13 [expr $core_lly+1932.0-$io_link_ch_len-$edge_offset] $core_urx
place_pins_k2_k4 $io_link_ports_14 [expr $core_llx+9230.5-$io_link_ch_len-$edge_offset] $core_lly
place_pins_k2_k4 $io_link_ports_15 [expr $core_llx+7538.5-$io_link_ch_len-$edge_offset] $core_lly

puts "BSG-info: Completed script [info script]\n"
