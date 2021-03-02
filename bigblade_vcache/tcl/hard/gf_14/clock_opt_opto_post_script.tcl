puts "BSG-info: Running script [info script]\n"

source $::env(BSG_DESIGNS_TARGET_TCL_HARD_DIR)/hb_common_variables.tcl


set all_input_nets [list]
set all_output_nets [list]

for {set i [expr 2*$HB_WH_LINK_WIDTH_P]} {$i < [expr 2*$HB_WH_RUCHE_FACTOR_P*$HB_WH_LINK_WIDTH_P]} {incr i} {
  append_to_collection all_input_nets [get_nets "wh_link_sif_i[${i}]"]
  append_to_collection all_output_nets [get_nets -of [get_ports "wh_link_sif_o[${i}]"]]
}

route_group -nets $all_input_nets
set_attribute -objects $all_input_nets -name physical_status -value locked
set_attribute -objects $all_output_nets -name physical_status -value locked




puts "BSG-info: Completed script [info script]\n"
