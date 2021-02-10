puts "BSG-info: Running script [info script]\n"

# constraints dir
set constraints_dir $::env(BSG_DESIGNS_TARGET_DIR)/tcl

# clock setup config
set router_clk_name               "router_clk"
set router_clk_period_ps          1666.0
set router_clk_uncertainty_ps     20

set io_master_clk_name            "io_master_clk"
set io_master_clk_period_ps       1666.0
set io_master_clk_uncertainty_ps  20

set manycore_clk_name             "manycore_clk"
set manycore_clk_period_ps        1000.0
set manycore_clk_uncertainty_ps   20

set tag_clk_name                  "tag_clk"
set tag_clk_period_ps             6666.0
set tag_clk_uncertainty_ps        20

set oscillator_period_ps          250.0
set oscillator_uncertainty_ps     20
set ds_uncertainty_ps             20


# constraints
if { ${DESIGN_NAME} == "bsg_manycore_tile_compute_ruche" } {
  source -echo -verbose $constraints_dir/bsg_manycore_tile_compute_ruche.synth.constraints.tcl
} elseif { ${DESIGN_NAME} == "bsg_manycore_tile_vcache" } {
  source -echo -verbose $constraints_dir/bsg_manycore_tile_vcache.constraints.tcl
} elseif { ${DESIGN_NAME} == "bsg_chip_pod" } {
  source -echo -verbose $constraints_dir/bsg_chip_pod.constraints.tcl
}


puts "BSG-info: Completed script [info script]\n"
