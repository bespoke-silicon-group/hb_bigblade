puts "BSG-info: Running script [info script]\n"

set core_clk_name           "core_clk"
set core_clk_period_ps      800.0 ;# 1.25 GHz

# grouping ports...
set core_valid_in_ports        [get_ports core_v_i]
set core_data_in_ports         [get_ports core_data_i]
set core_ready_and_out_ports   [get_ports core_ready_and_o]
set core_valid_out_ports       [get_ports core_v_o]
set core_data_out_ports        [get_ports core_data_o]
set core_yumi_in_ports         [get_ports core_yumi_i]

proc constraint_input_ports {clk_name ports max_delay min_delay} {
  set_input_delay -max $max_delay -clock $clk_name $ports
  set_input_delay -min $min_delay -clock $clk_name $ports
  set_driving_cell -min -no_design_rule -lib_cell "SC7P5T_INVX8_SSC14R" $ports
  set_driving_cell -max -no_design_rule -lib_cell "SC7P5T_INVX2_SSC14R" $ports
}
proc constraint_output_ports {clk_name ports max_delay min_delay} {
  set_output_delay -max $max_delay -clock $clk_name $ports
  set_output_delay -min $min_delay -clock $clk_name $ports
  set_load -max [load_of [get_lib_pin "*/SC7P5T_INVX8_SSC14R/A"]] $ports
  set_load -min [load_of [get_lib_pin "*/SC7P5T_INVX2_SSC14R/A"]] $ports
}

constraint_input_ports  $core_clk_name   $core_valid_in_ports        [expr $core_clk_period_ps-270]   -5
constraint_input_ports  $core_clk_name   $core_data_in_ports         [expr $core_clk_period_ps-180]   75
constraint_output_ports $core_clk_name   $core_ready_and_out_ports   [expr $core_clk_period_ps-220]  -20

constraint_output_ports $core_clk_name   $core_valid_out_ports       [expr $core_clk_period_ps-170]   -5
constraint_output_ports $core_clk_name   $core_data_out_ports        [expr $core_clk_period_ps-200]    0
constraint_input_ports  $core_clk_name   $core_yumi_in_ports         [expr $core_clk_period_ps-165]   25

puts "BSG-info: Completed script [info script]\n"
