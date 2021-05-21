puts "BSG-info: Running script [info script]\n"

########################################
## Source common scripts
source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/bsg_chip_misc.tcl
source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_design_constants.tcl
source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/bsg_async.constraints.tcl


set BSG_LINK_DDR_USE_GENERATED_CLOCK 1

proc bsg_link_ddr_in_constraints {clk_name ports max_delay min_delay} {
  set_input_delay -max $max_delay -clock $clk_name -source_latency_included -network_latency_included $ports
  set_input_delay -max $max_delay -clock $clk_name -source_latency_included -network_latency_included $ports -add_delay -clock_fall
  set_input_delay -min $min_delay -clock $clk_name -source_latency_included -network_latency_included $ports
  set_input_delay -min $min_delay -clock $clk_name -source_latency_included -network_latency_included $ports -add_delay -clock_fall
}

proc bsg_link_ddr_out_constraints {clk_port ports setup_time hold_time} {
  foreach_in_collection obj $ports {
    set_data_check -from $clk_port -to $obj -setup $setup_time
    set_data_check -from $clk_port -to $obj -hold  $hold_time
    set_multicycle_path -end   -setup 1 -to $obj
    set_multicycle_path -start -hold  0 -to $obj
  }
}

proc bsg_link_ddr_out_generated_clock_constraints {clk_name ports max_delay min_delay} {
  set_output_delay -max $max_delay -clock $clk_name $ports
  set_output_delay -max $max_delay -clock $clk_name $ports -add_delay -clock_fall
  set_output_delay -min $min_delay -clock $clk_name $ports
  set_output_delay -min $min_delay -clock $clk_name $ports -add_delay -clock_fall
}

proc bsg_link_ddr_constraints { \
  master_clk_name               \
  out_clk_name                  \
  out_clk_period                \
  out_clk_margin                \
  out_clk_port                  \
  out_dv_port                   \
  in_clk_name                   \
  in_clk_period                 \
  in_clk_margin                 \
  in_clk_port                   \
  in_dv_port                    \
  tkn_clk_name                  \
  tkn_clk_port                  \
  uncertainty                   \
} {
  # token
  set tkn_clk_period         [expr $in_clk_period]
  create_clock -period $tkn_clk_period -name $tkn_clk_name $tkn_clk_port
  set_clock_uncertainty $uncertainty [get_clocks $tkn_clk_name]

  # input
  set max_input_delay        [expr ($in_clk_period/2.0)-$in_clk_margin]
  set min_input_delay        [expr $in_clk_margin]
  create_clock -period $in_clk_period -name $in_clk_name $in_clk_port
  set_clock_uncertainty $uncertainty [get_clocks $in_clk_name]
  bsg_link_ddr_in_constraints $in_clk_name $in_dv_port $max_input_delay $min_input_delay
  set_driving_cell -no_design_rule -lib_cell "IN12LP_GPIO18_13M9S30P_IO_H" -pin Y $in_clk_port
  set_driving_cell -no_design_rule -lib_cell "IN12LP_GPIO18_13M9S30P_IO_H" -pin Y $in_dv_port

  # output
  global BSG_LINK_DDR_USE_GENERATED_CLOCK
  puts "BSG_LINK_DDR_USE_GENERATED_CLOCK = $BSG_LINK_DDR_USE_GENERATED_CLOCK"
  if {$BSG_LINK_DDR_USE_GENERATED_CLOCK == 0} {
    set setup_time_output      [expr ($out_clk_period/4.0)-$out_clk_margin]
    set hold_time_output       [expr ($out_clk_period/4.0)-$out_clk_margin]
    bsg_link_ddr_out_constraints $out_clk_port $out_dv_port $setup_time_output $hold_time_output
  } else {
    set max_output_delay       [expr ($out_clk_period/4.0)-$out_clk_margin]
    set min_output_delay       [expr $out_clk_margin-($out_clk_period/4.0)]
    create_generated_clock -edges {2 4 6} -master_clock $master_clk_name -source [get_attribute [get_clocks $master_clk_name] sources] -name $out_clk_name $out_clk_port
    bsg_link_ddr_out_generated_clock_constraints $out_clk_name $out_dv_port $max_output_delay $min_output_delay
  }
  set_load [load_of [get_lib_pin "*/IN12LP_GPIO18_13M9S30P_IO_H/DATA"]] $out_clk_port
  set_load [load_of [get_lib_pin "*/IN12LP_GPIO18_13M9S30P_IO_H/DATA"]] $out_dv_port
}



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
create_clock -period $tag_clk_period_ps -name $tag_clk_name [get_ports pad_ML0_0_i_int]
set_clock_uncertainty $tag_clk_uncertainty_ps  [get_clocks $tag_clk_name]

set osc_period_ps         250.0 ;# Raw oscillator frequency
set osc_uncertainty_ps    20
set ds_uncertainty_ps     20

set ext_io_clk_name           "ext_io_clk"
create_clock -period $osc_period_ps -name $ext_io_clk_name [get_ports pad_CT0_0_i_int]
set_clock_uncertainty $osc_uncertainty_ps  [get_clocks $ext_io_clk_name]

set ext_noc_clk_name           "ext_noc_clk"
create_clock -period $osc_period_ps -name $ext_noc_clk_name [get_ports pad_CT0_1_i_int]
set_clock_uncertainty $osc_uncertainty_ps  [get_clocks $ext_noc_clk_name]


# tag constraints
set tag_in_ports [get_ports {pad_ML0_1_i_int pad_ML0_2_i_int}]
set_input_delay [expr $tag_clk_period_ps/2] -clock $tag_clk_name -source_latency_included -network_latency_included $tag_in_ports


# false path
set_false_path -from [get_ports pad_CT0_v_i_int]


# Source-sync link constraints
set io_clk_period_ps          800.0 ;# 1.25 GHz
set io_clk_uncertainty_ps     20

set link_clk_period_ps        [expr $io_clk_period_ps*2.0]
set link_clk_uncertainty_ps   20
set max_io_output_margin_ps   380
set max_io_input_margin_ps    380

for {set i 0} {$i < 8} {incr i} {
  for {set j 0} {$j < 2} {incr j} {
    set io_clk_name   "mem_link_${i}_${j}_io_clk"
    create_clock -period $io_clk_period_ps -name $io_clk_name [get_pins "mem_link*${i}*link/io_link_${j}_io_clk"]
    set_clock_uncertainty $io_clk_uncertainty_ps  [get_clocks $io_clk_name]

    set side [expr {$i < 4} ? {"DL"} : {"DR"}]
    set num  [expr ($i % 4) * 2 + $j]
    set loc  "pad_${side}${num}"

    set in_dv  [list]
    set out_dv [list]

                                      append_to_collection out_dv [get_ports "${loc}_v_o_int"]
    for {set k 0} {$k < 16} {incr k} {append_to_collection out_dv [get_ports "${loc}_${k}_o_int"]}

                                      append_to_collection in_dv [get_ports "${loc}_v_i_int"]
    for {set k 0} {$k < 16} {incr k} {append_to_collection in_dv [get_ports "${loc}_${k}_i_int"]}

    bsg_link_ddr_constraints            \
      $io_clk_name                      \
      "mem_link_${i}_${j}_out_clk"      \
      $link_clk_period_ps               \
      $max_io_output_margin_ps          \
      [get_ports "${loc}_clk_o_int"]    \
      $out_dv                           \
      "mem_link_${i}_${j}_in_clk"       \
      $link_clk_period_ps               \
      $max_io_input_margin_ps           \
      [get_ports "${loc}_clk_i_int"]    \
      $in_dv                            \
      "mem_link_${i}_${j}_tkn_clk"      \
      [get_ports "${loc}_tkn_i_int"]    \
      $link_clk_uncertainty_ps

  }
}


  for {set j 0} {$j < 2} {incr j} {
    set io_clk_name   "io_link_${j}_io_clk"
    create_clock -period $io_clk_period_ps -name $io_clk_name [get_pins "io_link/io_link_${j}_io_clk"]
    set_clock_uncertainty $io_clk_uncertainty_ps  [get_clocks $io_clk_name]

    set side "IT"
    set num  $j
    set loc  "pad_${side}${num}"

    set in_dv  [list]
    set out_dv [list]

                                      append_to_collection out_dv [get_ports "${loc}_v_o_int"]
    for {set k 0} {$k < 16} {incr k} {append_to_collection out_dv [get_ports "${loc}_${k}_o_int"]}

                                      append_to_collection in_dv [get_ports "${loc}_v_i_int"]
    for {set k 0} {$k < 16} {incr k} {append_to_collection in_dv [get_ports "${loc}_${k}_i_int"]}

    bsg_link_ddr_constraints            \
      $io_clk_name                      \
      "io_link_${j}_out_clk"            \
      $link_clk_period_ps               \
      $max_io_output_margin_ps          \
      [get_ports "${loc}_clk_o_int"]    \
      $out_dv                           \
      "io_link_${j}_in_clk"             \
      $link_clk_period_ps               \
      $max_io_input_margin_ps           \
      [get_ports "${loc}_clk_i_int"]    \
      $in_dv                            \
      "io_link_${j}_tkn_clk"            \
      [get_ports "${loc}_tkn_i_int"]    \
      $link_clk_uncertainty_ps

  }


# CDC
set cdc_clocks [remove_from_collection [remove_from_collection [all_clocks] [get_clocks mem_link_*_*_out_clk]] [get_clocks io_link_*_out_clk]]
bsg_async_icl $cdc_clocks


# ungroup


# Derate
bsg_chip_derate_cells
bsg_chip_derate_mems
#report_timing_derate

# Disabled or false paths


puts "BSG-info: Completed script [info script]\n"
