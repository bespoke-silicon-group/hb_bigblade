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

bsg_create_terminal  "tag_en_i"                       "left"   7.241
bsg_create_terminal  "tag_clk_i"                      "left"   6.841
bsg_create_terminal  "osc_tag_op_param_i[1]"          "left"   4.921
bsg_create_terminal  "osc_tag_op_param_i[0]"          "left"   4.761
bsg_create_terminal  "ds_tag_op_param_i[1]"           "left"   4.601
bsg_create_terminal  "ds_tag_op_param_i[0]"           "left"   4.441
bsg_create_terminal  "osc_trigger_tag_op_param_i[1]"  "left"   4.281
bsg_create_terminal  "osc_trigger_tag_op_param_i[0]"  "left"   4.121
bsg_create_terminal  "async_reset_tag_op_param_i[1]"  "left"   3.961
bsg_create_terminal  "async_reset_tag_op_param_i[0]"  "left"   3.801
bsg_create_terminal  "sel_tag_op_param_i[0]"          "left"   2.361
bsg_create_terminal  "sel_tag_op_param_i[1]"          "left"   2.201
bsg_create_terminal  "async_output_disable_i"         "left"   1.721
bsg_create_terminal  "ext_clk_i"                      "left"   1.241
bsg_create_terminal  "clk_o"                          "right"  1.321

puts "BSG-info: Completed script [info script]\n"
