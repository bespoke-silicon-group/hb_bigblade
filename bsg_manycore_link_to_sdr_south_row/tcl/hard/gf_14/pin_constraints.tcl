source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_common_variables.tcl

remove_individual_pin_constraints
remove_block_pin_constraints
set_block_pin_constraints -allowed_layers {C4 C5 K1 K2 K3 K4}
bsg_create_macro_matching_ports [get_ports *] true

#set_individual_pin_constraints -ports [get_ports core_clk_i[0]] -allowed_layers K4 -location "[expr 0.128*4584] [die_ury]"
#set_individual_pin_constraints -ports [get_ports core_clk_i[1]] -allowed_layers K4 -location "[expr 0.128*13824] [die_ury]"
set_individual_pin_constraints -ports [get_ports core_clk_i] -allowed_layers K4 -location "[expr 0.128*9225] [die_ury]"









