puts "Info: Start script [info script]\n"

# Source-sync link constraints
proc constrain_input_sdr_ports {clk_name ports max_delay min_delay} {
  set_input_delay -max $max_delay -clock $clk_name -source_latency_included -network_latency_included $ports
  set_input_delay -min $min_delay -clock $clk_name -source_latency_included -network_latency_included -add_delay $ports
  set_driving_cell -no_design_rule -lib_cell "SC7P5T_DFFQX1_SSC14R" $ports
}
proc constrain_output_sdr_ports {clk_name ports max_delay min_delay} {
  set_output_delay -max $max_delay -clock $clk_name $ports
  set_output_delay -min $min_delay -clock $clk_name -add_delay $ports
  set_load [load_of [get_lib_pin "*/SC7P5T_BUFX1_SSC14R/A"]] $ports
}

puts "Info: Completed script [info script]\n"
