source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_common_variables.tcl

remove_individual_pin_constraints
remove_block_pin_constraints
set_block_pin_constraints -allowed_layers {C4 C5 K1 K2 K3 K4}
bsg_create_macro_matching_ports [get_ports *] true

#set_individual_pin_constraints -ports [get_ports core_clk_i[0]] -allowed_layers K4 -location "[expr 0.128*4584] [die_ury]"
#set_individual_pin_constraints -ports [get_ports core_clk_i[1]] -allowed_layers K4 -location "[expr 0.128*13824] [die_ury]"
set_individual_pin_constraints -ports [get_ports core_clk_i] -allowed_layers K4 -location "[expr 0.128*9225] [die_lly]"



# BTC PINs
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
      set_individual_pin_constraints -ports $pin -allowed_layers $layer -location "$curr_x $y"
      incr i
    }

    set curr_x [expr $curr_x + 0.128]
  }
}


place_pins_k2_k4 [get_ports "pod_tags*"] [expr 0.128*18468]  [die_ury]




