puts "BSG-info: Running script [info script]\n"

########################################
## Source common scripts
source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/bsg_chip_misc.tcl
source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_design_constants.tcl
source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/bsg_async.constraints.tcl
source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/bsg_clk_gen.constraints.tcl
source -echo -verbose $::env(BASEJUMP_STL_DIR)/hard/gf_14/bsg_link/tcl/bsg_link_ddr.constraints.tcl


########################################
## App Var Setup
# Needed for CDC multiple clock path constraints
set_app_var timing_enable_multiple_clocks_per_reg true
# Needed for automatic clock-gate insertions
set_app_var case_analysis_propagate_through_icg true
########################################


set core_clk_name           "core_clk"
set core_clk_period_ps      800.0 ;# 1.25 GHz
set core_clk_uncertainty_ps 20
create_clock -period $core_clk_period_ps -name $core_clk_name [get_ports core_clk_i]
set_clock_uncertainty $core_clk_uncertainty_ps  [get_clocks $core_clk_name]

set tag_clk_name           "tag_clk"
set tag_clk_period_ps      5000.0 ;# 200 MHz
set tag_clk_uncertainty_ps 20
create_clock -period $tag_clk_period_ps -name $tag_clk_name [get_ports tag_clk_i]
set_clock_uncertainty $tag_clk_uncertainty_ps  [get_clocks $tag_clk_name]

set io_clk_name           "io_clk"
set io_clk_period_ps      800.0 ;# 1.25 GHz
set io_clk_uncertainty_ps 20
set osc_period_ps         250.0 ;# Raw oscillator frequency
set osc_uncertainty_ps    20
set ds_uncertainty_ps     20
bsg_clk_gen_clock_create clk_gen/clk_gen_inst/ ${io_clk_name} ${osc_period_ps} ${io_clk_period_ps} ${osc_uncertainty_ps} ${ds_uncertainty_ps} ${io_clk_uncertainty_ps}

set ext_clk_name           "ext_clk"
create_clock -period $osc_period_ps -name $ext_clk_name [get_ports ext_clk_i]
set_clock_uncertainty $osc_uncertainty_ps  [get_clocks $ext_clk_name]


# grouping ports...
set core_valid_in_ports        [get_ports core_v_i]
set core_data_in_ports         [get_ports core_data_i]
set core_ready_and_out_ports   [get_ports core_ready_and_o]
set core_valid_out_ports       [get_ports core_v_o]
set core_data_out_ports        [get_ports core_data_o]
set core_yumi_in_ports         [get_ports core_yumi_i]
set tag_in_ports               [get_ports {tag_*_tag_lines_i[1] tag_*_tag_lines_i[2]}]


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

constraint_input_ports  $core_clk_name   $core_valid_in_ports        [expr $core_clk_period_ps-125]   -5
constraint_input_ports  $core_clk_name   $core_data_in_ports         [expr $core_clk_period_ps-120]   25
constraint_output_ports $core_clk_name   $core_ready_and_out_ports   [expr $core_clk_period_ps-150]  -25

constraint_output_ports $core_clk_name   $core_valid_out_ports       [expr $core_clk_period_ps-105]  -10
constraint_output_ports $core_clk_name   $core_data_out_ports        [expr $core_clk_period_ps-125]  -10
constraint_input_ports  $core_clk_name   $core_yumi_in_ports         [expr $core_clk_period_ps-100]   25

constraint_input_ports  $tag_clk_name    $tag_in_ports              4900   30

# false path
set_false_path -from [get_ports async_output_disable_i]
set_false_path -from [get_ports {tag_*_tag_lines_i[0] tag_*_tag_lines_i[3]}]


# Source-sync link constraints
set link_clk_period_ps        [expr $io_clk_period_ps*2.0]
set link_clk_uncertainty_ps   20
set max_io_output_margin_ps   80
set max_io_input_margin_ps    80

bsg_link_ddr_constraints                    \
  $io_clk_name                              \
  "link_out_clk"                            \
  $link_clk_period_ps                       \
  $max_io_output_margin_ps                  \
  [get_ports io_link_clk_o]                 \
  [get_ports {io_link_data_o io_link_v_o}]  \
  "link_in_clk"                             \
  $link_clk_period_ps                       \
  $max_io_input_margin_ps                   \
  [get_ports io_link_clk_i]                 \
  [get_ports {io_link_data_i io_link_v_i}]  \
  "link_tkn_clk"                            \
  [get_ports io_link_token_i]               \
  $link_clk_uncertainty_ps


# CDC
set cdc_clocks [all_clocks]
bsg_async_icl $cdc_clocks


# ungroup


# Derate
bsg_chip_derate_cells
bsg_chip_derate_mems
#report_timing_derate

# Disabled or false paths
bsg_chip_disable_1r1w_paths {"*downstream/harden*fifo/*"}
set_min_delay [expr -$osc_uncertainty_ps] -from ${io_clk_name}_osc_ds -to ${io_clk_name}_osc -ignore_clock_latency
set_min_delay [expr -$osc_uncertainty_ps] -from ${tag_clk_name} -to ${io_clk_name}_osc -ignore_clock_latency

puts "BSG-info: Completed script [info script]\n"

