puts "BSG-info: Running script [info script]\n"


if { $DESIGN_NAME == "bsg_chip_pod" } {
  set ROUTE_AUTO_CREATE_SHIELDS "none"
} elseif {$DESIGN_NAME == "bsg_manycore_tile_compute_ruche"} {
  set ROUTE_AUTO_CREATE_SHIELDS "none"
} elseif {$DESIGN_NAME == "bsg_manycore_tile_vcache"} {
  set ROUTE_AUTO_CREATE_SHIELDS "none"
}



puts "BSG-info: Completed script [info script]\n"
