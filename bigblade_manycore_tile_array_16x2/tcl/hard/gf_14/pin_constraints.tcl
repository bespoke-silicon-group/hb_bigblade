puts "BSG-info: Running script [info script]\n"

source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_common_variables.tcl

remove_individual_pin_constraints
remove_block_pin_constraints

set_block_pin_constraints -allowed_layers {C4 C5 K1 K2 K3 K4}
bsg_create_macro_matching_ports [get_ports] true
#set_individual_pin_constraints -ports [get_ports clk_i] -allowed_layers K4 -location "[expr ([die_width] / 2.0) - ($tile_x_space / 2.0) + 1.750] [die_ury]"
set_individual_pin_constraints -ports [get_ports clk_i[0]] -allowed_layers K4 -location "[expr 0.128*4584] [die_ury]"
set_individual_pin_constraints -ports [get_ports clk_i[1]] -allowed_layers K4 -location "[expr 0.128*13824] [die_ury]"

puts "BSG-info: Completed script [info script]\n"
