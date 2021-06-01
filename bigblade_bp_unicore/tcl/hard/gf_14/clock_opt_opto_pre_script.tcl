# remove temporary placement blockages for I/O
remove_placement_blockages [get_placement_blockages sdr_place_blockage_0]
remove_placement_blockages [get_placement_blockages sdr_place_blockage_1]
remove_placement_blockages [get_placement_blockages sdr_place_blockage_2]
remove_placement_blockages [get_placement_blockages sdr_place_blockage_3]
remove_placement_blockages [get_placement_blockages sdr_place_blockage_4]
# Hold fixing
set_app_options -name clock_opt.hold.effort -value high
set_app_options -name refine_opt.hold.effort -value high
