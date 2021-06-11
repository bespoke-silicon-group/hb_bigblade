
derive_pin_access_routing_guides -cells [get_cells "block"] -layers {C4 C5 K1 K2 K3 K4} -x_width [expr 0.084*4] -y_width [expr 0.084*4]

route_auto
