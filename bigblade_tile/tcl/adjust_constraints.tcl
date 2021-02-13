puts "BSG-info: Running script [info script]\n"


source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/tcl/hb_design_constants.tcl

# core clk
set clk_name           "manycore_clk"
set clk_period_ps      1000
set clk_uncertainty_ps 20
create_clock -period ${clk_period_ps} -name ${clk_name} [get_ports clk_i]
set_clock_uncertainty ${clk_uncertainty_ps} [get_clocks ${clk_name}]


# Grouping ports...
set reset_port [get_ports reset_i]

set ruche_input_ports         [list]
set ruche_output_ports        [list]
set local_input_ports         [list]
set local_output_ports        [list]

for {set i 0} {$i < [expr 4*$HB_LINK_WIDTH_P]} {incr i} {
  append_to_collection local_input_ports  [get_ports "link_i[$i]"]
  append_to_collection local_output_ports [get_ports "link_o[$i]"]
}

for {set i 0} {$i < [expr 6*$HB_RUCHE_LINK_WIDTH_P]} {incr i} {
  append_to_collection ruche_input_ports [get_ports "ruche_link_i[$i]"]
  append_to_collection ruche_output_ports [get_ports "ruche_link_o[$i]"]
}



# W = 0
# E = 1
# N = 2
# S = 3
# RW = 4
# RE = 5
for {set i 0} {$i < 4} {incr i} {
  set rev_data_out_ports($i)       [index_collection $local_output_ports [expr 0+($HB_LINK_WIDTH_P*$i)] [expr 52+($HB_LINK_WIDTH_P*$i)]] 
  set rev_ready_out_ports($i)      [index_collection $local_output_ports [expr 53+($HB_LINK_WIDTH_P*$i)]] 
  set rev_valid_out_ports($i)      [index_collection $local_output_ports [expr 54+($HB_LINK_WIDTH_P*$i)]] 
  set fwd_data_out_ports($i)       [index_collection $local_output_ports [expr 55+($HB_LINK_WIDTH_P*$i)] [expr 151+($HB_LINK_WIDTH_P*$i)]] 
  set fwd_ready_out_ports($i)      [index_collection $local_output_ports [expr 152+($HB_LINK_WIDTH_P*$i)]] 
  set fwd_valid_out_ports($i)      [index_collection $local_output_ports [expr 153+($HB_LINK_WIDTH_P*$i)]] 

  set rev_data_in_ports($i)       [index_collection $local_input_ports [expr 0+($HB_LINK_WIDTH_P*$i)] [expr 52+($HB_LINK_WIDTH_P*$i)]] 
  set rev_ready_in_ports($i)      [index_collection $local_input_ports [expr 53+($HB_LINK_WIDTH_P*$i)]] 
  set rev_valid_in_ports($i)      [index_collection $local_input_ports [expr 54+($HB_LINK_WIDTH_P*$i)]] 
  set fwd_data_in_ports($i)       [index_collection $local_input_ports [expr 55+($HB_LINK_WIDTH_P*$i)] [expr 151+($HB_LINK_WIDTH_P*$i)]] 
  set fwd_ready_in_ports($i)      [index_collection $local_input_ports [expr 152+($HB_LINK_WIDTH_P*$i)]] 
  set fwd_valid_in_ports($i)      [index_collection $local_input_ports [expr 153+($HB_LINK_WIDTH_P*$i)]] 
}

for {set i 0} {$i < 2} {incr i} {
  set dir [expr $i+4]
  set rev_data_out_ports($dir)        [index_collection $ruche_output_ports [expr 0+($HB_RUCHE_LINK_WIDTH_P*$i)] [expr 45+($HB_RUCHE_LINK_WIDTH_P*$i)]] 
  set rev_ready_out_ports($dir)       [index_collection $ruche_output_ports [expr 46+($HB_RUCHE_LINK_WIDTH_P*$i)]] 
  set rev_valid_out_ports($dir)       [index_collection $ruche_output_ports [expr 47+($HB_RUCHE_LINK_WIDTH_P*$i)]] 
  set fwd_data_out_ports($dir)        [index_collection $ruche_output_ports [expr 48+($HB_RUCHE_LINK_WIDTH_P*$i)] [expr 137+($HB_RUCHE_LINK_WIDTH_P*$i)]] 
  set fwd_ready_out_ports($dir)       [index_collection $ruche_output_ports [expr 138+($HB_RUCHE_LINK_WIDTH_P*$i)]] 
  set fwd_valid_out_ports($dir)       [index_collection $ruche_output_ports [expr 139+($HB_RUCHE_LINK_WIDTH_P*$i)]] 

  set rev_data_in_ports($dir)        [index_collection $ruche_input_ports [expr 0+($HB_RUCHE_LINK_WIDTH_P*$i)] [expr 45+($HB_RUCHE_LINK_WIDTH_P*$i)]] 
  set rev_ready_in_ports($dir)       [index_collection $ruche_input_ports [expr 46+($HB_RUCHE_LINK_WIDTH_P*$i)]] 
  set rev_valid_in_ports($dir)       [index_collection $ruche_input_ports [expr 47+($HB_RUCHE_LINK_WIDTH_P*$i)]] 
  set fwd_data_in_ports($dir)        [index_collection $ruche_input_ports [expr 48+($HB_RUCHE_LINK_WIDTH_P*$i)] [expr 137+($HB_RUCHE_LINK_WIDTH_P*$i)]] 
  set fwd_ready_in_ports($dir)       [index_collection $ruche_input_ports [expr 138+($HB_RUCHE_LINK_WIDTH_P*$i)]] 
  set fwd_valid_in_ports($dir)       [index_collection $ruche_input_ports [expr 139+($HB_RUCHE_LINK_WIDTH_P*$i)]] 
}


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

constraint_input_ports $clk_name $reset_port 500 0

# ruche link delay
set ruche_max_delay 150

# FIFO input constraints
for {set i 0} {$i < 6} {incr i} {
  constraint_input_ports $clk_name $rev_data_in_ports($i)      885   200
  constraint_input_ports $clk_name $rev_valid_in_ports($i)     800   10
  constraint_output_ports $clk_name $rev_ready_out_ports($i)   860   -55

  constraint_input_ports $clk_name $fwd_data_in_ports($i)      885   200
  constraint_input_ports $clk_name $fwd_valid_in_ports($i)     795   10
  constraint_output_ports $clk_name $fwd_ready_out_ports($i)   840   -55
}


# FIFO output constraints
for {set i 0} {$i < 2} {incr i} {
  constraint_output_ports $clk_name $rev_valid_out_ports($i)    65    -60
  constraint_output_ports $clk_name $rev_data_out_ports($i)     150   -75
  constraint_input_ports  $clk_name $rev_ready_in_ports($i)     90    -50

  constraint_output_ports $clk_name $fwd_valid_out_ports($i)    65    -60
  constraint_output_ports $clk_name $fwd_data_out_ports($i)     155   -75
  constraint_input_ports  $clk_name $fwd_ready_in_ports($i)     110   -50
}

for {set i 2} {$i < 4} {incr i} {
  constraint_output_ports $clk_name $rev_valid_out_ports($i)    65    -60
  constraint_output_ports $clk_name $rev_data_out_ports($i)     150   -75
  constraint_input_ports  $clk_name $rev_ready_in_ports($i)     90    -50

  constraint_output_ports $clk_name $fwd_valid_out_ports($i)    65    -60
  constraint_output_ports $clk_name $fwd_data_out_ports($i)     155   -75
  constraint_input_ports  $clk_name $fwd_ready_in_ports($i)     110   -50
}

for {set i 4} {$i < 6} {incr i} {
  constraint_output_ports $clk_name $rev_valid_out_ports($i)    215   -20
  constraint_output_ports $clk_name $rev_data_out_ports($i)     300   -35
  constraint_input_ports  $clk_name $rev_ready_in_ports($i)     240   -10

  constraint_output_ports $clk_name $fwd_valid_out_ports($i)    350   -20
  constraint_output_ports $clk_name $fwd_data_out_ports($i)     305   -35
  constraint_input_ports  $clk_name $fwd_ready_in_ports($i)     260   -10
}


# feedthrough input pins
set feedthrough_input_pins [index_collection $ruche_input_ports [expr 2*$HB_RUCHE_LINK_WIDTH_P] [expr (6*$HB_RUCHE_LINK_WIDTH_P)-1]]
set_input_delay -min 20.0 ${feedthrough_input_pins} -clock ${clk_name}
set_input_delay -max 20.0 ${feedthrough_input_pins} -clock ${clk_name}
set_driving_cell -min -no_design_rule -lib_cell "SC7P5T_INVX8_SSC14R" $feedthrough_input_pins
set_driving_cell -max -no_design_rule -lib_cell "SC7P5T_INVX8_SSC14R" $feedthrough_input_pins
set_dont_touch [get_nets -of_objects $feedthrough_input_pins] true



# feedthrough output pins
set feedthrough_output_pins [index_collection $ruche_output_ports [expr 2*$HB_RUCHE_LINK_WIDTH_P] [expr (6*$HB_RUCHE_LINK_WIDTH_P)-1]]
set_output_delay -min 20.0 ${feedthrough_output_pins} -clock ${clk_name}
set_output_delay -max 20.0 ${feedthrough_output_pins} -clock ${clk_name}
set_load -max [load_of [get_lib_pin "*/SC7P5T_INVX8_SSC14R/A"]] $feedthrough_output_pins
set_load -min [load_of [get_lib_pin "*/SC7P5T_INVX8_SSC14R/A"]] $feedthrough_output_pins












puts "BSG-info: Completed script [info script]\n"
