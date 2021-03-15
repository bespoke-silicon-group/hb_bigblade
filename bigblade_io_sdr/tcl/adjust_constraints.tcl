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
set hor_input_ports   [list]
set hor_output_ports  [list]
set ruche_input_ports   [list]
set ruche_output_ports  [list]

for {set i 0} {$i < [expr 2*$HB_LINK_WIDTH_P]} {incr i} {
  append_to_collection ver_input_ports  [get_ports "core_ver_link_sif_i[$i]"]
  append_to_collection ver_output_ports [get_ports "core_ver_link_sif_o[$i]"]
}

for {set i 0} {$i < $HB_LINK_WIDTH_P} {incr i} {
  append_to_collection hor_input_ports  [get_ports "core_hor_link_sif_i[$i]"]
  append_to_collection hor_output_ports [get_ports "core_hor_link_sif_o[$i]"]
}

for {set i 0} {$i < $HB_RUCHE_LINK_WIDTH_P} {incr i} {
  append_to_collection ruche_input_ports  [get_ports "core_ruche_link_i[$i]"]
  append_to_collection ruche_output_ports [get_ports "core_ruche_link_o[$i]"]
}


# N = 0
# S = 1
for {set i 0} {$i <= 1} {incr i} {
  set ver_rev_data_out_ports($i)       [index_collection $ver_output_ports [expr 0+($HB_LINK_WIDTH_P*$i)] [expr 52+($HB_LINK_WIDTH_P*$i)]] 
  set ver_rev_ready_out_ports($i)      [index_collection $ver_output_ports [expr 53+($HB_LINK_WIDTH_P*$i)]] 
  set ver_rev_valid_out_ports($i)      [index_collection $ver_output_ports [expr 54+($HB_LINK_WIDTH_P*$i)]] 
  set ver_fwd_data_out_ports($i)       [index_collection $ver_output_ports [expr 55+($HB_LINK_WIDTH_P*$i)] [expr 151+($HB_LINK_WIDTH_P*$i)]] 
  set ver_fwd_ready_out_ports($i)      [index_collection $ver_output_ports [expr 152+($HB_LINK_WIDTH_P*$i)]] 
  set ver_fwd_valid_out_ports($i)      [index_collection $ver_output_ports [expr 153+($HB_LINK_WIDTH_P*$i)]] 

  set ver_rev_data_in_ports($i)       [index_collection $ver_input_ports [expr 0+($HB_LINK_WIDTH_P*$i)] [expr 52+($HB_LINK_WIDTH_P*$i)]] 
  set ver_rev_ready_in_ports($i)      [index_collection $ver_input_ports [expr 53+($HB_LINK_WIDTH_P*$i)]] 
  set ver_rev_valid_in_ports($i)      [index_collection $ver_input_ports [expr 54+($HB_LINK_WIDTH_P*$i)]] 
  set ver_fwd_data_in_ports($i)       [index_collection $ver_input_ports [expr 55+($HB_LINK_WIDTH_P*$i)] [expr 151+($HB_LINK_WIDTH_P*$i)]] 
  set ver_fwd_ready_in_ports($i)      [index_collection $ver_input_ports [expr 152+($HB_LINK_WIDTH_P*$i)]] 
  set ver_fwd_valid_in_ports($i)      [index_collection $ver_input_ports [expr 153+($HB_LINK_WIDTH_P*$i)]] 
}

set hor_rev_data_out_ports      [index_collection $hor_output_ports 0 52]
set hor_rev_ready_out_ports     [index_collection $hor_output_ports 53]
set hor_rev_valid_out_ports     [index_collection $hor_output_ports 54] 
set hor_fwd_data_out_ports      [index_collection $hor_output_ports 55 151] 
set hor_fwd_ready_out_ports     [index_collection $hor_output_ports 152] 
set hor_fwd_valid_out_ports     [index_collection $hor_output_ports 153] 

set hor_rev_data_in_ports       [index_collection $hor_input_ports 0 52] 
set hor_rev_ready_in_ports      [index_collection $hor_input_ports 53] 
set hor_rev_valid_in_ports      [index_collection $hor_input_ports 54] 
set hor_fwd_data_in_ports       [index_collection $hor_input_ports 55 151] 
set hor_fwd_ready_in_ports      [index_collection $hor_input_ports 152] 
set hor_fwd_valid_in_ports      [index_collection $hor_input_ports 153] 

set ruche_rev_data_out_ports        [index_collection $ruche_output_ports 0 45] 
set ruche_rev_ready_out_ports       [index_collection $ruche_output_ports 46] 
set ruche_rev_valid_out_ports       [index_collection $ruche_output_ports 47] 
set ruche_fwd_data_out_ports        [index_collection $ruche_output_ports 48 137] 
set ruche_fwd_ready_out_ports       [index_collection $ruche_output_ports 138] 
set ruche_fwd_valid_out_ports       [index_collection $ruche_output_ports 139] 

set ruche_rev_data_in_ports        [index_collection $ruche_input_ports 0 45] 
set ruche_rev_ready_in_ports       [index_collection $ruche_input_ports 46] 
set ruche_rev_valid_in_ports       [index_collection $ruche_input_ports 47] 
set ruche_fwd_data_in_ports        [index_collection $ruche_input_ports 48 137] 
set ruche_fwd_ready_in_ports       [index_collection $ruche_input_ports 138] 
set ruche_fwd_valid_in_ports       [index_collection $ruche_input_ports 139] 


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

#   FIFO input constraints
#   N/S ver link
for {set i 0} {$i <= 1} {incr i} {
  constraint_input_ports $core_clk_name   $ver_rev_data_in_ports($i)     830 200
  constraint_input_ports $core_clk_name   $ver_rev_valid_in_ports($i)    750 200
  constraint_output_ports $core_clk_name  $ver_rev_ready_out_ports($i)   770 200

  constraint_input_ports $core_clk_name   $ver_fwd_data_in_ports($i)     830 200
  constraint_input_ports $core_clk_name   $ver_fwd_valid_in_ports($i)    740 200
  constraint_output_ports $core_clk_name  $ver_fwd_ready_out_ports($i)   780 200
}

# hor link
constraint_input_ports $core_clk_name   $hor_rev_data_in_ports          830 200
constraint_input_ports $core_clk_name   $hor_rev_valid_in_ports         770 200
constraint_output_ports $core_clk_name  $hor_rev_ready_out_ports        770 200

constraint_input_ports $core_clk_name   $hor_fwd_data_in_ports          830 200
constraint_input_ports $core_clk_name   $hor_fwd_valid_in_ports         750 200
constraint_output_ports $core_clk_name  $hor_fwd_ready_out_ports        780 200

# ruche link
constraint_input_ports $core_clk_name   $ruche_rev_data_in_ports        830 200
constraint_input_ports $core_clk_name   $ruche_rev_valid_in_ports       740 200
constraint_output_ports $core_clk_name  $ruche_rev_ready_out_ports      770 200

constraint_input_ports $core_clk_name   $ruche_fwd_data_in_ports        500 0
constraint_input_ports $core_clk_name   $ruche_fwd_valid_in_ports       500 0
constraint_output_ports $core_clk_name  $ruche_fwd_ready_out_ports      550 0

# router output constraints
# N/S ver link
for {set i 0} {$i <= 1} {incr i} {
  constraint_output_ports $core_clk_name $ver_rev_data_out_ports($i)   250 -75
  constraint_output_ports $core_clk_name $ver_rev_valid_out_ports($i)  580 -75
  constraint_input_ports  $core_clk_name $ver_rev_ready_in_ports($i)   680 -75

  constraint_output_ports $core_clk_name $ver_fwd_data_out_ports($i)   250 -75
  constraint_output_ports $core_clk_name $ver_fwd_valid_out_ports($i)  580 -75
  constraint_input_ports  $core_clk_name $ver_fwd_ready_in_ports($i)   660 -75
}

# hor link
constraint_output_ports $core_clk_name $hor_rev_data_out_ports   250 -75
constraint_output_ports $core_clk_name $hor_rev_valid_out_ports  590 -75
constraint_input_ports  $core_clk_name $hor_rev_ready_in_ports   690 -75

constraint_output_ports $core_clk_name $hor_fwd_data_out_ports   250 -75
constraint_output_ports $core_clk_name $hor_fwd_valid_out_ports  650 -75
constraint_input_ports  $core_clk_name $hor_fwd_ready_in_ports   740 -75

# ruche link
constraint_output_ports $core_clk_name $ruche_rev_data_out_ports   250 -75
constraint_output_ports $core_clk_name $ruche_rev_valid_out_ports  800 -75
constraint_input_ports  $core_clk_name $ruche_rev_ready_in_ports   410 -75

constraint_output_ports $core_clk_name $ruche_fwd_data_out_ports   250 -75
constraint_output_ports $core_clk_name $ruche_fwd_valid_out_ports  660 -75
constraint_input_ports  $core_clk_name $ruche_fwd_ready_in_ports   730 -75


# core reset
constraint_input_ports $core_clk_name $core_reset_in_port 500 200





puts "BSG-info: Completed script [info script]\n"

