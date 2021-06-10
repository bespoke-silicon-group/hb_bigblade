
puts "BSG-info: Running script [info script]\n"


proc bsg_link_ddr_in_constraints {clk_name pins max_delay min_delay} {
  set_input_delay -max $max_delay -clock $clk_name -source_latency_included -network_latency_included $pins
  set_input_delay -max $max_delay -clock $clk_name -source_latency_included -network_latency_included $pins -add_delay -clock_fall
  set_input_delay -min $min_delay -clock $clk_name -source_latency_included -network_latency_included $pins
  set_input_delay -min $min_delay -clock $clk_name -source_latency_included -network_latency_included $pins -add_delay -clock_fall
}

proc bsg_link_ddr_out_constraints {clock_pin pins setup_time hold_time} {
  foreach_in_collection obj $pins {
    set_data_check -from $clock_pin -to $obj -setup $setup_time
    set_data_check -from $clock_pin -to $obj -hold  $hold_time
    set_multicycle_path -end   -setup 1 -to $obj
    set_multicycle_path -start -hold  0 -to $obj
  }
}

proc bsg_link_ddr_constraints { \
  master_clk_name               \
  out_clk_name                  \
  out_clk_period                \
  out_clk_margin                \
  out_clk_pin                  \
  out_dv_pin                   \
  in_clk_name                   \
  in_clk_period                 \
  in_clk_margin                 \
  in_clk_pin                   \
  in_dv_pin                    \
  tkn_clk_name                  \
  tkn_clk_pin                  \
  uncertainty                   \
} {
  # token
  set tkn_clk_period         [expr $in_clk_period]
  create_clock -period $tkn_clk_period -name $tkn_clk_name $tkn_clk_pin
  set_clock_uncertainty $uncertainty [get_clocks $tkn_clk_name]
  set_propagated_clock [get_clocks $tkn_clk_name]

  # input
  set max_input_delay        [expr ($in_clk_period/2.0)-$in_clk_margin]
  set min_input_delay        [expr $in_clk_margin]
  create_clock -period $in_clk_period -name $in_clk_name $in_clk_pin
  set_clock_uncertainty $uncertainty [get_clocks $in_clk_name]
  set_propagated_clock [get_clocks $in_clk_name]
  bsg_link_ddr_in_constraints $in_clk_name $in_dv_pin $max_input_delay $min_input_delay

  # output
  set setup_time_output      [expr ($out_clk_period/4.0)-$out_clk_margin]
  set hold_time_output       [expr ($out_clk_period/4.0)-$out_clk_margin]
  bsg_link_ddr_out_constraints $out_clk_pin $out_dv_pin $setup_time_output $hold_time_output
}

proc bsg_async_two_clocks {period clk0 clk1} {
  set max_delay_ps [expr $period/2]
  set_max_delay $max_delay_ps -from $clk0 -to $clk1 -ignore_clock_latency
  set_min_delay 0             -from $clk0 -to $clk1 -ignore_clock_latency
  set_max_delay $max_delay_ps -from $clk1 -to $clk0 -ignore_clock_latency
  set_min_delay 0             -from $clk1 -to $clk0 -ignore_clock_latency
}


set tag_clk_name           "tag_clk"
set tag_clk_period_ps      5000.0 ;# 200 MHz
set tag_clk_uncertainty_ps 20
create_clock -period $tag_clk_period_ps -name $tag_clk_name [get_pins pad_CT0_0_i/Y]
set_clock_uncertainty $tag_clk_uncertainty_ps  [get_clocks $tag_clk_name]
set_propagated_clock [get_clocks $tag_clk_name]

set bp_clk_period_ps      [expr 1100.0 * 1.3]
set bp_clk_uncertainty_ps 20

set cgra_clk_period_ps      1100.0
set cgra_clk_uncertainty_ps 20

# tag constraints
set tag_in_pins [get_pins {pad_CT0_1_i/Y pad_CT0_2_i/Y}]
set_input_delay [expr $tag_clk_period_ps/2] -clock $tag_clk_name -source_latency_included -network_latency_included $tag_in_pins


# false path
set_false_path -from [get_ports p_pad_CT0_v_i]
set_false_path -from [get_ports {p_pad_CT0_4_i p_pad_CT0_3_i}]
set_false_path -from [get_ports {p_pad_CT0_7_i p_pad_CT0_6_i p_pad_CT0_5_i}]

set_false_path -to [get_ports p_pad_CT0_0_o]
set_false_path -to [get_ports p_pad_CT0_1_o]
set_false_path -to [get_ports p_pad_CT0_2_o]

set_false_path -from [get_ports {p_pad_CB0_2_i, p_pad_CB0_1_i, p_pad_CB0_0_i}]
set_false_path -from [get_ports {p_pad_CB0_5_i, p_pad_CB0_4_i, p_pad_CB0_3_i}]

set_false_path -to [get_ports p_pad_CB0_0_o]
set_false_path -to [get_ports p_pad_CB0_1_o]


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
    create_clock -period $io_clk_period_ps -name $io_clk_name [get_pins "block/mem_link*${i}*link/ddr_link*${j}*link/clk_gen_io/clk_gen_inst/mux_inst/*/Z"]
    set_clock_uncertainty $io_clk_uncertainty_ps  [get_clocks $io_clk_name]
    set_propagated_clock [get_clocks $io_clk_name]
    set_case_analysis 0 [get_pins "block/mem_link*${i}*link/ddr_link*${j}*delay/sig*mux*/S*"]

    set side [expr {$i < 4} ? {"DL"} : {"DR"}]
    set num  [expr ($i % 4) * 2 + $j]
    set loc  "pad_${side}${num}"

    set in_dv  [list]
    set out_dv [list]
    append_to_collection out_dv [get_pins "${loc}_v_o/DATA"]
    for {set k 0} {$k < 16} {incr k} {append_to_collection out_dv [get_pins "${loc}_${k}_o/DATA"]}
    append_to_collection in_dv [get_pins "${loc}_v_i/Y"]
    for {set k 0} {$k < 16} {incr k} {append_to_collection in_dv [get_pins "${loc}_${k}_i/Y"]}

    bsg_link_ddr_constraints            \
      $io_clk_name                      \
      "mem_link_${i}_${j}_out_clk"      \
      $link_clk_period_ps               \
      $max_io_output_margin_ps          \
      [get_pins "${loc}_clk_o/DATA"]    \
      $out_dv                           \
      "mem_link_${i}_${j}_in_clk"       \
      $link_clk_period_ps               \
      $max_io_input_margin_ps           \
      [get_pins "${loc}_clk_i/Y"]    \
      $in_dv                            \
      "mem_link_${i}_${j}_tkn_clk"      \
      [get_pins "${loc}_tkn_i/Y"]    \
      $link_clk_uncertainty_ps

    bsg_async_two_clocks $io_clk_period_ps [get_clocks $io_clk_name] [get_clocks "mem_link_${i}_${j}_in_clk"]
    bsg_async_two_clocks $io_clk_period_ps [get_clocks $io_clk_name] [get_clocks "mem_link_${i}_${j}_tkn_clk"]
    set_false_path -to [get_clocks $io_clk_name] -from [get_clocks "tag_clk"]
    set_false_path -to [get_clocks "mem_link_${i}_${j}_in_clk"] -from [get_clocks "tag_clk"]
    set_false_path -to [get_clocks "mem_link_${i}_${j}_tkn_clk"] -from [get_clocks "tag_clk"]
  }
}

for {set j 0} {$j < 2} {incr j} {

  set io_clk_name   "io_link_${j}_io_clk"
  create_clock -period $io_clk_period_ps -name $io_clk_name [get_pins "block/io_link/ddr_link*${j}*link/clk_gen_io/clk_gen_inst/mux_inst/*/Z"]
  set_clock_uncertainty $io_clk_uncertainty_ps  [get_clocks $io_clk_name]
  set_propagated_clock [get_clocks $io_clk_name]
  set_case_analysis 0 [get_pins "block/io_link/ddr_link*${j}*delay/sig*mux*/S*"]

  set loc  "pad_IT${j}"

  set in_dv  [list]
  set out_dv [list]
  append_to_collection out_dv [get_pins "${loc}_v_o/DATA"]
  for {set k 0} {$k < 16} {incr k} {append_to_collection out_dv [get_pins "${loc}_${k}_o/DATA"]}
  append_to_collection in_dv [get_pins "${loc}_v_i/Y"]
  for {set k 0} {$k < 16} {incr k} {append_to_collection in_dv [get_pins "${loc}_${k}_i/Y"]}

  bsg_link_ddr_constraints            \
    $io_clk_name                      \
    "io_link_${j}_out_clk"            \
    $link_clk_period_ps               \
    $max_io_output_margin_ps          \
    [get_pins "${loc}_clk_o/DATA"]    \
    $out_dv                           \
    "io_link_${j}_in_clk"             \
    $link_clk_period_ps               \
    $max_io_input_margin_ps           \
    [get_pins "${loc}_clk_i/Y"]    \
    $in_dv                            \
    "io_link_${j}_tkn_clk"            \
    [get_pins "${loc}_tkn_i/Y"]    \
    $link_clk_uncertainty_ps

    bsg_async_two_clocks $io_clk_period_ps [get_clocks $io_clk_name] [get_clocks "io_link_${j}_in_clk"]
    bsg_async_two_clocks $io_clk_period_ps [get_clocks $io_clk_name] [get_clocks "io_link_${j}_tkn_clk"]
    set_false_path -to [get_clocks $io_clk_name] -from [get_clocks "tag_clk"]
    set_false_path -to [get_clocks "io_link_${j}_in_clk"] -from [get_clocks "tag_clk"]
    set_false_path -to [get_clocks "io_link_${j}_tkn_clk"] -from [get_clocks "tag_clk"]
}


# SDR
set pod_clk_period_ps          1100.0
set pod_clk_uncertainty_ps     20

for {set i 0} {$i < 4} {incr i} {
  set wh_master_clk_name   "pod_row_${i}_master_clk"
  create_clock -period $pod_clk_period_ps -name $wh_master_clk_name [get_pins "block/core_complex_core_${i}__clk_gen/clk_o"]
  set_clock_uncertainty $pod_clk_uncertainty_ps [get_clocks $wh_master_clk_name]
  set_propagated_clock [get_clocks $wh_master_clk_name]
  for {set j 0} {$j < 8} {incr j} {
    create_generated_clock \
        -divide_by 1 \
        -invert \
        -add \
        -master_clock $wh_master_clk_name \
        -source [get_attribute [get_clocks $wh_master_clk_name] sources] \
        -name "wh_link_${i}_${j}_clk" \
        [get_pins "block/core_complex_core_${i}__podrow/io_wh_link_clk_o[${j}]"]
    set_propagated_clock [get_clocks "wh_link_${i}_${j}_clk"]
  }
  set_false_path -to [get_clocks $wh_master_clk_name] -from [get_clocks "tag_clk"]
}

for {set i 0} {$i < 8} {incr i} {
  set wh_master_clk_name   "mem_link_${i}_master_clk"
  create_clock -period 1000 -name $wh_master_clk_name [get_pins "block/mem_link*${i}*link/ddr_link*0*link/clk_gen_noc/clk_gen_inst/mux_inst/*/Z"]
  set_clock_uncertainty 20 [get_clocks $wh_master_clk_name]
  set_propagated_clock [get_clocks $wh_master_clk_name]
  for {set j 0} {$j < 4} {incr j} {
    create_generated_clock \
        -divide_by 1 \
        -invert \
        -master_clock $wh_master_clk_name \
        -add \
        -source [get_attribute [get_clocks $wh_master_clk_name] sources] \
        -name "mem_link_${i}_${j}_clk" \
        [get_pins "block/mem_link*${i}*link/io_wh_link_clk_o[${j}]"]
    set_propagated_clock [get_clocks "mem_link_${i}_${j}_clk"]
  }
  bsg_async_two_clocks $io_clk_period_ps [get_clocks $wh_master_clk_name] [get_clocks "mem_link_${i}_0_io_clk"]
  bsg_async_two_clocks $io_clk_period_ps [get_clocks $wh_master_clk_name] [get_clocks "mem_link_${i}_1_io_clk"]
  bsg_async_two_clocks $io_clk_period_ps [get_clocks $wh_master_clk_name] [get_clocks "mem_link_${i}_0_in_clk"]
  bsg_async_two_clocks $io_clk_period_ps [get_clocks $wh_master_clk_name] [get_clocks "mem_link_${i}_1_in_clk"]
  bsg_async_two_clocks $io_clk_period_ps [get_clocks $wh_master_clk_name] [get_clocks "mem_link_${i}_0_tkn_clk"]
  bsg_async_two_clocks $io_clk_period_ps [get_clocks $wh_master_clk_name] [get_clocks "mem_link_${i}_1_tkn_clk"]
  set_false_path -to [get_clocks $wh_master_clk_name] -from [get_clocks "tag_clk"]
}

set wh_master_clk_name   "io_link_master_clk"
create_clock -period 1000 -name $wh_master_clk_name [get_pins "block/io_link/ddr_link*0*link/clk_gen_noc/clk_gen_inst/mux_inst/*/Z"]
set_clock_uncertainty 20 [get_clocks $wh_master_clk_name]
set_propagated_clock [get_clocks $wh_master_clk_name]
foreach {j} {"fwd" "rev"} {
  create_generated_clock \
      -divide_by 1 \
      -invert \
      -master_clock $wh_master_clk_name \
      -add \
      -source [get_attribute [get_clocks $wh_master_clk_name] sources] \
      -name "io_link_${j}_clk" \
      [get_pins "block/io_link/mc_${j}_link_clk_o"]
  set_propagated_clock [get_clocks "io_link_${j}_clk"]
}
bsg_async_two_clocks $io_clk_period_ps [get_clocks $wh_master_clk_name] [get_clocks "io_link_0_io_clk"]
bsg_async_two_clocks $io_clk_period_ps [get_clocks $wh_master_clk_name] [get_clocks "io_link_1_io_clk"]
bsg_async_two_clocks $io_clk_period_ps [get_clocks $wh_master_clk_name] [get_clocks "io_link_0_in_clk"]
bsg_async_two_clocks $io_clk_period_ps [get_clocks $wh_master_clk_name] [get_clocks "io_link_1_in_clk"]
bsg_async_two_clocks $io_clk_period_ps [get_clocks $wh_master_clk_name] [get_clocks "io_link_0_tkn_clk"]
bsg_async_two_clocks $io_clk_period_ps [get_clocks $wh_master_clk_name] [get_clocks "io_link_1_tkn_clk"]
set_false_path -to [get_clocks $wh_master_clk_name] -from [get_clocks "tag_clk"]

set wh_master_clk_name   "pod_row_0_master_clk"
create_generated_clock \
    -divide_by 1 \
    -invert \
    -add \
    -master_clock $wh_master_clk_name \
    -source [get_attribute [get_clocks $wh_master_clk_name] sources] \
    -name "west_link_rev_clk" \
    [get_pins "block/core_complex_core_0__podrow/hor_io_rev_link_clk_o[0]"]
set_propagated_clock [get_clocks "west_link_rev_clk"]
create_generated_clock \
    -divide_by 1 \
    -invert \
    -add \
    -master_clock $wh_master_clk_name \
    -source [get_attribute [get_clocks $wh_master_clk_name] sources] \
    -name "north_link_fwd_clk" \
    [get_pins "block/core_complex_core_0__podrow/ver_io_fwd_link_clk_o[16]"]
set_propagated_clock [get_clocks "north_link_fwd_clk"]


# BP
for {set i 0} {$i < 4} {incr i} {
  for {set j 0} {$j < 2} {incr j} {
    set wh_master_clk_name   "bp_${i}_${j}_master_clk"
    create_clock -period $bp_clk_period_ps -name $wh_master_clk_name [get_pins "block/core_complex_core_${i}__bp_${j}__clk_gen/clk_o"]
    set_clock_uncertainty $bp_clk_uncertainty_ps [get_clocks $wh_master_clk_name]
    set_propagated_clock [get_clocks $wh_master_clk_name]
    set_false_path -to [get_clocks $wh_master_clk_name] -from [get_clocks "tag_clk"]
    set_false_path -through [get_pins "block/core_complex_core_${i}__bp_${j}__halfpod/*disable_o*"]
  }
}

# CGRA
for {set i 0} {$i < 4} {incr i} {
  for {set j 0} {$j < 2} {incr j} {
    set wh_master_clk_name   "cgra_${i}_${j}_master_clk"
    create_clock -period $cgra_clk_period_ps -name $wh_master_clk_name [get_pins "block/core_complex_core_${i}__cgra_${j}__clk_gen/clk_o"]
    set_clock_uncertainty $cgra_clk_uncertainty_ps [get_clocks $wh_master_clk_name]
    set_propagated_clock [get_clocks $wh_master_clk_name]
    set_false_path -to [get_clocks $wh_master_clk_name] -from [get_clocks "tag_clk"]
    set_false_path -through [get_pins "block/core_complex_core_${i}__cgra_${j}__halfpod/*disable_o*"]
  }
}


set num_ver_links [expr 64+2]
for {set i 0} {$i < 4} {incr i} {
  set wh_master_clk_name   "pod_row_${i}_master_clk"
  set pod_clk_period_ps [get_attribute [get_clocks $wh_master_clk_name] period]
  set start_idx [expr {$i == 0} ? {$num_ver_links} : {0}]
  set end_idx   [expr {$i == 3} ? {$num_ver_links} : {2*$num_ver_links}]
  for {set j $start_idx} {$j < $end_idx} {incr j} {
    foreach {k} {"fwd" "rev"} {
      create_generated_clock \
          -divide_by 1 \
          -invert \
          -master_clock $wh_master_clk_name \
          -add \
          -source [get_attribute [get_clocks $wh_master_clk_name] sources] \
          -name "ver_link_${i}_${j}_${k}_clk" \
          [get_pins "block/core_complex_core_${i}__podrow/ver_io_${k}_link_clk_o[${j}]"]
      set_propagated_clock [get_clocks "ver_link_${i}_${j}_${k}_clk"] 

      set x [expr {$j < $num_ver_links} ? {$i-1} : {$i+1}]
      bsg_async_two_clocks $pod_clk_period_ps [get_clocks "ver_link_${i}_${j}_${k}_clk"] [get_clocks "pod_row_${x}_master_clk"]
      set_false_path -to [get_clocks "ver_link_${i}_${j}_${k}_clk"] -from [get_clocks "tag_clk"]
    }
  }
}


for {set i 0} {$i < 4} {incr i} {
  set wh_master_clk_name   "pod_row_${i}_master_clk"
  set pod_clk_period_ps [get_attribute [get_clocks $wh_master_clk_name] period]
  for {set j 0} {$j < 8} {incr j} {
    set blk [expr {$j < 8} ? {"bp"} : {"cgra"}]
    if {($j == 0) || ($j == 4)} { continue }
    foreach {k} {"fwd" "rev"} {
      create_generated_clock \
          -divide_by 1 \
          -invert \
          -master_clock $wh_master_clk_name \
          -add \
          -source [get_attribute [get_clocks $wh_master_clk_name] sources] \
          -name "hor_link_${i}_${j}_${k}_clk" \
          [get_pins "block/core_complex_core_${i}__podrow/hor_io_${k}_link_clk_o[${j}]"]
      set_propagated_clock [get_clocks "hor_link_${i}_${j}_${k}_clk"] 

      set x [expr ($j%8)/4]
      bsg_async_two_clocks $pod_clk_period_ps [get_clocks "hor_link_${i}_${j}_${k}_clk"] [get_clocks "${blk}_${i}_${x}_master_clk"]
      set_false_path -to [get_clocks "hor_link_${i}_${j}_${k}_clk"] -from [get_clocks "tag_clk"]
    }
  }
}

foreach {blk} {"bp" "cgra"} {
  for {set i 0} {$i < 4} {incr i} {
    for {set j 0} {$j < 2} {incr j} {
      set wh_master_clk_name   "${blk}_${i}_${j}_master_clk"
      set pod_clk_period_ps [get_attribute [get_clocks $wh_master_clk_name] period]
      set end_idx [expr {$blk == "bp"} ? {3} : {4}]
      for {set l 0} {$l < $end_idx} {incr l} {
        foreach {k} {"fwd" "rev"} {
          create_generated_clock \
              -divide_by 1 \
              -invert \
              -master_clock $wh_master_clk_name \
              -add \
              -source [get_attribute [get_clocks $wh_master_clk_name] sources] \
              -name "${blk}_link_${i}_${j}_${k}_${l}_clk" \
              [get_pins "block/core_complex_core_${i}__${blk}_${j}__halfpod/io_${k}_link_clk_o[${l}]"]
          set_propagated_clock [get_clocks "${blk}_link_${i}_${j}_${k}_${l}_clk"] 

          bsg_async_two_clocks $pod_clk_period_ps [get_clocks "${blk}_link_${i}_${j}_${k}_${l}_clk"] [get_clocks "pod_row_${i}_master_clk"]
          set_false_path -to [get_clocks "${blk}_link_${i}_${j}_${k}_${l}_clk"] -from [get_clocks "tag_clk"]
        }
      }
    }
  }
}




foreach_in_collection cell [get_cells "block/mem_link*link/ddr_link*link/downlink/*downstream/*harden*fifo/*hardened*/*mem*/*macro*mem"] {
  set_disable_timing $cell -from CLKA -to CLKB
  set_disable_timing $cell -from CLKB -to CLKA
}
foreach_in_collection cell [get_cells "block/io_link/ddr_link*link/downlink/*downstream/*harden*fifo/*hardened*/*mem*/*macro*mem"] {
  set_disable_timing $cell -from CLKA -to CLKB
  set_disable_timing $cell -from CLKB -to CLKA
}
foreach_in_collection cell [get_cells "block/io_link/tunnel/bcti/b1_ntf/*buff*fifo/*hardened*/*mem*/*macro*mem"] {
  set_disable_timing $cell -from CLKA -to CLKB
  set_disable_timing $cell -from CLKB -to CLKA
}

if { [sizeof [get_lib_cells */* -filter "is_memory_cell"]] > 0 } {
  set_timing_derate -cell_delay -early 0.97 [get_lib_cells */* -filter "is_memory_cell"]
  set_timing_derate -cell_delay -late  1.03 [get_lib_cells */* -filter "is_memory_cell"]
  set_timing_derate -cell_check -early 0.97 [get_lib_cells */* -filter "is_memory_cell"]
  set_timing_derate -cell_check -late  1.03 [get_lib_cells */* -filter "is_memory_cell"]
}



# multicycle cells
set multicycle_cells [list]
# manycore_tiles
append_to_collection multicycle_cells [get_cells block/core_complex_core_*__podrow/podrow/px_*__pod/*_vc_x_0__*_vc_row/vc_y_0__vc_x_*__vc/x_dff/data_r_reg_*]
append_to_collection multicycle_cells [get_cells block/core_complex_core_*__podrow/podrow/px_*__pod/*_vc_x_0__*_vc_row/vc_y_0__vc_x_*__vc/y_dff/data_r_reg_*]
# vcache
append_to_collection multicycle_cells [get_cells block/core_complex_core_*__podrow/podrow/px_*__pod/mc_y_*__mc_x_0__mc/y_*__x_*__tile/dff_x/data_r_reg_*]
append_to_collection multicycle_cells [get_cells block/core_complex_core_*__podrow/podrow/px_*__pod/mc_y_*__mc_x_0__mc/y_*__x_*__tile/dff_y/data_r_reg_*]
# sdr north
append_to_collection multicycle_cells [get_cells block/core_complex_core_*__podrow/sdr_n_x_*__sdr_n/sdr_x_*__sdr_n/dff_global_x/data_r_reg_*]
append_to_collection multicycle_cells [get_cells block/core_complex_core_*__podrow/sdr_n_x_*__sdr_n/sdr_x_*__sdr_n/dff_global_y/data_r_reg_*]
# sdr corner
append_to_collection multicycle_cells [get_cells block/core_complex_core_*__podrow/sdr_nw/dff_global_x/data_r_reg*]
append_to_collection multicycle_cells [get_cells block/core_complex_core_*__podrow/sdr_nw/dff_global_y/data_r_reg*]
append_to_collection multicycle_cells [get_cells block/core_complex_core_*__podrow/sdr_ne/dff_global_x/data_r_reg*]
append_to_collection multicycle_cells [get_cells block/core_complex_core_*__podrow/sdr_ne/dff_global_y/data_r_reg*]
append_to_collection multicycle_cells [get_cells block/core_complex_core_*__podrow/sdr_sw/dff_global_x/data_r_reg*]
append_to_collection multicycle_cells [get_cells block/core_complex_core_*__podrow/sdr_sw/dff_global_y/data_r_reg*]
append_to_collection multicycle_cells [get_cells block/core_complex_core_*__podrow/sdr_se/dff_global_x/data_r_reg*]
append_to_collection multicycle_cells [get_cells block/core_complex_core_*__podrow/sdr_se/dff_global_y/data_r_reg*]
# sdr_west east
append_to_collection multicycle_cells [get_cells block/core_complex_core_*__podrow/sdr_*_y_*__sdr_*/dff_global_x/data_r_reg*]
append_to_collection multicycle_cells [get_cells block/core_complex_core_*__podrow/sdr_*_y_*__sdr_*/dff_global_y/data_r_reg*]




set_multicycle_path 2 -setup -to   $multicycle_cells
set_multicycle_path 2 -hold  -to   $multicycle_cells
set_multicycle_path 2 -setup -from $multicycle_cells
set_multicycle_path 2 -hold  -from $multicycle_cells






# Disabled or false paths
for {set i 0} {$i < 4} {incr i} {
  for {set j 0} {$j < 8} {incr j} {
    set x [expr $i+4*($j/4)]
    bsg_async_two_clocks $pod_clk_period_ps [get_clocks "wh_link_${i}_${j}_clk"] [get_clocks "mem_link_${x}_master_clk"]
    set_false_path -to [get_clocks "wh_link_${i}_${j}_clk"] -from [get_clocks "tag_clk"]
  }
}

for {set i 0} {$i < 8} {incr i} {
  for {set j 0} {$j < 4} {incr j} {
    set x [expr $i%4]
    bsg_async_two_clocks $pod_clk_period_ps [get_clocks "mem_link_${i}_${j}_clk"] [get_clocks "pod_row_${x}_master_clk"]
    set_false_path -to [get_clocks "mem_link_${i}_${j}_clk"] -from [get_clocks "tag_clk"]
  }
}

foreach {j} {"fwd" "rev"} {
  bsg_async_two_clocks $pod_clk_period_ps [get_clocks "io_link_${j}_clk"] [get_clocks "pod_row_0_master_clk"]
  set_false_path -to [get_clocks "io_link_${j}_clk"] -from [get_clocks "tag_clk"]
}

bsg_async_two_clocks $pod_clk_period_ps [get_clocks "west_link_rev_clk"] [get_clocks "io_link_master_clk"]
set_false_path -to [get_clocks "west_link_rev_clk"] -from [get_clocks "tag_clk"]

bsg_async_two_clocks $pod_clk_period_ps [get_clocks "north_link_fwd_clk"] [get_clocks "io_link_master_clk"]
set_false_path -to [get_clocks "north_link_fwd_clk"] -from [get_clocks "tag_clk"]



puts "BSG-info: Completed script [info script]\n"
