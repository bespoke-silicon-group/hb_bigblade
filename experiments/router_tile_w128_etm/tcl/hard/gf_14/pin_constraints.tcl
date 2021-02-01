puts "BSG-info: Running script [info script]\n"

source -echo -verbose $::env(BSG_DESIGNS_TARGET_TCL_HARD_DIR)/fp_common.tcl

################################################################################
# Bsg Router Tile Pin Constraints
#

set block "self"
set pin_spacing 1
set allow_pin_overlap false
set debug_msg 0

set layers      "K1 K3"
set side        "left"
set start       30.0
set pins        [get_ports "link_w_i[0:[expr $width_p-1]]"]
set mirror_pins [get_ports "link_e_o[0:[expr $width_p-1]]"]
bsg_pins_line_constraint $pins $layers $side $start $block $mirror_pins $pin_spacing $allow_pin_overlap $debug_msg

set layers      "K1 K3"
set side        "right"
set start       30.0
set pins        [get_ports "link_e_i[0:[expr $width_p-1]]"]
set mirror_pins [get_ports "link_w_o[0:[expr $width_p-1]]"]
bsg_pins_line_constraint $pins $layers $side $start $block $mirror_pins $pin_spacing $allow_pin_overlap $debug_msg

set layers      "K2 K4"
set side        "top"
set start       30.0
set pins        [get_ports "link_n_i[0:[expr $width_p-1]]"]
set mirror_pins [get_ports "link_s_o[0:[expr $width_p-1]]"]
bsg_pins_line_constraint $pins $layers $side $start $block $mirror_pins $pin_spacing $allow_pin_overlap $debug_msg

set layers      "K2 K4"
set side        "bottom"
set start       30.0
set pins        [get_ports "link_s_i[0:[expr $width_p-1]]"]
set mirror_pins [get_ports "link_n_o[0:[expr $width_p-1]]"]
bsg_pins_line_constraint $pins $layers $side $start $block $mirror_pins $pin_spacing $allow_pin_overlap $debug_msg

set layers      "K2 K4"
set side        "top"
set start       70.0
set pins        [get_ports "clk_i reset_i my_x_i* my_y_i*"]
set mirror_pins {}
bsg_pins_line_constraint $pins $layers $side $start $block $mirror_pins $pin_spacing $allow_pin_overlap $debug_msg

puts "BSG-info: Completed script [info script]\n"
