puts "BSG-info: Running script [info script]\n"

########################################
## Source common scripts
source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/bsg_chip_misc.tcl
source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_design_constants.tcl
source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/bsg_async.constraints.tcl


########################################
## App Var Setup
# Needed for CDC multiple clock path constraints
set_app_var timing_enable_multiple_clocks_per_reg true
# Needed for automatic clock-gate insertions
set_app_var case_analysis_propagate_through_icg true
########################################


# manycore interface
set core_clk_name           "manycore_clk"
set core_clk_period_ps      1000
set core_clk_uncertainty_ps 20

create_clock -period $core_clk_period_ps -name $core_clk_name [get_ports core_clk_i]
set_clock_uncertainty $core_clk_uncertainty_ps  [get_clocks $core_clk_name]


# grouping ports...
set core_reset_in_port  [get_ports core_reset_i]
set ver_input_ports   [list]
set ver_output_ports  [list]
set hor_input_ports   [list]
set hor_output_ports  [list]
set ruche_input_ports   [list]
set ruche_output_ports  [list]

for {set i 3} {$i <= 4} {incr i} {
  for {set j 0} {$j < $HB_LINK_WIDTH_P} {incr j} {
    append_to_collection ver_input_ports  [get_ports "core_ver_link_sif_i[$i][$j]"]
    append_to_collection ver_output_ports [get_ports "core_ver_link_sif_o[$i][$j]"]
  }
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
  constraint_input_ports $core_clk_name   $ver_rev_data_in_ports($i)     500 0
  constraint_input_ports $core_clk_name   $ver_rev_valid_in_ports($i)    500 0
  constraint_output_ports $core_clk_name  $ver_rev_ready_out_ports($i)  500 0

  constraint_input_ports $core_clk_name   $ver_fwd_data_in_ports($i)     500 0
  constraint_input_ports $core_clk_name   $ver_fwd_valid_in_ports($i)    500 0
  constraint_output_ports $core_clk_name  $ver_fwd_ready_out_ports($i)  500 0
}

# hor link
constraint_input_ports $core_clk_name   $hor_rev_data_in_ports     500 0
constraint_input_ports $core_clk_name   $hor_rev_valid_in_ports    500 0
constraint_output_ports $core_clk_name  $hor_rev_ready_out_ports  500 0

constraint_input_ports $core_clk_name   $hor_fwd_data_in_ports     500 0
constraint_input_ports $core_clk_name   $hor_fwd_valid_in_ports    500 0
constraint_output_ports $core_clk_name  $hor_fwd_ready_out_ports  500 0

# ruche link
constraint_input_ports $core_clk_name   $ruche_rev_data_in_ports     500 0
constraint_input_ports $core_clk_name   $ruche_rev_valid_in_ports    500 0
constraint_output_ports $core_clk_name  $ruche_rev_ready_out_ports  500 0

constraint_input_ports $core_clk_name   $ruche_fwd_data_in_ports     500 0
constraint_input_ports $core_clk_name   $ruche_fwd_valid_in_ports    500 0
constraint_output_ports $core_clk_name  $ruche_fwd_ready_out_ports   500 0

# router output constraints
# N/S ver link
for {set i 0} {$i <= 1} {incr i} {
  constraint_output_ports $core_clk_name $ver_rev_data_out_ports($i)   500 0
  constraint_output_ports $core_clk_name $ver_rev_valid_out_ports($i)  500 0
  constraint_input_ports  $core_clk_name $ver_rev_ready_in_ports($i)   500 0

  constraint_output_ports $core_clk_name $ver_fwd_data_out_ports($i)   500 0
  constraint_output_ports $core_clk_name $ver_fwd_valid_out_ports($i)  500 0
  constraint_input_ports  $core_clk_name $ver_fwd_ready_in_ports($i)   500 0
}

# hor link
constraint_output_ports $core_clk_name $hor_rev_data_out_ports   500 0
constraint_output_ports $core_clk_name $hor_rev_valid_out_ports  500 0
constraint_input_ports  $core_clk_name $hor_rev_ready_in_ports   500 0

constraint_output_ports $core_clk_name $hor_fwd_data_out_ports   500 0
constraint_output_ports $core_clk_name $hor_fwd_valid_out_ports  500 0
constraint_input_ports  $core_clk_name $hor_fwd_ready_in_ports   500 0

# ruche link
constraint_output_ports $core_clk_name $ruche_rev_data_out_ports   500 0
constraint_output_ports $core_clk_name $ruche_rev_valid_out_ports  500 0
constraint_input_ports  $core_clk_name $ruche_rev_ready_in_ports   500 0

constraint_output_ports $core_clk_name $ruche_fwd_data_out_ports   500 0
constraint_output_ports $core_clk_name $ruche_fwd_valid_out_ports  500 0
constraint_input_ports  $core_clk_name $ruche_fwd_ready_in_ports   500 0


# core reset
constraint_input_ports $core_clk_name $core_reset_in_port 500 0


# false path
set_false_path -from [get_ports core_global_*_i]
set_false_path -from [get_ports async_*_reset_i]
set_false_path -to   [get_ports async_*_reset_o]


# Source-sync link constraints
set link_clk_period_ps        1000
set link_clk_uncertainty_ps   20

set token_clk_period_ps       [expr 2*$link_clk_period_ps]
set token_clk_uncertainty_ps  20

set max_io_skew_ps            50
set io_max_output_delay       [expr ($core_clk_period_ps/2)-$max_io_skew_ps]
set io_min_output_delay       [expr $max_io_skew_ps-($core_clk_period_ps/2)]
set io_max_input_delay        [expr ($link_clk_period_ps)-$max_io_skew_ps]
set io_min_input_delay        [expr $max_io_skew_ps]

# upstream (fwd)
create_generated_clock -divide_by 1 -invert -master_clock $core_clk_name -source [get_ports core_clk_i] -name "fwd_out_clk" [get_ports io_fwd_link_clk_o]
constraint_output_ports "fwd_out_clk" [get_ports io_fwd_link_data_o]  $io_max_output_delay $io_min_output_delay
constraint_output_ports "fwd_out_clk" [get_ports io_fwd_link_v_o]     $io_max_output_delay $io_min_output_delay
create_clock -period $token_clk_period_ps -name "fwd_tkn_clk" [get_ports io_fwd_link_token_i]
set_clock_uncertainty $token_clk_uncertainty_ps [get_clock "fwd_tkn_clk"]

# upstream (rev)
create_generated_clock -divide_by 1 -invert -master_clock $core_clk_name -source [get_ports core_clk_i] -name "rev_out_clk" [get_ports io_rev_link_clk_o]
constraint_output_ports "rev_out_clk" [get_ports io_rev_link_data_o]  $io_max_output_delay $io_min_output_delay
constraint_output_ports "rev_out_clk" [get_ports io_rev_link_v_o]     $io_max_output_delay $io_min_output_delay
create_clock -period $token_clk_period_ps -name "rev_tkn_clk" [get_ports io_rev_link_token_i]
set_clock_uncertainty $token_clk_uncertainty_ps [get_clock "rev_tkn_clk"]

# downstream (fwd)
create_clock -period $link_clk_period_ps -name "fwd_in_clk" [get_ports io_fwd_link_clk_i]
set_clock_uncertainty $link_clk_uncertainty_ps [get_clock "fwd_in_clk"]
constraint_input_ports "fwd_in_clk" [get_ports io_fwd_link_data_i] $io_max_input_delay $io_min_input_delay
constraint_input_ports "fwd_in_clk" [get_ports io_fwd_link_v_i]    $io_max_input_delay $io_min_input_delay

# downstream (rev)
create_clock -period $link_clk_period_ps -name "rev_in_clk" [get_ports io_rev_link_clk_i]
set_clock_uncertainty $link_clk_uncertainty_ps [get_clock "rev_in_clk"]
constraint_input_ports "rev_in_clk" [get_ports io_rev_link_data_i] $io_max_input_delay $io_min_input_delay
constraint_input_ports "rev_in_clk" [get_ports io_rev_link_v_i]    $io_max_input_delay $io_min_input_delay



# CDC
set cdc_clocks [list]
append_to_collection cdc_clocks [get_clocks "fwd_in_clk"]
append_to_collection cdc_clocks [get_clocks $core_clk_name]
bsg_async_icl $cdc_clocks

set cdc_clocks [list]
append_to_collection cdc_clocks [get_clocks "rev_in_clk"]
append_to_collection cdc_clocks [get_clocks $core_clk_name]
bsg_async_icl $cdc_clocks

set cdc_clocks [list]
append_to_collection cdc_clocks [get_clocks "fwd_tkn_clk"]
append_to_collection cdc_clocks [get_clocks $core_clk_name]
bsg_async_icl $cdc_clocks

set cdc_clocks [list]
append_to_collection cdc_clocks [get_clocks "rev_tkn_clk"]
append_to_collection cdc_clocks [get_clocks $core_clk_name]
bsg_async_icl $cdc_clocks


## Derate
bsg_chip_derate_cells
#bsg_chip_derate_mems
#report_timing_derate

puts "BSG-info: Completed script [info script]\n"

