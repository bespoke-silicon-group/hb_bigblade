source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_common_variables.tcl



proc get_pin_y {pin} {
  set lly [get_attribute $pin bounding_box.ll_y]
  set ury [get_attribute $pin bounding_box.ur_y]
  return [expr ($lly+$ury)/2]
}


# print out pin y locations for local and stage1 ruche link.

# west output
for {set j 0} {$j < $HB_LINK_WIDTH_P} {incr j} {
  set local_pin [get_ports "link_o[$j]"]
  set local_pin_y [get_pin_y $local_pin]
  set local_pin_name [get_attribute $local_pin full_name]
  set local_pin_layer [get_attribute $local_pin layer.name]
  puts $local_pin_name,$local_pin_y,$local_pin_layer
}

for {set j 0} {$j < $HB_RUCHE_LINK_WIDTH_P} {incr j} {
  # stage 0
  set ruche_idx [expr $j+($HB_RUCHE_LINK_WIDTH_P*0)]
  set ruche_pin [get_ports "ruche_link_o[${ruche_idx}]"]
  set ruche_pin_y [get_pin_y $ruche_pin]
  set ruche_pin_name [get_attribute $ruche_pin full_name]
  set ruche_pin_layer [get_attribute $ruche_pin layer.name]
  puts $ruche_pin_name,$ruche_pin_y,$ruche_pin_layer
  # stage one
  set ruche_idx [expr $j+($HB_RUCHE_LINK_WIDTH_P*2)]
  set ruche_pin [get_ports "ruche_link_o[${ruche_idx}]"]
  set ruche_pin_y [get_pin_y $ruche_pin]
  set ruche_pin_name [get_attribute $ruche_pin full_name]
  set ruche_pin_layer [get_attribute $ruche_pin layer.name]
  puts $ruche_pin_name,$ruche_pin_y,$ruche_pin_layer
}


# west input
for {set j 0} {$j < $HB_LINK_WIDTH_P} {incr j} {
  set local_pin [get_ports "link_i[$j]"]
  set local_pin_y [get_pin_y $local_pin]
  set local_pin_name [get_attribute $local_pin full_name]
  set local_pin_layer [get_attribute $local_pin layer.name]
  puts $local_pin_name,$local_pin_y,$local_pin_layer
}

for {set j 0} {$j < $HB_RUCHE_LINK_WIDTH_P} {incr j} {
  # stage 0
  set ruche_idx [expr $j+($HB_RUCHE_LINK_WIDTH_P*0)]
  set ruche_pin [get_ports "ruche_link_i[${ruche_idx}]"]
  set ruche_pin_y [get_pin_y $ruche_pin]
  set ruche_pin_name [get_attribute $ruche_pin full_name]
  set ruche_pin_layer [get_attribute $ruche_pin layer.name]
  puts $ruche_pin_name,$ruche_pin_y,$ruche_pin_layer
  # stage one
  set ruche_idx [expr $j+($HB_RUCHE_LINK_WIDTH_P*2)]
  set ruche_pin [get_ports "ruche_link_i[${ruche_idx}]"]
  set ruche_pin_y [get_pin_y $ruche_pin]
  set ruche_pin_name [get_attribute $ruche_pin full_name]
  set ruche_pin_layer [get_attribute $ruche_pin layer.name]
  puts $ruche_pin_name,$ruche_pin_y,$ruche_pin_layer
}
