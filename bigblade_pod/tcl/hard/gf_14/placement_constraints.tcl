puts "BSG-info: Running script [info script]\n"

set_app_options -name plan.place.auto_generate_blockages -value false

set_dont_touch [get_nets -of [get_pins "pod/mc/y_*__x_*__tile/ruche_link_i*"] -boundary_type upper] true
set_dont_touch [get_nets -of [get_pins "pod/mc/y_*__x_*__tile/ruche_link_o*"] -boundary_type upper] true


#source $::env(BSG_DESIGNS_TARGET_TCL_HARD_DIR)/hb_placement_blockage.tcl
source $::env(BSG_DESIGNS_TARGET_TCL_HARD_DIR)/hb_placement_sram.tcl
source $::env(BSG_DESIGNS_TARGET_TCL_HARD_DIR)/hb_placement_rp_group.tcl

puts "BSG-info: Completed script [info script]\n"
