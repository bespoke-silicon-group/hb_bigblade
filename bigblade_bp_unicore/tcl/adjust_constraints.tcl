puts "BSG-info: Running script [info script]\n"

########################################
## Source common scripts
source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/bsg_chip_cdc.constraints.tcl
source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/bsg_chip_misc.tcl

# TODO: Put names in common
# Loosen constraint
set core_clk_name "core_clk" ;# main clock running black parrot
set core_clk_period_ps [get_attribute [get_clocks ${core_clk_name}] period]
set core_clk_uncertainty_ps 20

set loosen_factor 1.10
create_clock -period [expr ${loosen_factor}*${core_clk_period_ps}] -name ${core_clk_name} [get_ports "clk_i"]
set_clock_uncertainty ${core_clk_uncertainty_ps} [get_clocks ${core_clk_name}]

puts "BSG-info: Completed script [info script]\n"
