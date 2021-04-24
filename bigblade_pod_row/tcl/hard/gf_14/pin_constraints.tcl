puts "BSG-info: Running script [info script]\n"

source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_common_variables.tcl

remove_individual_pin_constraints
remove_block_pin_constraints
set_block_pin_constraints -allowed_layers {C4 C5 K1 K2 K3 K4}

### match ports
set matching_ports [list]
append_to_collection matching_ports [get_ports "global_*_i"]
append_to_collection matching_ports [get_ports "hor_sdr_async_*_reset_i"]
append_to_collection matching_ports [get_ports "ver_sdr_async_*_reset_i"]
append_to_collection matching_ports [get_ports "ver_io_*"]
append_to_collection matching_ports [get_ports "hor_io_*"]
append_to_collection matching_ports [get_ports "io_wh_*"]

bsg_create_macro_matching_ports $matching_ports false

### place unmatch ports

# pod tags
for {set i 0} {$i < $HB_NUM_PODS_X_P} {incr i} {
  set pod_tag_ports [list]
  for {set j 0} {$j < 4} {incr j} {
    set idx [expr (4*$i)+$j]
    append_to_collection pod_tag_ports [get_ports "pod_tags_i[$idx]"]
  }
  set x_offset [expr ($grid_width*4) + ($i*$grid_width*177)]
  bsg_pins_line_constraint $pod_tag_ports {K2} top $x_offset self
}


# clk gen
set unset_ports [list]
append_to_collection unset_ports [get_ports "ext_clk_i"]
append_to_collection unset_ports [get_ports "*_tag_lines_i*"]
append_to_collection unset_ports [get_ports "async_output_disable_i"]

bsg_pins_line_constraint $unset_ports {K2} top [expr ([die_width] / 2.0) - ($tile_x_space / 2.0) - 1] self




puts "BSG-info: Completed script [info script]\n"
