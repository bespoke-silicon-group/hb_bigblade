puts "BSG-info: Running script [info script]\n"

source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_design_constants.tcl

# core clk
set clk_name           "manycore_clk"
set clk_period_ps      1000
set clk_uncertainty_ps 20
create_clock -period ${clk_period_ps} -name ${clk_name} [get_ports clk_i]
set_clock_uncertainty ${clk_uncertainty_ps} [get_clocks ${clk_name}]
set_input_transition 10 -min [get_ports clk_i]
set_input_transition 50 -max [get_ports clk_i]

# Grouping ports...
set reset_in_port  [get_ports reset_i]
set reset_out_port [get_ports reset_o]

set ruche_input_ports         [list]
set ruche_output_ports        [list]
set local_input_ports         [list]
set local_output_ports        [list]

for {set i 1} {$i < 5} {incr i} {
  for {set j 0} {$j < $HB_LINK_WIDTH_P} {incr j} {
    append_to_collection local_input_ports [get_ports "link_i[$i][$j]"]
    append_to_collection local_output_ports [get_ports "link_o[$i][$j]"]
  }
}

for {set i 0} {$i < 3} {incr i} {
  for {set j 1} {$j < 3} {incr j} {
    for {set k 0} {$k < $HB_RUCHE_LINK_WIDTH_P} {incr k} {
      append_to_collection ruche_input_ports [get_ports "ruche_link_i[$i][$j][$k]"]
      append_to_collection ruche_output_ports [get_ports "ruche_link_o[$i][$j][$k]"]
    }
  }
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


# FIFO input constraints
for {set i 0} {$i < 6} {incr i} {
  constraint_input_ports $clk_name $rev_data_in_ports($i)     935 0
  constraint_input_ports $clk_name $rev_valid_in_ports($i)    850 0
  constraint_output_ports $clk_name $rev_ready_out_ports($i)  910 0

  constraint_input_ports $clk_name $fwd_data_in_ports($i)     935 0
  constraint_input_ports $clk_name $fwd_valid_in_ports($i)    845 0
  constraint_output_ports $clk_name $fwd_ready_out_ports($i)  890 0
}


# FIFO output constraints
# W/E
for {set i 0} {$i < 2} {incr i} {
  constraint_output_ports $clk_name $rev_data_out_ports($i)   610 0
  constraint_output_ports $clk_name $rev_valid_out_ports($i)  655 0
  constraint_input_ports  $clk_name $rev_ready_in_ports($i)   885 0

  constraint_output_ports $clk_name $fwd_data_out_ports($i)   570 0
  constraint_output_ports $clk_name $fwd_valid_out_ports($i)  685 0
  constraint_input_ports  $clk_name $fwd_ready_in_ports($i)   850 0
}

# N/S
for {set i 2} {$i < 4} {incr i} {
  constraint_output_ports $clk_name $rev_data_out_ports($i)   665 0
  constraint_output_ports $clk_name $rev_valid_out_ports($i)  740 0
  constraint_input_ports  $clk_name $rev_ready_in_ports($i)   890 0

  constraint_output_ports $clk_name $fwd_data_out_ports($i)   570 0
  constraint_output_ports $clk_name $fwd_valid_out_ports($i)  710 0
  constraint_input_ports  $clk_name $fwd_ready_in_ports($i)   860 0
}

# RW/RE
for {set i 4} {$i < 6} {incr i} {
  constraint_output_ports $clk_name $rev_data_out_ports($i)   605 0
  constraint_output_ports $clk_name $rev_valid_out_ports($i)  660 0
  constraint_input_ports  $clk_name $rev_ready_in_ports($i)   855 0

  constraint_output_ports $clk_name $fwd_data_out_ports($i)   605 0
  constraint_output_ports $clk_name $fwd_valid_out_ports($i)  700 0
  constraint_input_ports  $clk_name $fwd_ready_in_ports($i)   860 0
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


# reset ports
constraint_input_ports  $clk_name $reset_in_port  40 40
constraint_output_ports $clk_name $reset_out_port 40 40
constraint_input_ports  $clk_name [get_ports global_*_i*] 40 40
constraint_output_ports $clk_name [get_ports global_*_o*] 40 40

set multicycle_cells [list]
append_to_collection multicycle_cells [get_cells dff_x/data_r_reg*]
append_to_collection multicycle_cells [get_cells dff_y/data_r_reg*]
append_to_collection multicycle_cells [get_cells dff_reset/data_r_reg*]
set_multicycle_path 2 -setup -to   $multicycle_cells
set_multicycle_path 2 -hold  -to   $multicycle_cells
set_multicycle_path 2 -setup -from $multicycle_cells
set_multicycle_path 2 -hold  -from $multicycle_cells


#set_false_path -from [get_ports global_*_i*]
#set_false_path -to   [get_ports global_*_o*]



# derating
set cells_to_derate [list]
append_to_collection cells_to_derate [get_cells -quiet -hier -filter "ref_name=~gf14_*"]
append_to_collection cells_to_derate [get_cells -quiet -hier -filter "ref_name=~IN12LP_*"]

if { [sizeof $cells_to_derate] > 0 } {
  foreach_in_collection cell $cells_to_derate {
    set_timing_derate -cell_delay -early 0.97 $cell
    set_timing_derate -cell_delay -late  1.03 $cell
    set_timing_derate -cell_check -early 0.97 $cell
    set_timing_derate -cell_check -late  1.03 $cell
  }
}




# Ungroup
set_ungroup [get_designs -filter "hdl_template==bsg_mux"] true
set_ungroup [get_designs -filter "hdl_template==bsg_manycore_reg_id_decode"] true
set_ungroup [get_designs -filter "hdl_template==bsg_manycore_endpoint"] true
set_ungroup [get_designs -filter "hdl_template==bsg_manycore_endpoint_fc"] true
set_ungroup [get_designs -filter "hdl_template==network_tx"] true
set_ungroup [get_designs -filter "hdl_template==network_rx"] true
set_ungroup [get_designs -filter "hdl_template==bsg_scan"] true
set_ungroup [get_designs -filter "hdl_template==reverse"] true
set_ungroup [get_designs -filter "hdl_template==recFNToRawFN"] true
set_ungroup [get_designs -filter "hdl_template==bsg_manycore_dram_hash_function"] true
set_ungroup [get_designs -filter "hdl_template==bsg_manycore_eva_to_npa"] true
set_ungroup [get_designs -filter "hdl_template==bsg_transpose"] true
set_ungroup [get_designs -filter "hdl_template==bsg_concentrate_static"] true
set_ungroup [get_designs -filter "hdl_template==bsg_array_concentrate_static"] true
set_ungroup [get_designs -filter "hdl_template==bsg_unconcentrate_static"] true
set_ungroup [get_designs fpu_float_fma] false
set_ungroup [get_designs fpu_float_fma_round] false
ungroup [get_cells proc/h.z/vcore/fpu_int0/*] -flatten
ungroup [get_cells proc/h.z/vcore/fpu_float0/fma1/*] -flatten
ungroup [get_cells proc/h.z/vcore/fpu_float0/fma2/*] -flatten
ungroup [get_cells proc/h.z/vcore/fpu_float0/aux0/*] -flatten
ungroup [get_cells proc/h.z/vcore/fpu_fdiv_fsqrt0/*] -flatten
ungroup [get_cells proc/h.z/vcore/idiv0/*] -flatten

# Retiming
set_optimize_registers true -designs [get_designs fpu_float_fma] -check_design -verbose
set_optimize_registers true -designs [get_designs fpu_float_fma_round] -check_design -verbose

#set_app_var case_analysis_propagate_through_icg true
#update_timing

puts "BSG-info: Completed script [info script]\n"
