puts "BSG-info: Running script [info script]\n"

# constraints dir
source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_design_constants.tcl


# core clk
set clk_name            "manycore_clk"
set clk_period_ps       1000
set clk_uncertainty_ps  20
create_clock -period $clk_period_ps -name $clk_name [get_ports clk_i]
set_clock_uncertainty $clk_uncertainty_ps [get_clocks $clk_name]
set_input_transition 10 -min [get_ports clk_i]
set_input_transition 50 -max [get_ports clk_i]


# group the ports in orderly manner.
set reset_in_port  [get_ports reset_i]
set reset_out_port [get_ports reset_o]

set ver_input_ports  [list]
set ver_output_ports [list]
set wh_input_ports  [list]
set wh_output_ports [list]

for {set rf 0} {$rf < $HB_WH_RUCHE_FACTOR_P} {incr rf} {
  for {set dir 1} {$dir <= 2} {incr dir} {
    for {set i 0} {$i < $HB_WH_LINK_WIDTH_P} {incr i} {
      append_to_collection wh_input_ports  [get_ports "wh_link_sif_i[$rf][$dir][$i]"]
      append_to_collection wh_output_ports [get_ports "wh_link_sif_o[$rf][$dir][$i]"]
    }
  }
}

for {set dir 3} {$dir <= 4} {incr dir} {
  for {set i 0} {$i < $HB_LINK_WIDTH_P} {incr i} {
    append_to_collection ver_input_ports  [get_ports "ver_link_sif_i[$dir][$i]"]
    append_to_collection ver_output_ports [get_ports "ver_link_sif_o[$dir][$i]"]
  }
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
  constraint_output_ports $clk_name $rev_data_out_ports($i)  560 0
  constraint_output_ports $clk_name $rev_ready_out_ports($i) 885 0
  constraint_output_ports $clk_name $rev_valid_out_ports($i) 670 0
  constraint_output_ports $clk_name $fwd_data_out_ports($i)  590 0
  constraint_output_ports $clk_name $fwd_ready_out_ports($i) 880 0
  constraint_output_ports $clk_name $fwd_valid_out_ports($i) 715 0

  constraint_input_ports $clk_name $rev_data_in_ports($i)  925 0
  constraint_input_ports $clk_name $rev_ready_in_ports($i) 835 0
  constraint_input_ports $clk_name $rev_valid_in_ports($i) 835 0
  constraint_input_ports $clk_name $fwd_data_in_ports($i)  925 0
  constraint_input_ports $clk_name $fwd_ready_in_ports($i) 825 0
  constraint_input_ports $clk_name $fwd_valid_in_ports($i) 835 0

  # wh link
  constraint_output_ports $clk_name $wh_data_out_ports($i)  565 0
  constraint_output_ports $clk_name $wh_ready_out_ports($i) 870 0
  constraint_output_ports $clk_name $wh_valid_out_ports($i) 625 0

  constraint_input_ports $clk_name $wh_data_in_ports($i)  925 0
  constraint_input_ports $clk_name $wh_ready_in_ports($i) 735 0
  constraint_input_ports $clk_name $wh_valid_in_ports($i) 835 0
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
constraint_input_ports  $clk_name $reset_in_port  20 20
constraint_output_ports $clk_name $reset_out_port 20 20
constraint_input_ports  $clk_name [get_ports global_*_i*] 20 20
constraint_output_ports $clk_name [get_ports global_*_o*] 20 20


# The timing paths to/from these registers don't need a single-cycle requirement,
# because the signals are mostly static. We relax the constraints by allowing double cycle.
# The hold cycle is set to 2, so that it becomes much easier to meet hold check.
set_multicycle_path 2 -setup -to   [get_cells *_dff/data_r_reg*] 
set_multicycle_path 2 -hold  -to   [get_cells *_dff/data_r_reg*] 
set_multicycle_path 2 -setup -from [get_cells *_dff/data_r_reg*] 
set_multicycle_path 2 -hold  -from [get_cells *_dff/data_r_reg*] 

# ungrouping
set_ungroup [get_designs -filter "hdl_template==bsg_mux"] true
set_ungroup [get_designs -filter "hdl_template==bsg_decode"] true
set_ungroup [get_designs -filter "hdl_template==bsg_mux_segmented"] true
set_ungroup [get_designs -filter "hdl_template==bsg_mux_one_hot"] true
set_ungroup [get_designs -filter "hdl_template==bsg_scan"] true
set_ungroup [get_designs -filter "hdl_template==bsg_expand_bitmask"] true
set_ungroup [get_designs -filter "hdl_template==bsg_manycore_endpoint"] true
set_ungroup [get_designs -filter "hdl_template==bsg_transpose"] true
set_ungroup [get_designs -filter "hdl_template==bsg_concentrate_static"] true
set_ungroup [get_designs -filter "hdl_template==bsg_array_concentrate_static"] true
set_ungroup [get_designs -filter "hdl_template==bsg_unconcentrate_static"] true


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

puts "BSG-info: Completed script [info script]\n"
