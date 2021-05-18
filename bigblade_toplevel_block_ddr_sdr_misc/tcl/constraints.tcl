puts "BSG-info: Running script [info script]\n"

########################################
## Source common scripts
source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/bsg_chip_misc.tcl
source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_design_constants.tcl
source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/bsg_async.constraints.tcl


proc bsg_link_ddr_out_constraints {clk_name clk_port ports setup_time hold_time} {
  foreach_in_collection obj $ports {
    set_data_check -clock [get_clocks $clk_name] -from $clk_port -to $obj -setup $setup_time
    set_data_check -clock [get_clocks $clk_name] -from $clk_port -to $obj -hold  $hold_time
    set_multicycle_path -end   -setup 1 -to $obj
    set_multicycle_path -start -hold  0 -to $obj
  }
}

proc bsg_link_ddr_constraints { \
  master_out_clk_name           \
  out_clk_period                \
  out_clk_margin                \
  out_clk_port                  \
  out_dv_port                   \
  master_in_clk_name            \
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
  set setup_time_input       [expr ($in_clk_period/2.0)-$in_clk_margin]
  set hold_time_input        [expr -$in_clk_margin]
  bsg_link_ddr_out_constraints $master_in_clk_name $in_clk_port $in_dv_port $setup_time_input $hold_time_input

  # output
  set setup_time_output      [expr ($out_clk_period/4.0)-$out_clk_margin]
  set hold_time_output       [expr ($out_clk_period/4.0)-$out_clk_margin]
  bsg_link_ddr_out_constraints $master_out_clk_name $out_clk_port $out_dv_port $setup_time_output $hold_time_output
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

set ext_mc_clk_name           "ext_mc_clk"
create_clock -period 1000.0 -name $ext_mc_clk_name [get_ports pad_CT0_2_i_int]
set_clock_uncertainty 20  [get_clocks $ext_mc_clk_name]

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
set max_io_output_margin_ps   300
set max_io_input_margin_ps    300

for {set i 0} {$i < 8} {incr i} {
  for {set j 0} {$j < 2} {incr j} {
    set io_clk_name   "mem_link_${i}_${j}_io_clk"
    create_clock -period $io_clk_period_ps -name $io_clk_name [get_pins "mem_link*${i}*link/io_link_${j}_io_clk"]
    set_clock_uncertainty $io_clk_uncertainty_ps  [get_clocks $io_clk_name]

    set master_in_clk_name   "mem_link_in_${i}_${j}_io_clk"
    create_clock -period $io_clk_period_ps -name $master_in_clk_name
    set_clock_uncertainty $io_clk_uncertainty_ps  [get_clocks $master_in_clk_name]

    set side [expr {$i < 4} ? {"DL"} : {"DR"}]
    set num  [expr ($i % 4) * 2 + $j]
    set loc  "pad_${side}${num}"

    set in_dv  [list]
    set in_ports [list]
    set out_dv [list]

                                      append_to_collection out_dv [get_ports "${loc}_v_o_int"]
    for {set k 0} {$k < 16} {incr k} {append_to_collection out_dv [get_ports "${loc}_${k}_o_int"]}
    append_to_collection in_dv  [get_flat_pins -filter "full_name=~mem_link*${i}*link/io_link_v_i[$j]"]
    for {set k [expr $j*16]} {$k < [expr ($j+1)*16]} {incr k} {
      append_to_collection in_dv  [get_flat_pins -filter "full_name=~mem_link*${i}*link/io_link_data_i[$k]"]
    }

                                      append_to_collection in_ports [get_ports "${loc}_clk_i_int"]
                                      append_to_collection in_ports [get_ports "${loc}_v_i_int"]
    for {set k 0} {$k < 16} {incr k} {append_to_collection in_ports [get_ports "${loc}_${k}_i_int"]}
    set_input_delay 0 -clock [get_clocks $master_in_clk_name] $in_ports

    bsg_link_ddr_constraints              \
      $io_clk_name                        \
      $link_clk_period_ps                 \
      $max_io_output_margin_ps            \
      [get_ports "${loc}_clk_o_int"]      \
      $out_dv                             \
      $master_in_clk_name                 \
      $link_clk_period_ps                 \
      $max_io_input_margin_ps             \
      [get_flat_pins -filter "full_name=~mem_link*${i}*link/io_link_clk_i[$j]"]     \
      $in_dv                              \
      "mem_link_${i}_${j}_tkn_clk"        \
      [get_ports "${loc}_tkn_i_int"]      \
      $link_clk_uncertainty_ps

    #set_max_delay -from [get_ports "${loc}_clk_i_int"] 2000
    #set_max_delay -to   [get_ports "${loc}_clk_o_int"] 2000

  }
}

# SDR
set sdr_clocks [list]

for {set i 0} {$i < 10} {incr i} {
  set wh_master_clk_name   "wh_link_${i}_master_clk"
  create_clock -period 1000 -name $wh_master_clk_name [get_pins "wh_link*${i}*link/core_clk"]
  set_clock_uncertainty 20 [get_clocks $wh_master_clk_name]
  for {set j 0} {$j < 4} {incr j} {
    create_generated_clock \
        -divide_by 1 \
        -invert \
        -master_clock $wh_master_clk_name \
        -source [get_attribute [get_clocks $wh_master_clk_name] sources] \
        -name "wh_link_${i}_${j}_clk" \
        [get_pins "wh_link*${i}*link/io_wh_link_clk_o[${j}]"]
    append_to_collection sdr_clocks [get_clocks "wh_link_${i}_${j}_clk"]
  }
}

for {set i 0} {$i < 8} {incr i} {
  set wh_master_clk_name   "mem_link_${i}_master_clk"
  create_clock -period 1000 -name $wh_master_clk_name [get_pins "mem_link*${i}*link/core_clk"]
  set_clock_uncertainty 20 [get_clocks $wh_master_clk_name]
  for {set j 0} {$j < 4} {incr j} {
    create_generated_clock \
        -divide_by 1 \
        -invert \
        -master_clock $wh_master_clk_name \
        -source [get_attribute [get_clocks $wh_master_clk_name] sources] \
        -name "mem_link_${i}_${j}_clk" \
        [get_pins "mem_link*${i}*link/io_wh_link_clk_o[${j}]"]
    append_to_collection sdr_clocks [get_clocks "mem_link_${i}_${j}_clk"]
  }
}

  set wh_master_clk_name   "io_link_master_clk"
  create_clock -period 1000 -name $wh_master_clk_name [get_pins "io_link/core_clk"]
  set_clock_uncertainty 20 [get_clocks $wh_master_clk_name]
  foreach {j} {"fwd" "rev"} {
    create_generated_clock \
        -divide_by 1 \
        -invert \
        -master_clock $wh_master_clk_name \
        -source [get_attribute [get_clocks $wh_master_clk_name] sources] \
        -name "io_link_${j}_clk" \
        [get_pins "io_link/mc_${j}_link_clk_o"]
    append_to_collection sdr_clocks [get_clocks "io_link_${j}_clk"]
  }

  set wh_master_clk_name   "west_link_master_clk"
  create_clock -period 1000 -name $wh_master_clk_name [get_pins "west_link/core_clk_i"]
  set_clock_uncertainty 20 [get_clocks $wh_master_clk_name]
  create_generated_clock \
      -divide_by 1 \
      -invert \
      -master_clock $wh_master_clk_name \
      -source [get_attribute [get_clocks $wh_master_clk_name] sources] \
      -name "west_link_rev_clk" \
      [get_pins "west_link/io_rev_link_clk_o"]
  append_to_collection sdr_clocks [get_clocks "west_link_rev_clk"]

  set wh_master_clk_name   "north_link_master_clk"
  create_clock -period 1000 -name $wh_master_clk_name [get_pins "north_link/core_clk_i"]
  set_clock_uncertainty 20 [get_clocks $wh_master_clk_name]
  create_generated_clock \
      -divide_by 1 \
      -invert \
      -master_clock $wh_master_clk_name \
      -source [get_attribute [get_clocks $wh_master_clk_name] sources] \
      -name "north_link_fwd_clk" \
      [get_pins "north_link/io_fwd_link_clk_o"]
  append_to_collection sdr_clocks [get_clocks "north_link_fwd_clk"]

  for {set j 0} {$j < 2} {incr j} {
    set io_clk_name   "io_link_${j}_io_clk"
    create_clock -period $io_clk_period_ps -name $io_clk_name [get_pins "io_link/io_link_${j}_io_clk"]
    set_clock_uncertainty $io_clk_uncertainty_ps  [get_clocks $io_clk_name]

    set master_in_clk_name   "io_link_in_${j}_io_clk"
    create_clock -period $io_clk_period_ps -name $master_in_clk_name
    set_clock_uncertainty $io_clk_uncertainty_ps  [get_clocks $master_in_clk_name]

    set side "IT"
    set num  $j
    set loc  "pad_${side}${num}"

    set in_dv  [list]
    set in_ports [list]
    set out_dv [list]

                                      append_to_collection out_dv [get_ports "${loc}_v_o_int"]
    for {set k 0} {$k < 16} {incr k} {append_to_collection out_dv [get_ports "${loc}_${k}_o_int"]}
    append_to_collection in_dv  [get_flat_pins -filter "full_name=~io_link/io_link_v_i[$j]"]
    for {set k [expr $j*16]} {$k < [expr ($j+1)*16]} {incr k} {
      append_to_collection in_dv  [get_flat_pins -filter "full_name=~io_link/io_link_data_i[$k]"]
    }

                                      append_to_collection in_ports [get_ports "${loc}_clk_i_int"]
                                      append_to_collection in_ports [get_ports "${loc}_v_i_int"]
    for {set k 0} {$k < 16} {incr k} {append_to_collection in_ports [get_ports "${loc}_${k}_i_int"]}
    set_input_delay 0 -clock [get_clocks $master_in_clk_name] $in_ports

    bsg_link_ddr_constraints              \
      $io_clk_name                        \
      $link_clk_period_ps                 \
      $max_io_output_margin_ps            \
      [get_ports "${loc}_clk_o_int"]      \
      $out_dv                             \
      $master_in_clk_name                 \
      $link_clk_period_ps                 \
      $max_io_input_margin_ps             \
      [get_flat_pins -filter "full_name=~io_link/io_link_clk_i[$j]"]      \
      $in_dv                              \
      "io_link_${j}_tkn_clk"              \
      [get_ports "${loc}_tkn_i_int"]      \
      $link_clk_uncertainty_ps

    #set_max_delay -from [get_ports "${loc}_clk_i_int"] 2000
    #set_max_delay -to   [get_ports "${loc}_clk_o_int"] 2000

  }


# CDC
set cdc_clocks [remove_from_collection [all_clocks] $sdr_clocks]
bsg_async_icl $cdc_clocks


# ungroup


# Derate
bsg_chip_derate_cells
bsg_chip_derate_mems
#report_timing_derate

# Disabled or false paths


puts "BSG-info: Completed script [info script]\n"
