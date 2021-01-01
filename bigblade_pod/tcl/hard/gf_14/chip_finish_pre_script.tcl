puts "BSG-info: Running script [info script]\n"


if { $DESIGN_NAME == "bsg_chip_pod" } {
  route_eco

  # remove the hard placement blockages created during dp.placement,
  # so that filler cells can be inserted correctly.
  remove_placement_blockages [get_placement_blockages tile_rp*]
  #remove_placement_blockages [get_placement_blockages tile_right*]
  #remove_placement_blockages [get_placement_blockages tile_left*]
  remove_placement_blockages [get_placement_blockages north_vc_rp*]
  remove_placement_blockages [get_placement_blockages south_vc_rp*]
} elseif {$DESIGN_NAME == "bsg_manycore_tile_compute_ruche"} {
  route_eco
} elseif {$DESIGN_NAME == "bsg_manycore_tile_vcache"} {
  route_eco
}



puts "BSG-info: Completed script [info script]\n"


