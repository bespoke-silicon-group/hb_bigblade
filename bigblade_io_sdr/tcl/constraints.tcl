puts "BSG-info: Running script [info script]\n"

set constraints_dir $::env(BSG_DESIGNS_TARGET_DIR)/tcl

if { ${DESIGN_NAME} == "bsg_chip" } {
  source -echo -verbose $constraints_dir/bsg_chip.constraints.tcl
}

puts "BSG-info: Completed script [info script]\n"
