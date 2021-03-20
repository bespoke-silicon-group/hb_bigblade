puts "BSG-info: Running script [info script]\n"

########################################
source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_design_constants.tcl




# manycore interface
set core_clk_name           "manycore_clk"
set core_clk_period_ps      1000
set core_clk_uncertainty_ps 20


# grouping ports...
set core_reset_in_port  [get_ports core_reset_i]
set ver_input_ports   [list]
set ver_output_ports  [list]
set wh_input_ports   [list]
set wh_output_ports  [list]

for {set i 0} {$i < $HB_LINK_WIDTH_P} {incr i} {
  append_to_collection ver_input_ports  [get_ports "core_ver_link_sif_i[$i]"]
  append_to_collection ver_output_ports [get_ports "core_ver_link_sif_o[$i]"]
}

for {set rf 0} {$rf < $HB_WH_RUCHE_FACTOR_P} {incr rf} {
  for {set i 0} {$i < $HB_WH_LINK_WIDTH_P} {incr i} {
    set idx [expr $i+($rf*$HB_WH_LINK_WIDTH_P)]
    append_to_collection wh_input_ports  [get_ports "core_wh_link_sif_i[$idx]"]
    append_to_collection wh_output_ports [get_ports "core_wh_link_sif_o[$idx]"]
  }
}


set ver_rev_data_out_ports      [index_collection $ver_output_ports 0 52]
set ver_rev_ready_out_ports     [index_collection $ver_output_ports 53]
set ver_rev_valid_out_ports     [index_collection $ver_output_ports 54] 
set ver_fwd_data_out_ports      [index_collection $ver_output_ports 55 151] 
set ver_fwd_ready_out_ports     [index_collection $ver_output_ports 152] 
set ver_fwd_valid_out_ports     [index_collection $ver_output_ports 153] 

set ver_rev_data_in_ports       [index_collection $ver_input_ports 0 52] 
set ver_rev_ready_in_ports      [index_collection $ver_input_ports 53] 
set ver_rev_valid_in_ports      [index_collection $ver_input_ports 54] 
set ver_fwd_data_in_ports       [index_collection $ver_input_ports 55 151] 
set ver_fwd_ready_in_ports      [index_collection $ver_input_ports 152] 
set ver_fwd_valid_in_ports      [index_collection $ver_input_ports 153] 

for {set rf 0} {$rf < $HB_WH_RUCHE_FACTOR_P} {incr rf} {
  set wh_data_out_ports($rf)  [index_collection $wh_output_ports [expr 0+($HB_WH_LINK_WIDTH_P*$rf)] [expr 31+($HB_WH_LINK_WIDTH_P*$rf)]]
  set wh_ready_out_ports($rf) [index_collection $wh_output_ports [expr 32+($HB_WH_LINK_WIDTH_P*$rf)]]
  set wh_valid_out_ports($rf) [index_collection $wh_output_ports [expr 33+($HB_WH_LINK_WIDTH_P*$rf)]]

  set wh_data_in_ports($rf)  [index_collection $wh_input_ports [expr 0+($HB_WH_LINK_WIDTH_P*$rf)] [expr 31+($HB_WH_LINK_WIDTH_P*$rf)]]
  set wh_ready_in_ports($rf) [index_collection $wh_input_ports [expr 32+($HB_WH_LINK_WIDTH_P*$rf)]]
  set wh_valid_in_ports($rf) [index_collection $wh_input_ports [expr 33+($HB_WH_LINK_WIDTH_P*$rf)]]
}


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

# link constraints
# ver link
constraint_input_ports  $core_clk_name  $ver_rev_data_in_ports    780 200
constraint_input_ports  $core_clk_name  $ver_rev_valid_in_ports   680 200
constraint_output_ports $core_clk_name  $ver_rev_ready_out_ports  720 200

constraint_input_ports  $core_clk_name  $ver_fwd_data_in_ports    780 200
constraint_input_ports  $core_clk_name  $ver_fwd_valid_in_ports   680 200
constraint_output_ports $core_clk_name  $ver_fwd_ready_out_ports  720 200

constraint_output_ports $core_clk_name  $ver_rev_data_out_ports   250 -75
constraint_output_ports $core_clk_name  $ver_rev_valid_out_ports  650 -75
constraint_input_ports  $core_clk_name  $ver_rev_ready_in_ports   650 -75

constraint_output_ports $core_clk_name  $ver_fwd_data_out_ports   250 -75
constraint_output_ports $core_clk_name  $ver_fwd_valid_out_ports  650 -75
constraint_input_ports  $core_clk_name  $ver_fwd_ready_in_ports   650 -75

for {set rf 0} {$rf < $HB_WH_RUCHE_FACTOR_P} {incr rf} {
  # wh link
  constraint_output_ports $core_clk_name $wh_data_out_ports($rf)  350 -75
  constraint_output_ports $core_clk_name $wh_ready_out_ports($rf) 670 200
  constraint_output_ports $core_clk_name $wh_valid_out_ports($rf) 670 -75

  constraint_input_ports  $core_clk_name $wh_data_in_ports($rf)   730 200
  constraint_input_ports  $core_clk_name $wh_ready_in_ports($rf)  640 -75
  constraint_input_ports  $core_clk_name $wh_valid_in_ports($rf)  630 200
}



# core reset
constraint_input_ports $core_clk_name $core_reset_in_port 500 200





puts "BSG-info: Completed script [info script]\n"

