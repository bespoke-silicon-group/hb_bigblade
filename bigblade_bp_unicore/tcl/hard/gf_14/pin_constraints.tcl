remove_individual_pin_constraints
remove_block_pin_constraints

set tile_width [core_width]
set tile_height [core_height]

### Just make sure that other layers are not used.
set_block_pin_constraints -allowed_layers { C4 C5 K1 K2 K3 K4 }

set k_pitch 0.128
set c_pitch 0.160

set ruche_pins_i [get_ports -filter "name=~mc_ruche_links_i*"]
set ruche_pins_o [get_ports -filter "name=~mc_ruche_links_o*"]

set link_pins_i [get_ports -filter "name=~mc_links_i*"]
set link_pins_o [get_ports -filter "name=~mc_links_o*"]

set ruche_pin_len [expr [sizeof_collection $ruche_pins_i] / 1]
set link_pin_len  [expr [sizeof_collection $link_pins_i ] / 3]

set link_pin_i_E [index_collection $link_pins_i [expr 2*$link_pin_len]        [expr 3*$link_pin_len-1]]
set link_pin_o_E [index_collection $link_pins_o [expr 2*$link_pin_len]        [expr 3*$link_pin_len-1]]
set link_pin_i_N [index_collection $link_pins_i [expr 1*$link_pin_len]        [expr 2*$link_pin_len-1]]
set link_pin_o_N [index_collection $link_pins_o [expr 1*$link_pin_len]        [expr 2*$link_pin_len-1]]
set link_pin_i_S [index_collection $link_pins_i [expr 0*$link_pin_len]        [expr 1*$link_pin_len-1]]
set link_pin_o_S [index_collection $link_pins_o [expr 0*$link_pin_len]        [expr 1*$link_pin_len-1]]

set link_pin_E $ruche_pins_i
append_to_collection link_pin_E $ruche_pins_o
append_to_collection link_pin_E $link_pin_i_E
append_to_collection link_pin_E $link_pin_o_E

set link_pin_N $link_pin_i_N
append_to_collection link_pin_N $link_pin_o_N
set link_pin_S $link_pin_o_S
append_to_collection link_pin_S $link_pin_i_S

set link_pin_E_len [sizeof_collection $link_pin_E]
set start_y [expr ($tile_height / 2) - ($k_pitch*$link_pin_E_len/4)]
set last_loc [bsg_pins_line_constraint $link_pin_E  "K1 K3" right $start_y "self" {} 1 0]

set link_pin_N_len [sizeof_collection $link_pin_N]
set start_x [expr ($tile_width / 2) - ($k_pitch*$link_pin_N_len/2)]
set last_loc [bsg_pins_line_constraint $link_pin_N "K2 K4" top $start_x "self" $link_pin_S 1 0]

set                  misc_pins [get_ports  -filter "name=~*clk_i"]
append_to_collection misc_pins [get_ports  -filter "name=~*reset_i"]
append_to_collection misc_pins [get_ports  -filter "name=~my_*"]

set misc_pins_len [expr [sizeof_collection $misc_pins]]
set start_x [expr ($tile_width / 2)  - (2*$c_pitch*$misc_pins_len/2)]
set last_loc [bsg_pins_line_constraint $misc_pins "C5" top $start_x "self" {} 2 0]



