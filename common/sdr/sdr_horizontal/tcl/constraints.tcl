puts "BSG-info: Running script [info script]\n"

########################################
## Source common scripts
source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/bsg_chip_misc.tcl
source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_design_constants.tcl
source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/bsg_async.constraints.tcl
source -echo -verbose $::env(BASEJUMP_STL_DIR)/hard/gf_14/bsg_link/tcl/bsg_link_sdr.constraints.tcl


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
  constraint_input_ports $core_clk_name   $ver_rev_data_in_ports($i)     930 0
  constraint_input_ports $core_clk_name   $ver_rev_valid_in_ports($i)    850 0
  constraint_output_ports $core_clk_name  $ver_rev_ready_out_ports($i)   870 0

  constraint_input_ports $core_clk_name   $ver_fwd_data_in_ports($i)     930 0
  constraint_input_ports $core_clk_name   $ver_fwd_valid_in_ports($i)    840 0
  constraint_output_ports $core_clk_name  $ver_fwd_ready_out_ports($i)   880 0
}

# hor link
constraint_input_ports $core_clk_name   $hor_rev_data_in_ports          930 0
constraint_input_ports $core_clk_name   $hor_rev_valid_in_ports         870 0
constraint_output_ports $core_clk_name  $hor_rev_ready_out_ports        870 0

constraint_input_ports $core_clk_name   $hor_fwd_data_in_ports          930 0
constraint_input_ports $core_clk_name   $hor_fwd_valid_in_ports         850 0
constraint_output_ports $core_clk_name  $hor_fwd_ready_out_ports        880 0

# ruche link
constraint_input_ports $core_clk_name   $ruche_rev_data_in_ports        930 0
constraint_input_ports $core_clk_name   $ruche_rev_valid_in_ports       840 0
constraint_output_ports $core_clk_name  $ruche_rev_ready_out_ports      870 0

constraint_input_ports $core_clk_name   $ruche_fwd_data_in_ports        900 0
constraint_input_ports $core_clk_name   $ruche_fwd_valid_in_ports       800 0
constraint_output_ports $core_clk_name  $ruche_fwd_ready_out_ports      820 0

# router output constraints
# N/S ver link
for {set i 0} {$i <= 1} {incr i} {
  constraint_output_ports $core_clk_name $ver_rev_data_out_ports($i)   510 0
  constraint_output_ports $core_clk_name $ver_rev_valid_out_ports($i)  680 0
  constraint_input_ports  $core_clk_name $ver_rev_ready_in_ports($i)   750 0

  constraint_output_ports $core_clk_name $ver_fwd_data_out_ports($i)   520 0
  constraint_output_ports $core_clk_name $ver_fwd_valid_out_ports($i)  680 0
  constraint_input_ports  $core_clk_name $ver_fwd_ready_in_ports($i)   750 0
}

# hor link
constraint_output_ports $core_clk_name $hor_rev_data_out_ports   550 0
constraint_output_ports $core_clk_name $hor_rev_valid_out_ports  690 0
constraint_input_ports  $core_clk_name $hor_rev_ready_in_ports   790 0

constraint_output_ports $core_clk_name $hor_fwd_data_out_ports   590 0
constraint_output_ports $core_clk_name $hor_fwd_valid_out_ports  750 0
constraint_input_ports  $core_clk_name $hor_fwd_ready_in_ports   840 0

# ruche link
constraint_output_ports $core_clk_name $ruche_rev_data_out_ports   550 0
constraint_output_ports $core_clk_name $ruche_rev_valid_out_ports  900 0
constraint_input_ports  $core_clk_name $ruche_rev_ready_in_ports   510 0

constraint_output_ports $core_clk_name $ruche_fwd_data_out_ports   560 0
constraint_output_ports $core_clk_name $ruche_fwd_valid_out_ports  760 0
constraint_input_ports  $core_clk_name $ruche_fwd_ready_in_ports   830 0

# core reset
constraint_input_ports  $core_clk_name [get_ports core_reset_i]       700 -50
constraint_output_ports $core_clk_name [get_ports core_reset_o]       500 -200
constraint_input_ports  $core_clk_name [get_ports core_global_*_i*]   40 40
constraint_output_ports $core_clk_name [get_ports core_global_*_o*]   40 40

# global coordinates
# The timing paths to/from these registers don't need a single-cycle requirement, 
# so relax the constraints by allowing double cycle.
# The hold cycle is set to 2, so that it becomes much easier to meet hold check.
set multicycle_cells [list]
append_to_collection multicycle_cells [get_cells dff_global_x/data_r_reg*]
append_to_collection multicycle_cells [get_cells dff_global_y/data_r_reg*]
set_multicycle_path 2 -setup -to   $multicycle_cells
set_multicycle_path 2 -hold  -to   $multicycle_cells
set_multicycle_path 2 -setup -from $multicycle_cells
set_multicycle_path 2 -hold  -from $multicycle_cells


# false path
set_false_path -from [get_ports async_*_reset_i]
set_false_path -to   [get_ports async_*_reset_o]
set_false_path -from [get_ports async_*_disable_i]


# Source-sync link constraints
set link_clk_period_ps        1000
set link_clk_uncertainty_ps   20
set max_io_output_margin_ps   100
set max_io_input_margin_ps    100

bsg_link_sdr_constraints                           \
  $core_clk_name                                   \
  [get_ports core_clk_i]                           \
  "fwd_out_clk"                                    \
  $core_clk_period_ps                              \
  $max_io_output_margin_ps                         \
  [get_ports io_fwd_link_clk_o]                    \
  [get_ports {io_fwd_link_data_o io_fwd_link_v_o}] \
  "fwd_in_clk"                                     \
  $link_clk_period_ps                              \
  $max_io_input_margin_ps                          \
  [get_ports io_fwd_link_clk_i]                    \
  [get_ports {io_fwd_link_data_i io_fwd_link_v_i}] \
  "fwd_tkn_clk"                                    \
  [get_ports io_fwd_link_token_i]                  \
  $link_clk_uncertainty_ps

bsg_link_sdr_constraints                           \
  $core_clk_name                                   \
  [get_ports core_clk_i]                           \
  "rev_out_clk"                                    \
  $core_clk_period_ps                              \
  $max_io_output_margin_ps                         \
  [get_ports io_rev_link_clk_o]                    \
  [get_ports {io_rev_link_data_o io_rev_link_v_o}] \
  "rev_in_clk"                                     \
  $link_clk_period_ps                              \
  $max_io_input_margin_ps                          \
  [get_ports io_rev_link_clk_i]                    \
  [get_ports {io_rev_link_data_i io_rev_link_v_i}] \
  "rev_tkn_clk"                                    \
  [get_ports io_rev_link_token_i]                  \
  $link_clk_uncertainty_ps

# disable timing arcs
bsg_link_sdr_disable_timing_constraints

# set dont touch
bsg_link_sdr_dont_touch_constraints [get_ports {io_*_link_data_i[*] io_*_link_v_i}]

if {$::env(EAST_NOT_WEST) == 0} {
  set_dont_touch [get_cells -hier -filter "name=~*hard_inv*"] true
  set_dont_touch [get_cells -hier -filter "name=~*hard_buf*"] true
}

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


# ungroup

set_ungroup [get_designs -filter "hdl_template==bsg_concentrate_static"] true
set_ungroup [get_designs -filter "hdl_template==bsg_array_concentrate_static"] true
set_ungroup [get_designs -filter "hdl_template==bsg_unconcentrate_static"] true
set_ungroup [get_designs -filter "hdl_template==bsg_transpose"] true

## Derate
bsg_chip_derate_cells
#bsg_chip_derate_mems
#report_timing_derate

puts "BSG-info: Completed script [info script]\n"

