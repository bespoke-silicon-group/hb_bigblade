
set tile_cells [get_cells "y_*__x_*__tile" ]


# pin access guide
derive_pin_access_routing_guides -cells $tile_cells -layers {K1 K3} -x_width [expr 0.084*4] -y_width 0.001





#  route group
set all_nets [list]

append_to_collection all_nets [get_nets -of [get_pins -of $tile_cells -filter "name=~reset*"]]
append_to_collection all_nets [get_nets -of [get_pins -of $tile_cells -filter "name=~link_*"]]
append_to_collection all_nets [get_nets -of [get_pins -of $tile_cells -filter "name=~ruche_link*"]]
append_to_collection all_nets [get_nets -of [get_pins -of $tile_cells -filter "name=~global*"]]
append_to_collection all_nets [get_nets -of [get_ports hor_link_sif_*]]
append_to_collection all_nets [get_nets -of [get_ports ruche_link_*]]


route_group -nets $all_nets


set_attribute -objects $all_nets -name physical_status -value locked

