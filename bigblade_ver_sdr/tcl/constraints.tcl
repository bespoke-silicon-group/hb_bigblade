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
constraint_input_ports  $core_clk_name $core_link_rev_data_in_ports    930 0
constraint_input_ports  $core_clk_name $core_link_rev_valid_in_ports   870 0
constraint_output_ports $core_clk_name $core_link_rev_ready_out_ports  870 0

constraint_input_ports  $core_clk_name $core_link_fwd_data_in_ports    930 0
constraint_input_ports  $core_clk_name $core_link_fwd_valid_in_ports   850 0
constraint_output_ports $core_clk_name $core_link_fwd_ready_out_ports  880 0

# output constraints
constraint_output_ports $core_clk_name $core_link_rev_data_out_ports   550 0
constraint_output_ports $core_clk_name $core_link_rev_valid_out_ports  690 0
constraint_input_ports  $core_clk_name $core_link_rev_ready_in_ports   790 0

constraint_output_ports $core_clk_name $core_link_fwd_data_out_ports   590 0
constraint_output_ports $core_clk_name $core_link_fwd_valid_out_ports  750 0
constraint_input_ports  $core_clk_name $core_link_fwd_ready_in_ports   840 0


# false path
set_false_path -from [get_ports async_*_reset_i]
set_false_path -to   [get_ports async_*_reset_o]


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

