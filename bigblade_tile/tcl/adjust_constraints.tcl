puts "BSG-info: Running script [info script]\n"

# constraints dir
set constraints_dir $::env(BSG_DESIGNS_TARGET_DIR)/tcl

# clock setup config
set manycore_clk_name             "manycore_clk"
set manycore_clk_period_ps        1000.0
set manycore_clk_uncertainty_ps   20


# constraints
source -echo -verbose $constraints_dir/${DESIGN_NAME}.apr.constraints.tcl


puts "BSG-info: Completed script [info script]\n"
