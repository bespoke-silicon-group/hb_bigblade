puts "BSG-info: Running script [info script]\n"

source -echo -verbose $::env(BSG_DESIGNS_TARGET_TCL_HARD_DIR)/fp_common.tcl

set block "self"
set pin_spacing 1
set allow_pin_overlap false
set debug_msg 0

set layers  "K1 K3"
set start   [expr $init_gap_y + 30.0]
set pin_idx 0
set rev_pin [expr ($num_tiles_x_p-1)*$width_p]

for {set x 0} {$x < $num_tiles_x_p} {incr x} {
  set side        "left"
  set pins        [get_ports "link_w_i[$rev_pin:[expr $rev_pin+$width_p-1]]"]
  set mirror_pins [get_ports "link_e_o[$rev_pin:[expr $rev_pin+$width_p-1]]"]
  bsg_pins_line_constraint $pins $layers $side $start $block $mirror_pins $pin_spacing $allow_pin_overlap $debug_msg

  set side        "right"
  set pins        [get_ports "link_e_i[$pin_idx:[expr $pin_idx+$width_p-1]]"]
  set mirror_pins [get_ports "link_w_o[$pin_idx:[expr $pin_idx+$width_p-1]]"]
  bsg_pins_line_constraint $pins $layers $side $start $block $mirror_pins $pin_spacing $allow_pin_overlap $debug_msg

  set pin_idx [expr $pin_idx + $width_p]
  set rev_pin [expr $rev_pin - $width_p]
  set start   [expr $start + $tile_h + $tile_gap_y]
}

set layers  "K2 K4"
set start   [expr $init_gap_x + 30.0]
set pin_idx 0
set rev_pin [expr ($num_tiles_y_p-1)*$width_p]

for {set y 0} {$y < $num_tiles_y_p} {incr y} {
  set side        "top"
  set pins        [get_ports "link_n_i[[expr $pin_idx+$width_p-1]:$pin_idx]"]
  set mirror_pins [get_ports "link_s_o[[expr $pin_idx+$width_p-1]:$pin_idx]"]
  bsg_pins_line_constraint $pins $layers $side $start $block $mirror_pins $pin_spacing $allow_pin_overlap $debug_msg

  set side        "bottom"
  set pins        [get_ports "link_s_i[$rev_pin:[expr $rev_pin+$width_p-1]]"]
  set mirror_pins [get_ports "link_n_o[$rev_pin:[expr $rev_pin+$width_p-1]]"]
  bsg_pins_line_constraint $pins $layers $side $start $block $mirror_pins $pin_spacing $allow_pin_overlap $debug_msg

  set pin_idx [expr $pin_idx + $width_p]
  set rev_pin [expr $rev_pin - $width_p]
  set start   [expr $start + $tile_w + $tile_gap_x]
}

puts "BSG-info: Completed script [info script]\n"
