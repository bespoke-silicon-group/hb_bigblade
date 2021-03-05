puts "Info: Start script [info script]\n"

# Source-sync link constraints
proc constrain_input_sdr_ports {clk_name ports max_delay min_delay} {
  set_input_delay -max $max_delay -clock $clk_name -source_latency_included -network_latency_included $ports
  set_input_delay -min $min_delay -clock $clk_name -source_latency_included -network_latency_included -add_delay $ports
  set_driving_cell -no_design_rule -lib_cell "SC7P5T_BUFX2_SSC14R" $ports
}
proc constrain_output_sdr_ports {clk_port ports setup_time hold_time} {
  foreach_in_collection obj $ports {
    set_data_check -from $clk_port -to $obj -setup $setup_time
    set_data_check -from $clk_port -to $obj -hold  $hold_time
    set_multicycle_path -end   -setup 1 -to $obj
    set_multicycle_path -start -hold  0 -to $obj
  }
  set_load [load_of [get_lib_pin "*/SC7P5T_BUFX2_SSC14R/A"]] $ports
}

puts "Info: Completed script [info script]\n"
