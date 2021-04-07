puts "BSG-info: Running script [info script]\n"

source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_design_constants.tcl

# ==========================================================
# Clock Constraints
# ==========================================================

set manycore_clk_name             "manycore_clk"
set manycore_clk_port             "clk_i"
set manycore_clk_period_ps        1000.0
set manycore_clk_uncertainty_ps   20

set_input_transition 50 [get_port $manycore_clk_port]
create_clock -period $manycore_clk_period_ps -name $manycore_clk_name [get_ports $manycore_clk_port]
set_clock_uncertainty $manycore_clk_uncertainty_ps [get_clocks $manycore_clk_name]

# ==========================================================
# Input Constraints
# ==========================================================

# set_driving_cell ...
# set_input_delay ...

# ==========================================================
# Output Constraints
# ==========================================================

# set_load ...
# set_output_delay ...

# ==========================================================
# Flatten and Dont Touch
# ==========================================================

set_ungroup [get_cells "rr*"] true

set hard_inv_cells [get_cells -hier -filter "name=~*hard_inv*"]
set_dont_touch $hard_inv_cells true
set_dont_touch [get_nets -of [get_pins -of $hard_inv_cells -filter "name==A"]] true
set_dont_touch [get_nets -of [get_pins -of $hard_inv_cells -filter "name==Z"]] true

puts "BSG-info: Completed script [info script]\n"
