puts "BSG-info: Running script [info script]\n"

########################################
## Source common scripts
source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/bsg_chip_misc.tcl
source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_design_constants.tcl
source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/bsg_async.constraints.tcl
source -echo -verbose $::env(BASEJUMP_STL_DIR)/hard/gf_14/bsg_link/tcl/bsg_link_ddr.constraints.tcl


########################################
## App Var Setup
# Needed for CDC multiple clock path constraints
set_app_var timing_enable_multiple_clocks_per_reg true
# Needed for automatic clock-gate insertions
set_app_var case_analysis_propagate_through_icg true
########################################

set_driving_cell -no_design_rule -lib_cell "IN12LP_GPIO18_13M9S30P_IO_H" -pin Y [all_inputs]
set_load [load_of [get_lib_pin "*/IN12LP_GPIO18_13M9S30P_IO_H/DATA"]] [all_outputs]

set tag_clk_name           "tag_clk"
set tag_clk_period_ps      10000.0 ;# 100 MHz
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


# tag constraints
set tag_in_ports [get_ports {tag_data_i tag_en_i}]
set_input_delay [expr $tag_clk_period_ps/2] -clock $tag_clk_name -source_latency_included -network_latency_included $tag_in_ports


# false path
set_false_path -from [get_ports async_output_disable_i]


# Source-sync link constraints
set io_clk_period_ps          800.0 ;# 1.25 GHz
set io_clk_uncertainty_ps     20
set link_clk_period_ps        [expr $io_clk_period_ps*2.0]
set link_clk_uncertainty_ps   20
set max_io_output_margin_ps   380
set max_io_input_margin_ps    380

for {set i 0} {$i < 8} {incr i} {
  for {set j 0} {$j < 2} {incr j} {
    set io_clk_name   "io_link_${i}_${j}_io_clk"
    create_clock -period $io_clk_period_ps -name $io_clk_name [get_pins "mem_link*${i}*link/io_link_${j}_io_clk"]
    set_clock_uncertainty $io_clk_uncertainty_ps  [get_clocks $io_clk_name]

    bsg_link_ddr_constraints                                      \
      $io_clk_name                                                \
      "io_link_${i}_${j}_out_clk"                                 \
      $link_clk_period_ps                                         \
      $max_io_output_margin_ps                                    \
      [get_ports "io_link_clk_o[$i][$j]"]                         \
      [get_ports "io_link_data_o[$i][$j][*] io_link_v_o[$i][$j]"] \
      "io_link_${i}_${j}_in_clk"                                  \
      $link_clk_period_ps                                         \
      $max_io_input_margin_ps                                     \
      [get_ports "io_link_clk_i[$i][$j]"]                         \
      [get_ports "io_link_data_i[$i][$j][*] io_link_v_i[$i][$j]"] \
      "io_link_${i}_${j}_tkn_clk"                                 \
      [get_ports "io_link_token_i[$i][$j]"]                       \
      $link_clk_uncertainty_ps
  }
}

# CDC
set cdc_clocks [all_clocks]
bsg_async_icl $cdc_clocks


# ungroup


# Derate
bsg_chip_derate_cells
bsg_chip_derate_mems
#report_timing_derate

# Disabled or false paths


puts "BSG-info: Completed script [info script]\n"

