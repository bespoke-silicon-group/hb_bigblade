puts "BSG-info running [info script]"

derive_pin_access_routing_guides -cells [get_cells "mem_link_*__link"] -layers {K1 K3} -x_width [expr 0.084*4] -y_width 0.001

derive_pin_access_routing_guides -cells [get_cells "io_link"] -layers {K1 K3} -x_width [expr 0.084*4] -y_width 0.001
derive_pin_access_routing_guides -cells [get_cells "io_link"] -layers {K2 K4} -x_width 0.001 -y_width [expr 0.084*4]

#derive_pin_access_routing_guides -cells [get_cells "core_complex_core_*__podrow"] -layers {K1 K3} -x_width [expr 0.084*4] -y_width 0.001
#derive_pin_access_routing_guides -cells [get_cells "core_complex_core_*__podrow"] -layers {K2 K4} -x_width 0.001 -y_width [expr 0.084*4]

set TCL_USER_ROUTE_AUTO_SCRIPT "$::env(BSG_DESIGNS_TARGET_TCL_HARD_DIR)/user_route_auto_script.tcl"
set REDUNDANT_VIA_INSERTION 0
set ROUTE_AUTO_CREATE_SHIELDS "none"

puts "BSG-info finished [info script]"
