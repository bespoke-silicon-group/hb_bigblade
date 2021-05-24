puts "BSG-info: Running script [info script]\n"

remove_individual_pin_constraints
remove_block_pin_constraints

set_block_pin_constraints -self -allowed_layers { C4 } -sides 1

proc bsg_create_terminal { name side y } {

  # snap to C4 track
  set y [expr [round_to_nearest [expr $y - [core_lly]] 0.08] + [core_lly]]

  # terminal bbox for a C4 pin on the left of the block
  if {$side == "left"} {
    set term_llx [die_llx]
    set term_lly [expr $y - 0.02]
    set term_urx [expr [die_llx] + 0.04]
    set term_ury [expr $y + 0.02]

  # terminal bbox for a C4 pin on the right of the block
  } elseif {$side == "right"} {
    set term_llx [expr [die_urx] - 0.04]
    set term_lly [expr $y - 0.02]
    set term_urx [die_urx]
    set term_ury [expr $y + 0.02]
  }

  # remove any existing terminals for this port
  if {[sizeof_collection [get_terminals -quiet -of [get_port $name]]] > 0} {
    remove_objects [get_terminals -of [get_port $name]]
  }

  # create the terminal on C4 and fix it so place_pins doesn't move it.
  set_fixed_object [create_shape -port [get_port $name] -layer C4 -shape_type rect -boundary "{$term_llx $term_lly} {$term_urx $term_ury}"]

}

bsg_create_terminal  "tag_clk_i"                "left"   6.16
bsg_create_terminal  "tag_data_i"               "left"   6.00

bsg_create_terminal  "tag_node_id_offset_i[9]"  "left"   5.84
bsg_create_terminal  "tag_node_id_offset_i[8]"  "left"   5.68
bsg_create_terminal  "tag_node_id_offset_i[7]"  "left"   5.52
bsg_create_terminal  "tag_node_id_offset_i[6]"  "left"   5.36
bsg_create_terminal  "tag_node_id_offset_i[5]"  "left"   5.20
bsg_create_terminal  "tag_node_id_offset_i[4]"  "left"   5.04
bsg_create_terminal  "tag_node_id_offset_i[3]"  "left"   4.88
bsg_create_terminal  "tag_node_id_offset_i[2]"  "left"   4.72
bsg_create_terminal  "tag_node_id_offset_i[1]"  "left"   4.56
bsg_create_terminal  "tag_node_id_offset_i[0]"  "left"   4.40

bsg_create_terminal  "clk_monitor_o"            "right"  9.28
bsg_create_terminal  "ext_clk_i"                "right"  2.08
bsg_create_terminal  "async_output_disable_i"   "right"  2.88
bsg_create_terminal  "clk_o"                    "right"  1.28

puts "BSG-info: Completed script [info script]\n"

