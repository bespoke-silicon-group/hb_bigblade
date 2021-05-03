#source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_common_variables.tcl

remove_individual_pin_constraints
remove_block_pin_constraints
set_block_pin_constraints -allowed_layers {C4 C5 K1 K2 K3 K4}
#bsg_create_macro_matching_ports [get_ports *] true

proc round_y {y} {
  return [round_down_to_nearest $y 0.128]
}

proc round_x {x} {
  return [round_down_to_nearest $x 0.128]
}


set_individual_pin_constraints -ports [get_ports clk_i] \
                              -allowed_layers K2 -location \
                              "[round_x 1186] [die_ury]"


set_individual_pin_constraints -ports [get_ports data_i[0]] \
                              -allowed_layers K1 -location \
                              "0 [round_y 130]"

set_individual_pin_constraints -ports [get_ports data_i[1]] \
                              -allowed_layers K1 -location \
                              "0 [round_y 260]"

set_individual_pin_constraints -ports [get_ports data_o[0]] \
                              -allowed_layers K1 -location \
                              "[die_urx] [round_y 130]"

set_individual_pin_constraints -ports [get_ports data_o[1]] \
                              -allowed_layers K1 -location \
                              "[die_urx] [round_y 260]"







