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
for {set i 0} {$i < 4} {incr i} {append_to_collection clk_reset_tag_ports [get_ports "tag_async_reset_tag_lines_i[$i]"]}
for {set i 0} {$i < 4} {incr i} {append_to_collection clk_reset_tag_ports [get_ports "tag_osc_tag_lines_i[$i]"]}
for {set i 0} {$i < 4} {incr i} {append_to_collection clk_reset_tag_ports [get_ports "tag_osc_trigger_tag_lines_i[$i]"]}
for {set i 0} {$i < 4} {incr i} {append_to_collection clk_reset_tag_ports [get_ports "tag_ds_tag_lines_i[$i]"]}
for {set i 0} {$i < 4} {incr i} {append_to_collection clk_reset_tag_ports [get_ports "tag_sel_tag_lines_i[$i]"]}
for {set i 0} {$i < 4} {incr i} {append_to_collection clk_reset_tag_ports [get_ports "tag_io_tag_lines_i[$i]"]}
for {set i 0} {$i < 4} {incr i} {append_to_collection clk_reset_tag_ports [get_ports "tag_core_tag_lines_i[$i]"]}

# clock reset
append_to_collection clk_reset_tag_ports [get_ports "ext_clk_i"]
append_to_collection clk_reset_tag_ports [get_ports "async_output_disable_i"]

place_pins_k2_k4 $clk_reset_tag_ports [expr $core_urx/2+(0.128*75)] $core_ury


set BSG_LINK_DDR_DATA_WIDTH    33
set BSG_LINK_DDR_CHANNEL_WIDTH 16

# manycore links
set core_clock_ports [list]
set core_upstream_ports [list]
set core_downstream_ports [list]
append_to_collection core_clock_ports        [get_ports "core_clk_i"]
append_to_collection core_upstream_ports     [get_ports "core_v_i"]
append_to_collection core_upstream_ports     [get_ports "core_ready_and_o"]
append_to_collection core_downstream_ports   [get_ports "core_v_o"]
append_to_collection core_downstream_ports   [get_ports "core_yumi_i"]
for {set i 0} {$i < $BSG_LINK_DDR_DATA_WIDTH} {incr i} {
  append_to_collection core_upstream_ports   [get_ports "core_data_i[$i]"]
  append_to_collection core_downstream_ports [get_ports "core_data_o[$i]"]
}
place_pins_k1_k3 $core_upstream_ports   [expr $core_lly+(0.128*50)] $core_urx
place_pins_k1_k3 $core_clock_ports      [expr $core_lly+(0.128*125)] $core_urx
place_pins_k1_k3 $core_downstream_ports [expr $core_lly+(0.128*150)] $core_urx


# sdr links
set sdr_in_ports  [list]
set sdr_out_ports [list]

append_to_collection sdr_in_ports [get_ports "io_link_v_i"]
append_to_collection sdr_in_ports [get_ports "io_link_token_o"]
for {set i 0} {$i < [expr $BSG_LINK_DDR_CHANNEL_WIDTH/2]} {incr i} {
  append_to_collection sdr_in_ports [get_ports "io_link_data_i[$i]"]
}
append_to_collection sdr_in_ports [get_ports "io_link_clk_i"]
for {set i [expr $BSG_LINK_DDR_CHANNEL_WIDTH/2]} {$i < $BSG_LINK_DDR_CHANNEL_WIDTH} {incr i} {
  append_to_collection sdr_in_ports [get_ports "io_link_data_i[$i]"]
}

append_to_collection sdr_out_ports [get_ports "io_link_v_o"]
append_to_collection sdr_out_ports [get_ports "io_link_token_i"]
for {set i 0} {$i < [expr $BSG_LINK_DDR_CHANNEL_WIDTH/2]} {incr i} {
  append_to_collection sdr_out_ports [get_ports "io_link_data_o[$i]"]
}
append_to_collection sdr_out_ports [get_ports "io_link_clk_o"]
for {set i [expr $BSG_LINK_DDR_CHANNEL_WIDTH/2]} {$i < $BSG_LINK_DDR_CHANNEL_WIDTH} {incr i} {
  append_to_collection sdr_out_ports [get_ports "io_link_data_o[$i]"]
}

place_pins_k1_k3 $sdr_out_ports [expr $core_lly+(0.128*20)] $core_llx
place_pins_k1_k3 $sdr_in_ports [expr $core_lly+(0.128*80)] $core_llx




puts "BSG-info: Completed script [info script]\n"
