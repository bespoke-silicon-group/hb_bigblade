
# constraints
if { ${DESIGN_NAME} == "bsg_manycore_tile_compute_ruche" } {
  source -echo -verbose $constraints_dir/bsg_manycore_tile_compute_ruche.constraints.tcl
} elseif { ${DESIGN_NAME} == "bsg_manycore_tile_vcache" } {
  source -echo -verbose $constraints_dir/bsg_manycore_tile_vcache.constraints.tcl
} elseif { ${DESIGN_NAME} == "bsg_chip_pod" } {
  source -echo -verbose $constraints_dir/bsg_chip_pod.constraints.tcl
}


puts "BSG-info: Completed script [info script]\n"
