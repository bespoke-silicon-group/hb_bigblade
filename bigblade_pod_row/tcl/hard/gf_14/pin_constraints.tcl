puts "BSG-info: Running script [info script]\n"

source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_common_variables.tcl

remove_individual_pin_constraints
remove_block_pin_constraints
set_block_pin_constraints -allowed_layers {C4 C5 K1 K2 K3 K4}

### match ports
set matching_ports [list]
append_to_collection matching_ports [get_ports "global_*_i"]
append_to_collection matching_ports [get_ports "ver_io_*"]
append_to_collection matching_ports [get_ports "hor_io_*"]
append_to_collection matching_ports [get_ports "io_wh_*"]
append_to_collection matching_ports [get_ports "async_reset_tag_*"]
append_to_collection matching_ports [get_ports "pod_tag_*"]

bsg_create_macro_matching_ports $matching_ports false

### place unmatch ports


# clk gen
set_individual_pin_constraints -ports [get_ports "ext_clk_i"] -allowed_layers "K4" -location "[expr 37555*0.128] [die_ury]"




puts "BSG-info: Completed script [info script]\n"
