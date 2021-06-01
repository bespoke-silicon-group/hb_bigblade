remove_edit_groups -all -force
derive_pin_access_routing_guides -cells [get_flat_cells -filter "ref_name=~gf14_*"] -layers {M1 M2 M3 C4} -x_width 0.084 -y_width 0.001
route_eco -max_detail_route_iterations 10
