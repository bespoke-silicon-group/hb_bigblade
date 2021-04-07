puts "BSG-info: Running script [info script]\n"

source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_common_variables.tcl

remove_individual_pin_constraints
remove_block_pin_constraints
set_block_pin_constraints -allowed_layers {C4 C5 K1 K2 K3 K4}

set unset_ports [bsg_create_macro_matching_ports [remove_from_collection [get_ports] [get_ports "VDD VSS"]]]
bsg_pins_line_constraint $unset_ports {K4} top [expr ([die_width] / 2.0) - ($tile_x_space / 2.0) - 1] self

puts "BSG-info: Completed script [info script]\n"
