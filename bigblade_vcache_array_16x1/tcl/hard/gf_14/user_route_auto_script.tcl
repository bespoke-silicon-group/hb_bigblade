
set vc_cells [get_cells "vc_y_*__vc_x_*__vc"]

# pin access guide
derive_pin_access_routing_guides -cells $vc_cells -layers {K1 K3} -x_width [expr 0.084*4] -y_width 0.001


# route group
set all_nets [list]

append_to_collection all_nets [get_nets -of [get_pins -of $vc_cells -filter "name=~reset*"]]
append_to_collection all_nets [get_nets -of [get_pins -of $vc_cells -filter "name=~wh_link_sif*"]]
append_to_collection all_nets [get_nets -of [get_pins -of $vc_cells -filter "name=~ver_link_sif*"]]
append_to_collection all_nets [get_nets -of [get_pins -of $vc_cells -filter "name=~global*"]]
append_to_collection all_nets [get_nets -of [get_ports "wh_link_sif*"]]

route_group -nets $all_nets


set_attribute -objects $all_nets -name physical_status -value locked

