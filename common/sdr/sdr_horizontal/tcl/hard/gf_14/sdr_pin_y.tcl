# print SDR pins y-coordinates into csv

source $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_common_variables.tcl



set sdr_pins [list]
append_to_collection sdr_pins [get_ports "async_*_link_*_disable_i"]

append_to_collection sdr_pins [get_ports "io_fwd_link_clk_o"]
append_to_collection sdr_pins [get_ports "io_fwd_link_data_o*"]
append_to_collection sdr_pins [get_ports "io_fwd_link_v_o"]
append_to_collection sdr_pins [get_ports "io_fwd_link_token_i"]

append_to_collection sdr_pins [get_ports "io_fwd_link_clk_i"]
append_to_collection sdr_pins [get_ports "io_fwd_link_data_i*"]
append_to_collection sdr_pins [get_ports "io_fwd_link_v_i"]
append_to_collection sdr_pins [get_ports "io_fwd_link_token_o"]

append_to_collection sdr_pins [get_ports "io_rev_link_clk_o"]
append_to_collection sdr_pins [get_ports "io_rev_link_data_o*"]
append_to_collection sdr_pins [get_ports "io_rev_link_v_o"]
append_to_collection sdr_pins [get_ports "io_rev_link_token_i"]

append_to_collection sdr_pins [get_ports "io_rev_link_clk_i"]
append_to_collection sdr_pins [get_ports "io_rev_link_data_i*"]
append_to_collection sdr_pins [get_ports "io_rev_link_v_i"]
append_to_collection sdr_pins [get_ports "io_rev_link_token_o"]


proc get_pin_y {pin} {
  set lly [get_attribute $pin bounding_box.ll_y]
  set ury [get_attribute $pin bounding_box.ur_y]
  return [expr ($lly+$ury)/2]
}

foreach_in_collection pin $sdr_pins {
  set y [get_pin_y $pin]
  set name [get_attribute $pin name]
  set layer [get_attribute $pin layer.name]
  puts "$name,$y,$layer"
}
