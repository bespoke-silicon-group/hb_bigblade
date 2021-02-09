
#source -echo -verbose $constraints_dir/hb_design_constants.tcl
set ruche_input_ports         [list]
set ruche_output_ports        [list]
set local_input_ports         [list]
set local_output_ports        [list]
for {set i 0} {$i < [expr 4*$HB_LINK_WIDTH_P]} {incr i} {
  append_to_collection local_input_ports [get_ports "link_i[$i]"]
  append_to_collection local_output_ports [get_ports "link_o[$i]"]
}
for {set i 0} {$i < [expr 6*$HB_RUCHE_LINK_WIDTH_P]} {incr i} {
  append_to_collection ruche_input_ports [get_ports "ruche_link_i[$i]"]
  append_to_collection ruche_output_ports [get_ports "ruche_link_o[$i]"]
}
