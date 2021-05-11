puts "BSG-info: Running script [info script]\n"

########################################
## Source common scripts
source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/bsg_chip_cdc.constraints.tcl
source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/bsg_chip_misc.tcl

# Loosen constraint
set core_clk_name "core_clk" ;# main clock running cgra
set core_clk_period_ps [get_attribute [get_clocks $core_clk_name] period]
set core_clk_uncertainty_per 3.0
set core_clk_uncertainty_ps  [expr min([expr $core_clk_period_ps*($core_clk_uncertainty_per/100.0)], 20)]

if {${DESIGN_NAME} == "brg_cgra_pod"} {
  set loosen_factor 1.50
  create_clock -period [expr $loosen_factor*$core_clk_period_ps] -name $core_clk_name [get_ports "clk_i"]
  set_clock_uncertainty $core_clk_uncertainty_ps [get_clocks $core_clk_name]
} else {
  set loosen_factor 1.20
  create_clock -period [expr $loosen_factor*$core_clk_period_ps] -name $core_clk_name [get_ports "clk"]
  set_clock_uncertainty $core_clk_uncertainty_ps [get_clocks $core_clk_name]
}


puts "BSG-info: Completed script [info script]\n"
