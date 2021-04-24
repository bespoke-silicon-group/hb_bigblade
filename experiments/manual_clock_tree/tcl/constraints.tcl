#source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_design_constants.tcl


set clk_name            "manycore_clk"
set clk_period_ps       1000
set clk_uncertainty_ps  20

set_input_transition 50 [get_port clk_i*]
create_clock -period $clk_period_ps -name $clk_name [get_ports clk_i*]
set_clock_uncertainty $clk_uncertainty_ps [get_clocks $clk_name]


set input_ports [list]
append_to_collection input_ports [get_ports "data_i*"]
set_input_delay -max 0    -clock $clk_name $input_ports
set_input_delay -min 200  -clock $clk_name $input_ports
set_driving_cell -min -no_design_rule -lib_cell "SC7P5T_INVX8_SSC14R" $input_ports
set_driving_cell -max -no_design_rule -lib_cell "SC7P5T_INVX2_SSC14R" $input_ports


set output_ports [list]
append_to_collection output_ports [get_ports "data_o*"]
set_output_delay -max 0   -clock $clk_name $output_ports
set_output_delay -min 200 -clock $clk_name $output_ports
set_load -max [load_of [get_lib_pin "*/SC7P5T_INVX8_SSC14R/A"]] $output_ports
set_load -min [load_of [get_lib_pin "*/SC7P5T_INVX2_SSC14R/A"]] $output_ports


