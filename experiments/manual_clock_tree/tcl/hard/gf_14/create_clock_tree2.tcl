set bsg_cts_i 0

proc bsg_create_clock_buffer {src x y} {
  global bsg_cts_i
  set rd_x [round_down_to_nearest $x 0.084]
  set rd_y [round_down_to_nearest $y 0.48]

  # create buffer cell
  set cell_name "bsg_cts_${bsg_cts_i}"
  set buffer_cell [create_cell $cell_name "IN14LPP_SC7P5T_84CPP_BASE_SSC16R/SC7P5T_CKBUFX16_SSC16R"]
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
    #set_dont_touch $src_net true
  } else {
    connect_net -net $src_net [list $buffer_input_pin]
    #set_dont_touch $src_net true
  }

  incr bsg_cts_i
  return $buffer_output_pin
}

proc bsg_connect_sinks {src sinks} {
  global bsg_cts_i

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

disconnect_net [get_net "clk_i"] -all
#remove_cells [get_cells "bsg_cts_*"]
#remove_nets [get_nets "bsg_cts_net_*"]
set lv0 [bsg_create_clock_buffer [get_ports clk_i] 1186 374]
set lv1 [bsg_create_clock_buffer $lv0 1186 300]
set lv2 [bsg_create_clock_buffer $lv1 1186 250]
set lv3 [bsg_create_clock_buffer $lv2 1186 200]


set left0 [bsg_create_clock_buffer $lv3   1052 200]
set left1 [bsg_create_clock_buffer $left0 932 200]
set left2 [bsg_create_clock_buffer $left1 790 200]
set left3 [bsg_create_clock_buffer $left2 647 200]

set left_left0 [bsg_create_clock_buffer $left3 530 200]
set left_left1 [bsg_create_clock_buffer $left_left0 392 200]
set left_left_sinks [list]
append_to_collection left_left_sinks [get_pins "data_r_reg_0__0_/CLK"]
append_to_collection left_left_sinks [get_pins "data_r_reg_0__1_/CLK"]
append_to_collection left_left_sinks [get_pins "data_r_reg_1__0_/CLK"]
append_to_collection left_left_sinks [get_pins "data_r_reg_1__1_/CLK"]
bsg_connect_sinks $left_left1 $left_left_sinks

set left_right0 [bsg_create_clock_buffer $left3 792 201]
set left_right1 [bsg_create_clock_buffer $left_right0 930 201]
set left_right_sinks [list]
append_to_collection left_right_sinks [get_pins "data_r_reg_2__0_/CLK"]
append_to_collection left_right_sinks [get_pins "data_r_reg_2__1_/CLK"]
append_to_collection left_right_sinks [get_pins "data_r_reg_3__0_/CLK"]
append_to_collection left_right_sinks [get_pins "data_r_reg_3__1_/CLK"]
bsg_connect_sinks $left_right1 $left_right_sinks


set right0 [bsg_create_clock_buffer $lv3    1310 200]
set right1 [bsg_create_clock_buffer $right0 1449 200]
set right2 [bsg_create_clock_buffer $right1 1577 200]
set right3 [bsg_create_clock_buffer $right2 1720 200]

set right_right0 [bsg_create_clock_buffer $right3 1838 200]
set right_right1 [bsg_create_clock_buffer $right_right0 1984 200]
set right_right_sinks [list]
append_to_collection right_right_sinks [get_pins "data_r_reg_6__0_/CLK"]
append_to_collection right_right_sinks [get_pins "data_r_reg_6__1_/CLK"]
append_to_collection right_right_sinks [get_pins "data_r_reg_7__0_/CLK"]
append_to_collection right_right_sinks [get_pins "data_r_reg_7__1_/CLK"]
bsg_connect_sinks $right_right1 $right_right_sinks

set right_left0 [bsg_create_clock_buffer $right3 1575 201]
set right_left1 [bsg_create_clock_buffer $right_left0 1441 201]
set right_left_sinks [list]
append_to_collection right_left_sinks [get_pins "data_r_reg_4__0_/CLK"]
append_to_collection right_left_sinks [get_pins "data_r_reg_4__1_/CLK"]
append_to_collection right_left_sinks [get_pins "data_r_reg_5__0_/CLK"]
append_to_collection right_left_sinks [get_pins "data_r_reg_5__1_/CLK"]
bsg_connect_sinks $right_left1 $right_left_sinks





