puts "BSG-info running [info script]"

remove_routing_blockages [get_routing_blockages {rb_bp_gap* rb_cgra_gap*}]
#remove_routing_blockages [get_routing_blockages {rb_pod_gap*}]
#remove_placement_blockages [get_placement_blockages pb_pod_gap*]

set TCL_USER_ROUTE_OPT_SCRIPT "$::env(BSG_DESIGNS_TARGET_TCL_HARD_DIR)/user_route_opt_script.tcl"
set REDUNDANT_VIA_INSERTION 0
set ROUTE_OPT_RESHIELD "none"

puts "BSG-info finished [info script]"
