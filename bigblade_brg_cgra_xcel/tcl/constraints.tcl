puts "BSG-info: Running script [info script]\n"

# constraints dir
set constraints_dir $::env(BSG_DESIGNS_TARGET_DIR)/tcl

source $constraints_dir/hard/gf_14/adk.tcl

# constraints
if { ${DESIGN_NAME} == "brg_cgra_pod" } {
  #set clock_period 950.0
  set dc_clock_period 1250.0
  set dc_design_name ${DESIGN_NAME}
  source -echo -verbose $constraints_dir/constraints_pod.tcl
} elseif { ${DESIGN_NAME} == "ProcElement" } {
  set llfu_name LLFU
  #set clock_period 855.0
  set dc_clock_period 1155.0
  set dc_design_name ${DESIGN_NAME}
  source -echo -verbose $constraints_dir/constraints_pe.tcl
}

puts "BSG-info: Completed script [info script]\n"
