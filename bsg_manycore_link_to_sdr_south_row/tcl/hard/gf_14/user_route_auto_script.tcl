set all_nets [list]

set cells [get_cells "sdr_x_*__sdr_n"]
append_to_collection all_nets [get_nets -of [get_pins -of $cells -filter "name=~core_link_sif*"]]
append_to_collection all_nets [get_nets -of [get_pins -of $cells -filter "name=~async*"]]
append_to_collection all_nets [get_nets -of [get_pins -of $cells -filter "name=~io*"]]

route_group -nets $all_nets

set_attribute -objects $all_nets -name physical_status -value locked

