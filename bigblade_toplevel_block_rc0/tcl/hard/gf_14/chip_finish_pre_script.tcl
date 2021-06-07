
# remove placement blockages before filler cell insertion
remove_placement_blockages [get_placement_blockages {pb_pod_*}]
remove_placement_blockages [get_placement_blockages {pb_bp_*}]
remove_placement_blockages [get_placement_blockages {pb_cgra_*}]

check_legality
