puts "BSG-info: Running script [info script]\n"

source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_design_constants.tcl

# ==========================================================
# Clock Constraints
# ==========================================================

set manycore_clk_name             "manycore_clk"
set manycore_clk_port             "clk_i*"
set manycore_clk_period_ps        1000.0
set manycore_clk_uncertainty_ps   20

set_input_transition 50 [get_port $manycore_clk_port]
create_clock -period $manycore_clk_period_ps -name $manycore_clk_name [get_ports $manycore_clk_port]
set_clock_uncertainty $manycore_clk_uncertainty_ps [get_clocks $manycore_clk_name]

# ==========================================================
# Input Constraints
# ==========================================================
set input_ports [list]
append_to_collection input_ports [get_ports "reset_i*"]
append_to_collection input_ports [get_ports "wh_link_sif_i*"]
append_to_collection input_ports [get_ports "ver_link_sif_i*"]
append_to_collection input_ports [get_ports "global_*_i*"]
set_input_delay -max 0    -clock $manycore_clk_name $input_ports
set_input_delay -min 200  -clock $manycore_clk_name $input_ports
set_driving_cell -min -no_design_rule -lib_cell "SC7P5T_INVX8_SSC14R" $input_ports
set_driving_cell -max -no_design_rule -lib_cell "SC7P5T_INVX2_SSC14R" $input_ports

# ==========================================================
# Output Constraints
# ==========================================================
set output_ports [list]
append_to_collection output_ports [get_ports "reset_o*"]
append_to_collection output_ports [get_ports "wh_link_sif_o*"]
append_to_collection output_ports [get_ports "ver_link_sif_o*"]
append_to_collection output_ports [get_ports "global_*_o*"]
set_output_delay -max 0   -clock $manycore_clk_name $output_ports
set_output_delay -min 200 -clock $manycore_clk_name $output_ports
set_load -max [load_of [get_lib_pin "*/SC7P5T_INVX8_SSC14R/A"]] $output_ports
set_load -min [load_of [get_lib_pin "*/SC7P5T_INVX2_SSC14R/A"]] $output_ports

# ==========================================================
# Flatten and Dont Touch
# ==========================================================

set_ungroup [get_cells "rr*"] true

set hard_inv_cells [get_cells -hier -filter "name=~*hard_inv*"]
set_dont_touch $hard_inv_cells true
set_dont_touch [get_nets -of [get_pins -of $hard_inv_cells -filter "name==A"]] true
set_dont_touch [get_nets -of [get_pins -of $hard_inv_cells -filter "name==Z"]] true

puts "BSG-info: Completed script [info script]\n"
