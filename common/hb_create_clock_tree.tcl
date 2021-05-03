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
    set_dont_touch $src_net
    incr bsg_cts_i
  } else {
    connect_net -net $src_net $sinks
  }
}


