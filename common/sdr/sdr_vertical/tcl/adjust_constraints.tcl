puts "BSG-info: Running script [info script]\n"

########################################
source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_design_constants.tcl




# manycore interface
set core_clk_name           "manycore_clk"
set core_clk_period_ps      1000
set core_clk_uncertainty_ps 20


# grouping ports...
set core_link_input_ports   [list]
set core_link_output_ports  [list]


for {set i 0} {$i < $HB_LINK_WIDTH_P} {incr i} {
  append_to_collection core_link_input_ports  [get_ports "core_link_sif_i[$i]"]
  append_to_collection core_link_output_ports [get_ports "core_link_sif_o[$i]"]
}


set core_link_rev_data_out_ports      [index_collection $core_link_output_ports 0 52]
set core_link_rev_ready_out_ports     [index_collection $core_link_output_ports 53]
set core_link_rev_valid_out_ports     [index_collection $core_link_output_ports 54] 
set core_link_fwd_data_out_ports      [index_collection $core_link_output_ports 55 151] 
set core_link_fwd_ready_out_ports     [index_collection $core_link_output_ports 152] 
set core_link_fwd_valid_out_ports     [index_collection $core_link_output_ports 153] 

set core_link_rev_data_in_ports       [index_collection $core_link_input_ports 0 52] 
set core_link_rev_ready_in_ports      [index_collection $core_link_input_ports 53] 
set core_link_rev_valid_in_ports      [index_collection $core_link_input_ports 54] 
set core_link_fwd_data_in_ports       [index_collection $core_link_input_ports 55 151] 
set core_link_fwd_ready_in_ports      [index_collection $core_link_input_ports 152] 
set core_link_fwd_valid_in_ports      [index_collection $core_link_input_ports 153] 


proc constraint_input_ports {clk_name ports max_delay min_delay} {
  set_input_delay -max $max_delay -clock $clk_name $ports
  set_input_delay -min $min_delay -clock $clk_name -add_delay $ports
  set_driving_cell -min -no_design_rule -lib_cell "SC7P5T_INVX8_SSC14R" $ports
  set_driving_cell -max -no_design_rule -lib_cell "SC7P5T_INVX2_SSC14R" $ports
}
proc constraint_output_ports {clk_name ports max_delay min_delay} {
  set_output_delay -max $max_delay -clock $clk_name $ports
  set_output_delay -min $min_delay -clock $clk_name -add_delay $ports
  set_load -max [load_of [get_lib_pin "*/SC7P5T_INVX8_SSC14R/A"]] $ports
  set_load -min [load_of [get_lib_pin "*/SC7P5T_INVX2_SSC14R/A"]] $ports
}

# input constraints
constraint_input_ports  $core_clk_name $core_link_rev_data_in_ports    830 200
constraint_input_ports  $core_clk_name $core_link_rev_valid_in_ports   770 200
constraint_output_ports $core_clk_name $core_link_rev_ready_out_ports  710 200
                                                                       
constraint_input_ports  $core_clk_name $core_link_fwd_data_in_ports    830 200
constraint_input_ports  $core_clk_name $core_link_fwd_valid_in_ports   750 200
constraint_output_ports $core_clk_name $core_link_fwd_ready_out_ports  690 200


# output constraints
constraint_output_ports $core_clk_name $core_link_rev_data_out_ports   150 -75
constraint_output_ports $core_clk_name $core_link_rev_valid_out_ports  590 -75
constraint_input_ports  $core_clk_name $core_link_rev_ready_in_ports   690 -75

constraint_output_ports $core_clk_name $core_link_fwd_data_out_ports   150 -75
constraint_output_ports $core_clk_name $core_link_fwd_valid_out_ports  650 -75
constraint_input_ports  $core_clk_name $core_link_fwd_ready_in_ports   740 -75





puts "BSG-info: Completed script [info script]\n"

