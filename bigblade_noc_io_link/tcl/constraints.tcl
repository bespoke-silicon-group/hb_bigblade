puts "BSG-info: Running script [info script]\n"

########################################
## Source common scripts
source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/bsg_chip_misc.tcl
source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_design_constants.tcl
source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/bsg_async.constraints.tcl
source -echo -verbose $::env(BASEJUMP_STL_DIR)/hard/gf_14/bsg_link/tcl/bsg_link_sdr.constraints.tcl
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
create_clock -period $core_clk_period_ps -name $core_clk_name [get_pins ddr_link*0*link/noc_clk_o]
set_clock_uncertainty $core_clk_uncertainty_ps  [get_clocks $core_clk_name]

set tag_clk_name           "tag_clk"
set tag_clk_period_ps      5000.0 ;# 200 MHz
set tag_clk_uncertainty_ps 20
create_clock -period $tag_clk_period_ps -name $tag_clk_name [get_ports tag_clk_i]
set_clock_uncertainty $tag_clk_uncertainty_ps  [get_clocks $tag_clk_name]

set osc_period_ps         250.0 ;# Raw oscillator frequency
set osc_uncertainty_ps    20
set ds_uncertainty_ps     20

set ext_io_clk_name           "ext_io_clk"
create_clock -period $osc_period_ps -name $ext_io_clk_name [get_ports ext_io_clk_i]
set_clock_uncertainty $osc_uncertainty_ps  [get_clocks $ext_io_clk_name]

set ext_noc_clk_name           "ext_noc_clk"
create_clock -period $osc_period_ps -name $ext_noc_clk_name [get_ports ext_noc_clk_i]
set_clock_uncertainty $osc_uncertainty_ps  [get_clocks $ext_noc_clk_name]


# grouping ports...
set tag_in_ports        [get_ports tag_data_i]

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

constraint_input_ports  $tag_clk_name    $tag_in_ports     4000   100

# false path
set_false_path -from [get_ports async_output_disable_i]
set_false_path -from [get_ports tag_node_id_offset_i]


# Source-sync link constraints
set link_clk_period_ps        800
set link_clk_uncertainty_ps   20
set max_io_output_margin_ps   100
set max_io_input_margin_ps    100

foreach type {"fwd" "rev"} {
  bsg_link_sdr_constraints                                      \
    $core_clk_name                                              \
    [get_attribute [get_clocks $core_clk_name] sources]         \
    "mc_${type}_out_clk"                                        \
    $core_clk_period_ps                                         \
    $max_io_output_margin_ps                                    \
    [get_ports "mc_${type}_link_clk_o"]                         \
    [get_ports "mc_${type}_link_data_o[*] mc_${type}_link_v_o"] \
    "mc_${type}_in_clk"                                         \
    $link_clk_period_ps                                         \
    $max_io_input_margin_ps                                     \
    [get_ports "mc_${type}_link_clk_i"]                         \
    [get_ports "mc_${type}_link_data_i[*] mc_${type}_link_v_i"] \
    "mc_${type}_tkn_clk"                                        \
    [get_ports "mc_${type}_link_token_i"]                       \
    $link_clk_uncertainty_ps
}

# disable timing arcs
bsg_link_sdr_disable_timing_constraints

# set dont touch
bsg_link_sdr_dont_touch_constraints [get_ports { \
    mc_*_link_data_i[*] mc_*_link_v_i            \
}]


# Source-sync link constraints
set io_clk_period_ps              800.0 ;# 1.25 GHz
set io_clk_uncertainty_ps         20
set ddr_link_clk_period_ps        [expr $io_clk_period_ps*2.0]
set ddr_link_clk_uncertainty_ps   20
set ddr_max_io_output_margin_ps   100
set ddr_max_io_input_margin_ps    100

for {set i 0} {$i < 2} {incr i} {
  set io_clk_name   "io_link_${i}_io_clk"
  create_clock -period $io_clk_period_ps -name $io_clk_name [get_pins "ddr_link*${i}*link/io_clk"]
  set_clock_uncertainty $io_clk_uncertainty_ps  [get_clocks $io_clk_name]

  bsg_link_ddr_constraints                              \
    $io_clk_name                                        \
    "io_link_${i}_out_clk"                              \
    $ddr_link_clk_period_ps                             \
    $ddr_max_io_output_margin_ps                        \
    [get_ports "io_link_clk_o[$i]"]                     \
    [get_ports "io_link_data_o[$i][*] io_link_v_o[$i]"] \
    "io_link_${i}_in_clk"                               \
    $ddr_link_clk_period_ps                             \
    $ddr_max_io_input_margin_ps                         \
    [get_ports "io_link_clk_i[$i]"]                     \
    [get_ports "io_link_data_i[$i][*] io_link_v_i[$i]"] \
    "io_link_${i}_tkn_clk"                              \
    [get_ports "io_link_token_i[$i]"]                   \
    $ddr_link_clk_uncertainty_ps
}

# exclude delay cells and sel signals from timing analysis
#set_disable_timing [get_flat_cells -filter "full_name=~*delay/sig*dly*_BSG_DONT_TOUCH"]
#set_false_path -through [get_flat_pins -filter "full_name=~*delay/sig*mux_BSG_DONT_TOUCH/S*"]
set_case_analysis 0 [get_flat_pins -filter "full_name=~*delay/sig*mux_BSG_DONT_TOUCH/S*"]

# set dont touch on all delay lines
set_dont_touch_network [get_pins "ddr_link*link/io_link_clk_o*"]
set_dont_touch_network [get_pins "ddr_link*link/io_link_v_o*"]
set_dont_touch_network [get_pins "ddr_link*link/io_link_data_o*"]
set_dont_touch_network [get_ports "io_link_clk_i*"]
set_dont_touch_network [get_ports "io_link_v_i*"]
set_dont_touch_network [get_ports "io_link_data_i*"]


# CDC
set cdc_clocks [all_clocks]
bsg_async_icl $cdc_clocks


# ungroup


# Derate
bsg_chip_derate_cells
bsg_chip_derate_mems
#report_timing_derate

# Disabled or false paths
bsg_chip_disable_1r1w_paths {"tunnel/*buff*fifo/harden*fifo/*"}

puts "BSG-info: Completed script [info script]\n"

