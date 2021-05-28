remove_placement_blockages "cgra_blockage"

remove_routing_rule $CTS_NDR_RULE_NAME
create_routing_rule $CTS_NDR_RULE_NAME -default_reference_rule -multiplier_width 2 -multiplier_spacing 2 -shield
set_clock_routing_rules -net_type root -rule $CTS_NDR_RULE_NAME -min_routing_layer $CTS_NDR_MIN_ROUTING_LAYER -max_routing_layer $CTS_NDR_MAX_ROUTING_LAYER
set_clock_routing_rules -net_type internal -rule $CTS_NDR_RULE_NAME -min_routing_layer $CTS_NDR_MIN_ROUTING_LAYER -max_routing_layer $CTS_NDR_MAX_ROUTING_LAYER
