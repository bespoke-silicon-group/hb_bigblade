set bsg_cts_i 0

proc bsg_create_clock_buffer {src x y  {invert 1} {stren 20} {vt "SL"}} {
  global bsg_cts_i
  set rd_x [round_down_to_nearest $x 0.084]
  set rd_y [round_down_to_nearest $y 0.48]

  # create buffer cell
  if {$invert == 1} {
    set lib_name "IN14LPP_SC7P5T_84CPP_BASE_SSC14${vt}/SC7P5T_CKINVX${stren}_SSC14${vt}"
  } else {
    set lib_name "IN14LPP_SC7P5T_84CPP_BASE_SSC14${vt}/SC7P5T_CKBUFX${stren}_SSC14${vt}"
  }

  set cell_name "bsg_cts_${bsg_cts_i}"
  set buffer_cell [create_cell $cell_name $lib_name]
  move_objects -x $rd_x -y $rd_y $buffer_cell
  set_fixed_object $buffer_cell
  set_size_only [get_cells $buffer_cell] true

  set buffer_input_pin [get_pin -of $buffer_cell -filter "name==CLK"]
  set buffer_output_pin [get_pin -of $buffer_cell -filter "name==Z"]

  # create new net
  set src_net [get_net -of $src -quiet]
  if {[sizeof_collection $src_net] == 0} {
    set new_net_name "bsg_cts_net_${bsg_cts_i}"
    create_net $new_net_name
    set src_net [get_net $new_net_name]
    connect_net -net $src_net [list $src $buffer_input_pin]
    set_dont_touch $src_net true
  } else {
    connect_net -net $src_net [list $buffer_input_pin]
    set_dont_touch $src_net true
  }

  incr bsg_cts_i
  return $buffer_output_pin
}

proc bsg_connect_sinks {src sinks} {
  global bsg_cts_i

  set sink_net [get_net -of $sinks -quiet]
  if {[sizeof_collection $sink_net] != 0} {
    remove_net $sink_net
  }

  set src_net [get_net -of $src -quiet]
  if {[sizeof_collection $src_net] == 0} {
    set new_net_name "bsg_cts_net_${bsg_cts_i}"
    create_net $new_net_name
    set src_net [get_net $new_net_name]
    connect_net -net $src_net [list $src $sinks]
    incr bsg_cts_i
  } else {
    connect_net -net $src_net $sinks
  }
}


#remove_cells [get_cells bsg_cts*]
#remove_nets [get_nets bsg_cts*]
disconnect_net [get_net "ext_clk_i"] -all



# center spine
set C0 [bsg_create_clock_buffer [get_ports "ext_clk_i"] 4807 1867]
set C1 [bsg_create_clock_buffer $C0 4807 1844]
set C2 [bsg_create_clock_buffer $C1 4807 1771]
set C3 [bsg_create_clock_buffer $C2 4807 1693]
set C4 [bsg_create_clock_buffer $C3 4807 1598]
set C5 [bsg_create_clock_buffer $C4 4807 1503]
set C6 [bsg_create_clock_buffer $C5 4807 1408]
set C7 [bsg_create_clock_buffer $C6 4807 1313]
set C8 [bsg_create_clock_buffer $C7 4807 1218]
set C9 [bsg_create_clock_buffer $C8 4807 1123]
set C10 [bsg_create_clock_buffer $C9 4807 1029]
set C11 [bsg_create_clock_buffer $C10 4807 933]

set LH0 [bsg_create_clock_buffer $C11 4497 933]
set LH1 [bsg_create_clock_buffer $LH0 4202 933]
set LH2 [bsg_create_clock_buffer $LH1 3911 933]
set LH3 [bsg_create_clock_buffer $LH2 3619 933]
set LH4 [bsg_create_clock_buffer $LH3 3313 933]
set LH5 [bsg_create_clock_buffer $LH4 3016 933]
set LH6 [bsg_create_clock_buffer $LH5 2726 933]
set LH7 [bsg_create_clock_buffer $LH6 2429 933]
set LH8 [bsg_create_clock_buffer $LH7 2118 933]
set LH9 [bsg_create_clock_buffer $LH8 1824 933]
set LH10 [bsg_create_clock_buffer $LH9  1525 933]
set LH11 [bsg_create_clock_buffer $LH10 1239 933]
set LH12 [bsg_create_clock_buffer $LH11 935 933]
set LH13 [bsg_create_clock_buffer $LH12 643 933]
set LH14 [bsg_create_clock_buffer $LH13 346 933]
set LH15 [bsg_create_clock_buffer $LH14 54  933]

set LEN0 [bsg_create_clock_buffer $LH15 52 1028]
set LEN1 [bsg_create_clock_buffer $LEN0 52 1123]
set LEN2 [bsg_create_clock_buffer $LEN1 52 1218]
set LEN3 [bsg_create_clock_buffer $LEN2 52 1313]
set LEN4 [bsg_create_clock_buffer $LEN3 52 1408]
set LEN5 [bsg_create_clock_buffer $LEN4 52 1502]
set LEN6 [bsg_create_clock_buffer $LEN5 52 1598]
set LEN7 [bsg_create_clock_buffer $LEN6 52 1700]
bsg_connect_sinks $LEN1 [get_pins {sdr_w_y_3__sdr_w/core_clk_i sdr_w_y_2__sdr_w/core_clk_i}]
bsg_connect_sinks $LEN5 [get_pins {sdr_w_y_1__sdr_w/core_clk_i sdr_w_y_0__sdr_w/core_clk_i}]
bsg_connect_sinks $LEN7 [get_pins "sdr_nw/core_clk_i"]

set LES0 [bsg_create_clock_buffer $LH15 52 838]
set LES1 [bsg_create_clock_buffer $LES0 52 743]
set LES2 [bsg_create_clock_buffer $LES1 52 648]
set LES3 [bsg_create_clock_buffer $LES2 52 552]
set LES4 [bsg_create_clock_buffer $LES3 52 458]
set LES5 [bsg_create_clock_buffer $LES4 52 363]
set LES6 [bsg_create_clock_buffer $LES5 52 268]
set LES7 [bsg_create_clock_buffer $LES6 52 168]
bsg_connect_sinks $LES1 [get_pins {sdr_w_y_4__sdr_w/core_clk_i sdr_w_y_5__sdr_w/core_clk_i}]
bsg_connect_sinks $LES5 [get_pins {sdr_w_y_6__sdr_w/core_clk_i sdr_w_y_7__sdr_w/core_clk_i}]
bsg_connect_sinks $LES7 [get_pins "sdr_sw/core_clk_i"]

set LVS0 [bsg_create_clock_buffer $LH7  2429 838]
set LVS1 [bsg_create_clock_buffer $LVS0 2429 742]
set LVS2 [bsg_create_clock_buffer $LVS1 2429 648]
set LVS3 [bsg_create_clock_buffer $LVS2 2429 552]
set LVS4 [bsg_create_clock_buffer $LVS3 2429 458]
set LVS5 [bsg_create_clock_buffer $LVS4 2429 362]
set LVS6 [bsg_create_clock_buffer $LVS5 2429 268]
set LVS7 [bsg_create_clock_buffer $LVS6 2429 172]
set LVS8 [bsg_create_clock_buffer $LVS7 2429 106]
set LVS9 [bsg_create_clock_buffer $LVS8 2429 22.5]

set LVN0 [bsg_create_clock_buffer $LH7 2429 1028]
set LVN1 [bsg_create_clock_buffer $LVN0 2429 1123]
set LVN2 [bsg_create_clock_buffer $LVN1 2429 1217]
set LVN3 [bsg_create_clock_buffer $LVN2 2429 1312]
set LVN4 [bsg_create_clock_buffer $LVN3 2429 1408]
set LVN5 [bsg_create_clock_buffer $LVN4 2429 1503]
set LVN6 [bsg_create_clock_buffer $LVN5 2429 1598]
set LVN7 [bsg_create_clock_buffer $LVN6 2429 1693]
set LVN8 [bsg_create_clock_buffer $LVN7 2429 1771]
set LVN9 [bsg_create_clock_buffer $LVN8 2429 1844]


set LCL0 [bsg_create_clock_buffer $LH7  2267  933]
set LCL1 [bsg_create_clock_buffer $LCL0 1971  933]
set LCL2 [bsg_create_clock_buffer $LCL1 1673  933]
set LCL3 [bsg_create_clock_buffer $LCL2 1369  933]
bsg_connect_sinks $LCL3 [get_pins "podrow/px_0__pod/mc_y_2__mc_x_0__mc/clk_i"]
set LCR0 [bsg_create_clock_buffer $LH7  2572  933]
set LCR1 [bsg_create_clock_buffer $LCR0 2873  933]
set LCR2 [bsg_create_clock_buffer $LCR1 3164  933]
set LCR3 [bsg_create_clock_buffer $LCR2 3465  933]
bsg_connect_sinks $LCR3 [get_pins "podrow/px_1__pod/mc_y_2__mc_x_0__mc/clk_i"]

set LN1L0 [bsg_create_clock_buffer $LVN3  2267  1312]
set LN1L1 [bsg_create_clock_buffer $LN1L0 1971  1312]
set LN1L2 [bsg_create_clock_buffer $LN1L1 1673  1312]
set LN1L3 [bsg_create_clock_buffer $LN1L2 1369  1312]
bsg_connect_sinks $LN1L3 [get_pins "podrow/px_0__pod/mc_y_1__mc_x_0__mc/clk_i"]
set LN1R0 [bsg_create_clock_buffer $LVN3  2572  1312]
set LN1R1 [bsg_create_clock_buffer $LN1R0 2873  1312]
set LN1R2 [bsg_create_clock_buffer $LN1R1 3164  1312]
set LN1R3 [bsg_create_clock_buffer $LN1R2 3465  1312]
bsg_connect_sinks $LN1R3 [get_pins "podrow/px_1__pod/mc_y_1__mc_x_0__mc/clk_i"]

set LN2L0 [bsg_create_clock_buffer $LVN7  2267  1693]
set LN2L1 [bsg_create_clock_buffer $LN2L0 1971  1693]
set LN2L2 [bsg_create_clock_buffer $LN2L1 1673  1693]
set LN2L3 [bsg_create_clock_buffer $LN2L2 1369  1693]
bsg_connect_sinks $LN2L3 [get_pins "podrow/px_0__pod/mc_y_0__mc_x_0__mc/clk_i"]
set LN2R0 [bsg_create_clock_buffer $LVN7  2572  1693]
set LN2R1 [bsg_create_clock_buffer $LN2R0 2873  1693]
set LN2R2 [bsg_create_clock_buffer $LN2R1 3164  1693]
set LN2R3 [bsg_create_clock_buffer $LN2R2 3465  1693]
bsg_connect_sinks $LN2R3 [get_pins "podrow/px_1__pod/mc_y_0__mc_x_0__mc/clk_i"]

set LN3L0 [bsg_create_clock_buffer $LVN9  2267  1844]
set LN3L1 [bsg_create_clock_buffer $LN3L0 1971  1844]
set LN3L2 [bsg_create_clock_buffer $LN3L1 1673  1844]
set LN3L3 [bsg_create_clock_buffer $LN3L2 1369  1844]
bsg_connect_sinks $LN3L3 [get_pins {sdr_n_x_0__sdr_n/core_clk_i podrow/px_0__pod/north_vc_x_0__north_vc_row/clk_i}]
set LN3R0 [bsg_create_clock_buffer $LVN9  2572  1844]
set LN3R1 [bsg_create_clock_buffer $LN3R0 2873  1844]
set LN3R2 [bsg_create_clock_buffer $LN3R1 3164  1844]
set LN3R3 [bsg_create_clock_buffer $LN3R2 3465  1844]
bsg_connect_sinks $LN3R3 [get_pins {sdr_n_x_1__sdr_n/core_clk_i podrow/px_1__pod/north_vc_x_0__north_vc_row/clk_i}]

set LS1L0 [bsg_create_clock_buffer $LVS3  2267  552]
set LS1L1 [bsg_create_clock_buffer $LS1L0 1971  552]
set LS1L2 [bsg_create_clock_buffer $LS1L1 1673  552]
set LS1L3 [bsg_create_clock_buffer $LS1L2 1369  552]
bsg_connect_sinks $LS1L3 [get_pins "podrow/px_0__pod/mc_y_3__mc_x_0__mc/clk_i"]
set LS1R0 [bsg_create_clock_buffer $LVS3  2572  552]
set LS1R1 [bsg_create_clock_buffer $LS1R0 2873  552]
set LS1R2 [bsg_create_clock_buffer $LS1R1 3164  552]
set LS1R3 [bsg_create_clock_buffer $LS1R2 3465  552]
bsg_connect_sinks $LS1R3 [get_pins "podrow/px_1__pod/mc_y_3__mc_x_0__mc/clk_i"]

set LS2L0 [bsg_create_clock_buffer $LVS7  2267  172]
set LS2L1 [bsg_create_clock_buffer $LS2L0 1971  172]
set LS2L2 [bsg_create_clock_buffer $LS2L1 1673  172]
set LS2L3 [bsg_create_clock_buffer $LS2L2 1369  172]
bsg_connect_sinks $LS2L3 [get_pins "podrow/px_0__pod/south_vc_x_0__south_vc_row/clk_i"]
set LS2R0 [bsg_create_clock_buffer $LVS7  2572  172]
set LS2R1 [bsg_create_clock_buffer $LS2R0 2873  172]
set LS2R2 [bsg_create_clock_buffer $LS2R1 3164  172]
set LS2R3 [bsg_create_clock_buffer $LS2R2 3465  172]
bsg_connect_sinks $LS2R3 [get_pins "podrow/px_1__pod/south_vc_x_0__south_vc_row/clk_i"]

set LS3L0 [bsg_create_clock_buffer $LVS9  2267  22.5]
set LS3L1 [bsg_create_clock_buffer $LS3L0 1971  22.5]
set LS3L2 [bsg_create_clock_buffer $LS3L1 1673  22.5]
set LS3L3 [bsg_create_clock_buffer $LS3L2 1369  22.5]
bsg_connect_sinks $LS3L3 [get_pins "sdr_s_x_0__sdr_s/core_clk_i"]
set LS3R0 [bsg_create_clock_buffer $LVS9  2572  22.5]
set LS3R1 [bsg_create_clock_buffer $LS3R0 2873  22.5]
set LS3R2 [bsg_create_clock_buffer $LS3R1 3164  22.5]
set LS3R3 [bsg_create_clock_buffer $LS3R2 3465  22.5]
bsg_connect_sinks $LS3R3 [get_pins "sdr_s_x_1__sdr_s/core_clk_i"]




######
set RH0  [bsg_create_clock_buffer $C11  5100  933]
set RH1  [bsg_create_clock_buffer $RH0  5400  933]
set RH2  [bsg_create_clock_buffer $RH1  5700  933]
set RH3  [bsg_create_clock_buffer $RH2  5987  933]
set RH4  [bsg_create_clock_buffer $RH3  6286  933]
set RH5  [bsg_create_clock_buffer $RH4  6581  933]
set RH6  [bsg_create_clock_buffer $RH5  6878  933]
set RH7  [bsg_create_clock_buffer $RH6  7181  933]
set RH8  [bsg_create_clock_buffer $RH7  7484  933]
set RH9  [bsg_create_clock_buffer $RH8  7782  933]
set RH10 [bsg_create_clock_buffer $RH9  8074  933]
set RH11 [bsg_create_clock_buffer $RH10 8374  933]
set RH12 [bsg_create_clock_buffer $RH11 8664  933]
set RH13 [bsg_create_clock_buffer $RH12 8959  933]
set RH14 [bsg_create_clock_buffer $RH13 9255  933]
set RH15 [bsg_create_clock_buffer $RH14 9561  933]


set REN0 [bsg_create_clock_buffer $RH15 9565 1028]
set REN1 [bsg_create_clock_buffer $REN0 9565 1123]
set REN2 [bsg_create_clock_buffer $REN1 9565 1218]
set REN3 [bsg_create_clock_buffer $REN2 9565 1313]
set REN4 [bsg_create_clock_buffer $REN3 9565 1408]
set REN5 [bsg_create_clock_buffer $REN4 9565 1502]
set REN6 [bsg_create_clock_buffer $REN5 9565 1598]
set REN7 [bsg_create_clock_buffer $REN6 9565 1700]
bsg_connect_sinks $REN1 [get_pins {sdr_e_y_3__sdr_e/core_clk_i sdr_e_y_2__sdr_e/core_clk_i}]
bsg_connect_sinks $REN5 [get_pins {sdr_e_y_1__sdr_e/core_clk_i sdr_e_y_0__sdr_e/core_clk_i}]
bsg_connect_sinks $REN7 [get_pins "sdr_ne/core_clk_i"]

set RES0 [bsg_create_clock_buffer $RH15 9565 838]
set RES1 [bsg_create_clock_buffer $RES0 9565 743]
set RES2 [bsg_create_clock_buffer $RES1 9565 648]
set RES3 [bsg_create_clock_buffer $RES2 9565 552]
set RES4 [bsg_create_clock_buffer $RES3 9565 458]
set RES5 [bsg_create_clock_buffer $RES4 9565 363]
set RES6 [bsg_create_clock_buffer $RES5 9565 268]
set RES7 [bsg_create_clock_buffer $RES6 9565 168]
bsg_connect_sinks $RES1 [get_pins {sdr_e_y_4__sdr_e/core_clk_i sdr_e_y_5__sdr_e/core_clk_i}]
bsg_connect_sinks $RES5 [get_pins {sdr_e_y_6__sdr_e/core_clk_i sdr_e_y_7__sdr_e/core_clk_i}]
bsg_connect_sinks $RES7 [get_pins "sdr_se/core_clk_i"]



set RVS0 [bsg_create_clock_buffer $RH7  7186 838]
set RVS1 [bsg_create_clock_buffer $RVS0 7186 742]
set RVS2 [bsg_create_clock_buffer $RVS1 7186 648]
set RVS3 [bsg_create_clock_buffer $RVS2 7186 552]
set RVS4 [bsg_create_clock_buffer $RVS3 7186 458]
set RVS5 [bsg_create_clock_buffer $RVS4 7186 362]
set RVS6 [bsg_create_clock_buffer $RVS5 7186 268]
set RVS7 [bsg_create_clock_buffer $RVS6 7186 172]
set RVS8 [bsg_create_clock_buffer $RVS7 7186 106]
set RVS9 [bsg_create_clock_buffer $RVS8 7186 22.5]

set RVN0 [bsg_create_clock_buffer $RH7  7186 1028]
set RVN1 [bsg_create_clock_buffer $RVN0 7186 1123]
set RVN2 [bsg_create_clock_buffer $RVN1 7186 1217]
set RVN3 [bsg_create_clock_buffer $RVN2 7186 1312]
set RVN4 [bsg_create_clock_buffer $RVN3 7186 1408]
set RVN5 [bsg_create_clock_buffer $RVN4 7186 1503]
set RVN6 [bsg_create_clock_buffer $RVN5 7186 1598]
set RVN7 [bsg_create_clock_buffer $RVN6 7186 1693]
set RVN8 [bsg_create_clock_buffer $RVN7 7186 1771]
set RVN9 [bsg_create_clock_buffer $RVN8 7186 1844]


set RCL0 [bsg_create_clock_buffer $RH7  7028  933]
set RCL1 [bsg_create_clock_buffer $RCL0 6732  933]
set RCL2 [bsg_create_clock_buffer $RCL1 6433  933]
set RCL3 [bsg_create_clock_buffer $RCL2 6134  933]
bsg_connect_sinks $RCL3 [get_pins "podrow/px_2__pod/mc_y_2__mc_x_0__mc/clk_i"]
set RCR0 [bsg_create_clock_buffer $RH7  7335  933]
set RCR1 [bsg_create_clock_buffer $RCR0 7629  933]
set RCR2 [bsg_create_clock_buffer $RCR1 7925  933]
set RCR3 [bsg_create_clock_buffer $RCR2 8220  933]
bsg_connect_sinks $RCR3 [get_pins "podrow/px_3__pod/mc_y_2__mc_x_0__mc/clk_i"]

set RN1L0 [bsg_create_clock_buffer $RVN3  7028  1312]
set RN1L1 [bsg_create_clock_buffer $RN1L0 6732  1312]
set RN1L2 [bsg_create_clock_buffer $RN1L1 6433  1312]
set RN1L3 [bsg_create_clock_buffer $RN1L2  6134  1312]
bsg_connect_sinks $RN1L3 [get_pins "podrow/px_2__pod/mc_y_1__mc_x_0__mc/clk_i"]
set RN1R0 [bsg_create_clock_buffer $RVN3  7335  1312]
set RN1R1 [bsg_create_clock_buffer $RN1R0  7629  1312]
set RN1R2 [bsg_create_clock_buffer $RN1R1  7925  1312]
set RN1R3 [bsg_create_clock_buffer $RN1R2  8220  1312]
bsg_connect_sinks $RN1R3 [get_pins "podrow/px_3__pod/mc_y_1__mc_x_0__mc/clk_i"]

set RN2L0 [bsg_create_clock_buffer $RVN7   7028  1693]
set RN2L1 [bsg_create_clock_buffer $RN2L0  6732  1693]
set RN2L2 [bsg_create_clock_buffer $RN2L1  6433  1693]
set RN2L3 [bsg_create_clock_buffer $RN2L2  6134  1693]
bsg_connect_sinks $RN2L3 [get_pins "podrow/px_2__pod/mc_y_0__mc_x_0__mc/clk_i"]
set RN2R0 [bsg_create_clock_buffer $RVN7   7335  1693]
set RN2R1 [bsg_create_clock_buffer $RN2R0  7629  1693]
set RN2R2 [bsg_create_clock_buffer $RN2R1  7925  1693]
set RN2R3 [bsg_create_clock_buffer $RN2R2  8220  1693]
bsg_connect_sinks $RN2R3 [get_pins "podrow/px_3__pod/mc_y_0__mc_x_0__mc/clk_i"]

set RN3L0 [bsg_create_clock_buffer $RVN9   7028  1844]
set RN3L1 [bsg_create_clock_buffer $RN3L0  6732  1844]
set RN3L2 [bsg_create_clock_buffer $RN3L1  6433  1844]
set RN3L3 [bsg_create_clock_buffer $RN3L2  6134  1844]
bsg_connect_sinks $RN3L3 [get_pins {podrow/px_2__pod/north_vc_x_0__north_vc_row/clk_i sdr_n_x_2__sdr_n/core_clk_i}]
set RN3R0 [bsg_create_clock_buffer $RVN9   7335  1844]
set RN3R1 [bsg_create_clock_buffer $RN3R0  7629  1844]
set RN3R2 [bsg_create_clock_buffer $RN3R1  7925  1844]
set RN3R3 [bsg_create_clock_buffer $RN3R2  8220  1844]
bsg_connect_sinks $RN3R3 [get_pins {podrow/px_3__pod/north_vc_x_0__north_vc_row/clk_i sdr_n_x_3__sdr_n/core_clk_i}]


set RS1L0 [bsg_create_clock_buffer $RVS3   7028  552]
set RS1L1 [bsg_create_clock_buffer $RS1L0  6732  552]
set RS1L2 [bsg_create_clock_buffer $RS1L1  6433  552]
set RS1L3 [bsg_create_clock_buffer $RS1L2  6134  552]
bsg_connect_sinks $RS1L3 [get_pins "podrow/px_2__pod/mc_y_3__mc_x_0__mc/clk_i"]
set RS1R0 [bsg_create_clock_buffer $RVS3   7335  552]
set RS1R1 [bsg_create_clock_buffer $RS1R0  7629  552]
set RS1R2 [bsg_create_clock_buffer $RS1R1  7925  552]
set RS1R3 [bsg_create_clock_buffer $RS1R2  8220  552]
bsg_connect_sinks $RS1R3 [get_pins "podrow/px_3__pod/mc_y_3__mc_x_0__mc/clk_i"]

set RS2L0 [bsg_create_clock_buffer $RVS7   7028  172]
set RS2L1 [bsg_create_clock_buffer $RS2L0  6732  172]
set RS2L2 [bsg_create_clock_buffer $RS2L1  6433  172]
set RS2L3 [bsg_create_clock_buffer $RS2L2  6134  172]
bsg_connect_sinks $RS2L3 [get_pins "podrow/px_2__pod/south_vc_x_0__south_vc_row/clk_i"]
set RS2R0 [bsg_create_clock_buffer $RVS7   7335  172]
set RS2R1 [bsg_create_clock_buffer $RS2R0  7629  172]
set RS2R2 [bsg_create_clock_buffer $RS2R1  7925  172]
set RS2R3 [bsg_create_clock_buffer $RS2R2  8220  172]
bsg_connect_sinks $RS2R3 [get_pins "podrow/px_3__pod/south_vc_x_0__south_vc_row/clk_i"]


set RS3L0 [bsg_create_clock_buffer $RVS9   7028  22.5]
set RS3L1 [bsg_create_clock_buffer $RS3L0  6732  22.5]
set RS3L2 [bsg_create_clock_buffer $RS3L1  6433  22.5]
set RS3L3 [bsg_create_clock_buffer $RS3L2  6134  22.5]
bsg_connect_sinks $RS3L3 [get_pins "sdr_s_x_2__sdr_s/core_clk_i"]
set RS3R0 [bsg_create_clock_buffer $RVS9   7335  22.5]
set RS3R1 [bsg_create_clock_buffer $RS3R0  7629  22.5]
set RS3R2 [bsg_create_clock_buffer $RS3R1  7925  22.5]
set RS3R3 [bsg_create_clock_buffer $RS3R2  8220  22.5]
bsg_connect_sinks $RS3R3 [get_pins "sdr_s_x_3__sdr_s/core_clk_i"]





# BSG TAG
set TAG0 [bsg_create_clock_buffer [get_ports "pod_tags_i[3]"]  2417 1870 0]
bsg_connect_sinks $TAG0 [get_pins "sdr_n_x_0__sdr_n/pod_tags_i_clk_"]
set TAG1 [bsg_create_clock_buffer [get_ports "pod_tags_i[7]"]  4796 1870 0]
bsg_connect_sinks $TAG1 [get_pins "sdr_n_x_1__sdr_n/pod_tags_i_clk_"]
set TAG2 [bsg_create_clock_buffer [get_ports "pod_tags_i[11]"] 7174 1870 0]
bsg_connect_sinks $TAG2 [get_pins "sdr_n_x_2__sdr_n/pod_tags_i_clk_"]
set TAG3 [bsg_create_clock_buffer [get_ports "pod_tags_i[15]"] 9553 1870 0]
bsg_connect_sinks $TAG3 [get_pins "sdr_n_x_3__sdr_n/pod_tags_i_clk_"]

