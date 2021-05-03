


proc bsg_create_clock_buffer {src x y} {
  set rd_x [round_down_to_nearest $x 0.084]
  set rd_y [round_down_to_nearest $y 0.48]

  set new_buffer [create_clock_buffer -clock "manycore_clk" \
                             -source $src \
                             -location [list $rd_x $rd_y]]
  set_size_only [get_cells $new_buffer] true
  set_dont_touch [get_nets -of $src] true

  return [get_pins -of $new_buffer -filter "name=~Z"]
}

proc bsg_split_clock_tree {src x1 y1 x2 y2} {
  set rd_x1 [round_down_to_nearest $x1 0.084]
  set rd_y1 [round_down_to_nearest $y1 0.48]
  set rd_x2 [round_down_to_nearest $x2 0.084]
  set rd_y2 [round_down_to_nearest $y2 0.48]
  
  set src_net [get_nets -of $src]

  set new_buffer1 [create_clock_buffer -clock "manycore_clk" \
                             -source $src \
                             -location [list $rd_x1 $rd_y1]]
  set new_buffer1_input_pin [get_pins -of $new_buffer1 -filter "name=~CLK"]
  disconnect_net -net $src_net $new_buffer1_input_pin

  set new_buffer2 [create_clock_buffer -clock "manycore_clk" \
                             -source $src \
                             -location [list $rd_x2 $rd_y2]]
  set new_buffer2_input_pin [get_pins -of $new_buffer2 -filter "name=~CLK"]
  disconnect_net -net $src_net $new_buffer2_input_pin

  connect_net -net $src_net [list $new_buffer1_input_pin $new_buffer2_input_pin]
  
  set out_pin1 [get_pins -of $new_buffer1 -filter "name=~Z"]
  set out_pin2 [get_pins -of $new_buffer2 -filter "name=~Z"]
  return {$out_pin1 $out_pin2}
}

remove_cells [get_cells cts_guide*]
set lv0 [bsg_create_clock_buffer [get_ports clk_i] 1186 374]
set lv1 [bsg_create_clock_buffer $lv0 1186 300]
set lv2 [bsg_create_clock_buffer $lv1 1186 250]
set lv3 [bsg_create_clock_buffer $lv2 1186 200]

#set split0 [bsg_split_clock_tree $lv3 1052 200 1310 200]
#set left0  [lindex $split0 0 ]
#set right0 [lindex $split0 1 ]


