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


set CORE_DATA_WIDTH    34

set core_clock_ports  [get_ports core_clk_i]
set core_input_ports  [list]
set core_output_ports [list]
for {set i 0} {$i < $CORE_DATA_WIDTH} {incr i} {
  append_to_collection core_input_ports  [get_ports "core_data_i[$i]"]
}
for {set i 0} {$i < $CORE_DATA_WIDTH} {incr i} {
  append_to_collection core_output_ports [get_ports "core_data_o[$i]"]
}
place_pins_k2_k4 $core_clock_ports  [expr $core_llx+(0.128*10)] $core_ury
place_pins_k2_k4 $core_input_ports  [expr $core_llx+(0.128*20)] $core_ury
place_pins_k2_k4 $core_output_ports [expr $core_llx+(0.128*20)] $core_lly




puts "BSG-info: Completed script [info script]\n"
