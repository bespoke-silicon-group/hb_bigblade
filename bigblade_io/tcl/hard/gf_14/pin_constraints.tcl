remove_individual_pin_constraints
remove_block_pin_constraints

### Just make sure that other layers are not used.

set_block_pin_constraints -allowed_layers { C4 C5 K1 K2 K3 K4 }

# Useful numbers for the master tile
set tile_width  [core_width]
set tile_height [core_height]

set tile_req_pins_o       [get_ports -filter "name=~coh_lce_req_link_o*"]
set tile_req_pins_i       [get_ports -filter "name=~coh_lce_req_link_i*"]
set tile_cmd_pins_o       [get_ports -filter "name=~coh_lce_cmd_link_o*"]
set tile_cmd_pins_i       [get_ports -filter "name=~coh_lce_cmd_link_i*"]
set tile_resp_pins_o      [get_ports -filter "name=~coh_lce_resp_link_o*"]
set tile_resp_pins_i      [get_ports -filter "name=~coh_lce_resp_link_i*"]

set tile_mem_cmd_pins_o   [get_ports -filter "name=~mem_cmd_link_o*"]
set tile_mem_cmd_pins_i   [get_ports -filter "name=~mem_cmd_link_i*"]
set tile_mem_resp_pins_o  [get_ports -filter "name=~mem_resp_link_o*"]
set tile_mem_resp_pins_i  [get_ports -filter "name=~mem_resp_link_i*"]

set tile_req_pin_len       [expr [sizeof_collection $tile_req_pins_o] / 4]
set tile_cmd_pin_len       [expr [sizeof_collection $tile_cmd_pins_o] / 4]
set tile_resp_pin_len      [expr [sizeof_collection $tile_resp_pins_o] / 4]
set tile_mem_cmd_pin_len   [expr [sizeof_collection $tile_mem_cmd_pins_o] / 1]
set tile_mem_resp_pin_len  [expr [sizeof_collection $tile_mem_resp_pins_o] / 1]

# TODO: Refactor make list indexed by NSEW
set tile_req_pins_o_S      [index_collection $tile_req_pins_o       [expr 0*$tile_req_pin_len]        [expr 1*$tile_req_pin_len-1]]
set tile_req_pins_i_S      [index_collection $tile_req_pins_i       [expr 0*$tile_req_pin_len]        [expr 1*$tile_req_pin_len-1]]
set tile_cmd_pins_o_S      [index_collection $tile_cmd_pins_o       [expr 0*$tile_cmd_pin_len]        [expr 1*$tile_cmd_pin_len-1]]
set tile_cmd_pins_i_S      [index_collection $tile_cmd_pins_i       [expr 0*$tile_cmd_pin_len]        [expr 1*$tile_cmd_pin_len-1]]
set tile_resp_pins_o_S     [index_collection $tile_resp_pins_o      [expr 0*$tile_resp_pin_len]       [expr 1*$tile_resp_pin_len-1]]
set tile_resp_pins_i_S     [index_collection $tile_resp_pins_i      [expr 0*$tile_resp_pin_len]       [expr 1*$tile_resp_pin_len-1]]
set tile_mem_cmd_pins_o_S  [index_collection $tile_mem_cmd_pins_o   [expr 0*$tile_mem_cmd_pin_len]    [expr 1*$tile_mem_cmd_pin_len-1]]
set tile_mem_resp_pins_i_S [index_collection $tile_mem_resp_pins_i  [expr 0*$tile_mem_resp_pin_len]   [expr 1*$tile_mem_resp_pin_len-1]]

set tile_req_pins_o_N      [index_collection $tile_req_pins_o       [expr 1*$tile_req_pin_len]        [expr 2*$tile_req_pin_len-1]]
set tile_req_pins_i_N      [index_collection $tile_req_pins_i       [expr 1*$tile_req_pin_len]        [expr 2*$tile_req_pin_len-1]]
set tile_cmd_pins_o_N      [index_collection $tile_cmd_pins_o       [expr 1*$tile_cmd_pin_len]        [expr 2*$tile_cmd_pin_len-1]]
set tile_cmd_pins_i_N      [index_collection $tile_cmd_pins_i       [expr 1*$tile_cmd_pin_len]        [expr 2*$tile_cmd_pin_len-1]]
set tile_resp_pins_o_N     [index_collection $tile_resp_pins_o      [expr 1*$tile_resp_pin_len]       [expr 2*$tile_resp_pin_len-1]]
set tile_resp_pins_i_N     [index_collection $tile_resp_pins_i      [expr 1*$tile_resp_pin_len]       [expr 2*$tile_resp_pin_len-1]]
set tile_mem_cmd_pins_i_N  [index_collection $tile_mem_cmd_pins_i   [expr 0*$tile_mem_cmd_pin_len]    [expr 1*$tile_mem_cmd_pin_len-1]]
set tile_mem_resp_pins_o_N [index_collection $tile_mem_resp_pins_o  [expr 0*$tile_mem_resp_pin_len]   [expr 1*$tile_mem_resp_pin_len-1]]

set tile_req_pins_o_E      [index_collection $tile_req_pins_o       [expr 2*$tile_req_pin_len]        [expr 3*$tile_req_pin_len-1]]
set tile_req_pins_i_E      [index_collection $tile_req_pins_i       [expr 2*$tile_req_pin_len]        [expr 3*$tile_req_pin_len-1]]
set tile_cmd_pins_o_E      [index_collection $tile_cmd_pins_o       [expr 2*$tile_cmd_pin_len]        [expr 3*$tile_cmd_pin_len-1]]
set tile_cmd_pins_i_E      [index_collection $tile_cmd_pins_i       [expr 2*$tile_cmd_pin_len]        [expr 3*$tile_cmd_pin_len-1]]
set tile_resp_pins_o_E     [index_collection $tile_resp_pins_o      [expr 2*$tile_resp_pin_len]       [expr 3*$tile_resp_pin_len-1]]
set tile_resp_pins_i_E     [index_collection $tile_resp_pins_i      [expr 2*$tile_resp_pin_len]       [expr 3*$tile_resp_pin_len-1]]

set tile_req_pins_o_W      [index_collection $tile_req_pins_o       [expr 3*$tile_req_pin_len]        [expr 4*$tile_req_pin_len-1]]
set tile_req_pins_i_W      [index_collection $tile_req_pins_i       [expr 3*$tile_req_pin_len]        [expr 4*$tile_req_pin_len-1]]
set tile_cmd_pins_o_W      [index_collection $tile_cmd_pins_o       [expr 3*$tile_cmd_pin_len]        [expr 4*$tile_cmd_pin_len-1]]
set tile_cmd_pins_i_W      [index_collection $tile_cmd_pins_i       [expr 3*$tile_cmd_pin_len]        [expr 4*$tile_cmd_pin_len-1]]
set tile_resp_pins_o_W     [index_collection $tile_resp_pins_o      [expr 3*$tile_resp_pin_len]       [expr 4*$tile_resp_pin_len-1]]
set tile_resp_pins_i_W     [index_collection $tile_resp_pins_i      [expr 3*$tile_resp_pin_len]       [expr 4*$tile_resp_pin_len-1]]


# 0.04 = tile_height to track spacing
# 0.08*N = N tracks of space
# East/West pins - K1 K3
set start_y [expr 0.00 + 0.256*850]
set last_loc [bsg_pins_line_constraint $tile_req_pins_i_E      "K1 K3" right $start_y               self $tile_req_pins_o_W      2 0]
set last_loc [bsg_pins_line_constraint $tile_resp_pins_i_E     "K1 K3" right [expr $last_loc+0.256] self $tile_resp_pins_o_W     2 0]
set last_loc [bsg_pins_line_constraint $tile_cmd_pins_i_E      "K1 K3" right [expr $last_loc+0.256] self $tile_cmd_pins_o_W      2 0]
set last_loc [bsg_pins_line_constraint $tile_req_pins_o_E      "K1 K3" right [expr $last_loc+0.256] self $tile_req_pins_i_W      2 0]
set last_loc [bsg_pins_line_constraint $tile_resp_pins_o_E     "K1 K3" right [expr $last_loc+0.256] self $tile_resp_pins_i_W     2 0]
set last_loc [bsg_pins_line_constraint $tile_cmd_pins_o_E      "K1 K3" right [expr $last_loc+0.256] self $tile_cmd_pins_i_W      2 0]

# North/South pins - C5, K2
set start_x  [expr 0.00 + 0.256*850]
set last_loc [bsg_pins_line_constraint $tile_req_pins_i_N      "K2 K4" top   $start_x               self $tile_req_pins_o_S      2 0]
set last_loc [bsg_pins_line_constraint $tile_resp_pins_i_N     "K2 K4" top   [expr $last_loc+0.256] self $tile_resp_pins_o_S     2 0]
set last_loc [bsg_pins_line_constraint $tile_cmd_pins_i_N      "K2 K4" top   [expr $last_loc+0.256] self $tile_cmd_pins_o_S      2 0]
set last_loc [bsg_pins_line_constraint $tile_req_pins_o_N      "K2 K4" top   [expr $last_loc+0.256] self $tile_req_pins_i_S      2 0]
set last_loc [bsg_pins_line_constraint $tile_resp_pins_o_N     "K2 K4" top   [expr $last_loc+0.256] self $tile_resp_pins_i_S     2 0]
set last_loc [bsg_pins_line_constraint $tile_cmd_pins_o_N      "K2 K4" top   [expr $last_loc+0.256] self $tile_cmd_pins_i_S      2 0]

set start_x [expr 0.00 + 0.08*3450]
set last_loc [bsg_pins_line_constraint $tile_mem_cmd_pins_i_N  "C5" top   $start_x              self $tile_mem_cmd_pins_o_S  1 0]
set last_loc [bsg_pins_line_constraint $tile_mem_resp_pins_o_N "C5" top   [expr $last_loc+0.08] self $tile_mem_resp_pins_i_S 1 0]

################################################################################
###
### MISC Pins. Slow signals in the center on the top, K4
###

set                  misc_pins [get_ports -filter "name=~*clk_i"]
append_to_collection misc_pins [get_ports -filter "name=~*reset_i"]
append_to_collection misc_pins [get_ports -filter "name=~my*"]
append_to_collection misc_pins [get_ports -filter "name=~host*"]

#set start_x [expr $tile_width - 0.08*400]
set_individual_pin_constraints -ports $misc_pins -allowed_layers "C5" -side 2

