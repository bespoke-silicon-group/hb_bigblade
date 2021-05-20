
set all_nets [list]

set vc_cells [get_cells "vc_y_*__vc_x_*__vc"]
append_to_collection all_nets [get_nets -of [get_pins -of $vc_cells -filter "name=~reset*"]]
append_to_collection all_nets [get_nets -of [get_pins -of $vc_cells -filter "name=~wh_link_sif*"]]
append_to_collection all_nets [get_nets -of [get_pins -of $vc_cells -filter "name=~ver_link_sif*"]]
append_to_collection all_nets [get_nets -of [get_pins -of $vc_cells -filter "name=~global*"]]
append_to_collection all_nets [get_nets -of [get_ports "wh_link_sif*"]]

route_group -nets $all_nets


set_attribute -objects $all_nets -name physical_status -value locked

