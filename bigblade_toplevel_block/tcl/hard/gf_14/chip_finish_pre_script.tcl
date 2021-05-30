
# FIXME: delete this file when actual BP and CGRA blocks are added
remove_placement_blockages [get_placement_blockages {pb_bp_block*}]
remove_placement_blockages [get_placement_blockages {pb_cgra_block*}]
remove_routing_blockages [get_routing_blockages {rb_bp_block*}]
remove_routing_blockages [get_routing_blockages {rb_cgra_block*}]

check_legality
