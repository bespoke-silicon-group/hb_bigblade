puts "BSG-info: Running script [info script]\n"

# constraints dir
source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_design_constants.tcl


# core clk
set clk_name            "manycore_clk"
set clk_period_ps       1000
set clk_uncertainty_ps  20
create_clock -period $clk_period_ps -name $clk_name [get_ports clk_i]
set_clock_uncertainty $clk_uncertainty_ps [get_clocks $clk_name]


# group the ports in orderly manner.
set reset_in_port  [get_ports reset_i]
set reset_out_port [get_ports reset_o]

set ver_input_ports  [list]
set ver_output_ports [list]
set wh_input_ports  [list]
set wh_output_ports [list]

for {set i 0} {$i < $HB_WH_LINK_WIDTH_P*2*$HB_WH_RUCHE_FACTOR_P} {incr i} {
  append_to_collection wh_input_ports  [get_ports "wh_link_sif_i[$i]"]
  append_to_collection wh_output_ports [get_ports "wh_link_sif_o[$i]"]
}

for {set i 0} {$i < $HB_LINK_WIDTH_P*2} {incr i} {
  append_to_collection ver_input_ports  [get_ports "ver_link_sif_i[$i]"]
  append_to_collection ver_output_ports [get_ports "ver_link_sif_o[$i]"]
}

# N=0
# S=1
for {set i 0} {$i < 2} {incr i} {
  set rev_data_out_ports($i)  [index_collection $ver_output_ports [expr 0+($HB_LINK_WIDTH_P*$i)] [expr 52+($HB_LINK_WIDTH_P*$i)]]
  set rev_ready_out_ports($i) [index_collection $ver_output_ports [expr 53+($HB_LINK_WIDTH_P*$i)]]
  set rev_valid_out_ports($i) [index_collection $ver_output_ports [expr 54+($HB_LINK_WIDTH_P*$i)]]
  set fwd_data_out_ports($i)  [index_collection $ver_output_ports [expr 55+($HB_LINK_WIDTH_P*$i)] [expr 151+($HB_LINK_WIDTH_P*$i)]]
  set fwd_ready_out_ports($i) [index_collection $ver_output_ports [expr 152+($HB_LINK_WIDTH_P*$i)]]
  set fwd_valid_out_ports($i) [index_collection $ver_output_ports [expr 153+($HB_LINK_WIDTH_P*$i)]]

  set rev_data_in_ports($i)   [index_collection $ver_input_ports [expr 0+($HB_LINK_WIDTH_P*$i)] [expr 52+($HB_LINK_WIDTH_P*$i)]]
  set rev_ready_in_ports($i)  [index_collection $ver_input_ports [expr 53+($HB_LINK_WIDTH_P*$i)]]
  set rev_valid_in_ports($i)  [index_collection $ver_input_ports [expr 54+($HB_LINK_WIDTH_P*$i)]]
  set fwd_data_in_ports($i)   [index_collection $ver_input_ports [expr 55+($HB_LINK_WIDTH_P*$i)] [expr 151+($HB_LINK_WIDTH_P*$i)]]
  set fwd_ready_in_ports($i)  [index_collection $ver_input_ports [expr 152+($HB_LINK_WIDTH_P*$i)]]
  set fwd_valid_in_ports($i)  [index_collection $ver_input_ports [expr 153+($HB_LINK_WIDTH_P*$i)]]
}

# W=0
# E=1
for {set i 0} {$i < 2} {incr i} {
  set wh_data_out_ports($i)  [index_collection $wh_output_ports [expr 0+($HB_WH_LINK_WIDTH_P*$i)] [expr 31+($HB_WH_LINK_WIDTH_P*$i)]]
  set wh_ready_out_ports($i) [index_collection $wh_output_ports [expr 32+($HB_WH_LINK_WIDTH_P*$i)]]
  set wh_valid_out_ports($i) [index_collection $wh_output_ports [expr 33+($HB_WH_LINK_WIDTH_P*$i)]]

  set wh_data_in_ports($i)  [index_collection $wh_input_ports [expr 0+($HB_WH_LINK_WIDTH_P*$i)] [expr 31+($HB_WH_LINK_WIDTH_P*$i)]]
  set wh_ready_in_ports($i) [index_collection $wh_input_ports [expr 32+($HB_WH_LINK_WIDTH_P*$i)]]
  set wh_valid_in_ports($i) [index_collection $wh_input_ports [expr 33+($HB_WH_LINK_WIDTH_P*$i)]]
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


# constraint links
for {set i 0} {$i < 2} {incr i} {
  # ver link
  constraint_output_ports $clk_name $rev_data_out_ports($i)  450 -75
  constraint_output_ports $clk_name $rev_ready_out_ports($i) 785 200
  constraint_output_ports $clk_name $rev_valid_out_ports($i) 570 -75
  constraint_output_ports $clk_name $fwd_data_out_ports($i)  450 -75
  constraint_output_ports $clk_name $fwd_ready_out_ports($i) 780 200
  constraint_output_ports $clk_name $fwd_valid_out_ports($i) 615 -75

  constraint_input_ports $clk_name $rev_data_in_ports($i)  825 200
  constraint_input_ports $clk_name $rev_ready_in_ports($i) 635 -75
  constraint_input_ports $clk_name $rev_valid_in_ports($i) 635 200
  constraint_input_ports $clk_name $fwd_data_in_ports($i)  825 200
  constraint_input_ports $clk_name $fwd_ready_in_ports($i) 625 -75
  constraint_input_ports $clk_name $fwd_valid_in_ports($i) 635 200

  # wh link
  constraint_output_ports $clk_name $wh_data_out_ports($i)  450 -75
  constraint_output_ports $clk_name $wh_ready_out_ports($i) 770 200
  constraint_output_ports $clk_name $wh_valid_out_ports($i) 425 -75

  constraint_input_ports $clk_name $wh_data_in_ports($i)  825 200
  constraint_input_ports $clk_name $wh_ready_in_ports($i) 535 -75
  constraint_input_ports $clk_name $wh_valid_in_ports($i) 635 200
}



# feedthrough input pins
set feedthrough_input_pins [index_collection $wh_input_ports [expr 2*$HB_WH_LINK_WIDTH_P] [expr (4*$HB_WH_LINK_WIDTH_P)-1]]
set_input_delay -min 20.0 ${feedthrough_input_pins} -clock ${clk_name}
set_input_delay -max 20.0 ${feedthrough_input_pins} -clock ${clk_name}
set_driving_cell -min -no_design_rule -lib_cell "SC7P5T_INVX8_SSC14R" $feedthrough_input_pins
set_driving_cell -max -no_design_rule -lib_cell "SC7P5T_INVX8_SSC14R" $feedthrough_input_pins
set_dont_touch [get_nets -of_objects $feedthrough_input_pins] true

# feedthrough output pins
set feedthrough_output_pins [index_collection $wh_output_ports [expr 2*$HB_WH_LINK_WIDTH_P] [expr (4*$HB_WH_LINK_WIDTH_P)-1]]
set_output_delay -min 20.0 ${feedthrough_output_pins} -clock ${clk_name}
set_output_delay -max 20.0 ${feedthrough_output_pins} -clock ${clk_name}
set_load -max [load_of [get_lib_pin "*/SC7P5T_INVX8_SSC14R/A"]] $feedthrough_output_pins
set_load -min [load_of [get_lib_pin "*/SC7P5T_INVX8_SSC14R/A"]] $feedthrough_output_pins


# reset port
constraint_input_ports  $clk_name $reset_in_port  0 40
constraint_output_ports $clk_name $reset_out_port 0 40


constraint_input_ports $clk_name [get_ports global_*_i*]  0 40
constraint_output_ports $clk_name [get_ports global_*_o*] 0 40




puts "BSG-info: Completed script [info script]\n"
