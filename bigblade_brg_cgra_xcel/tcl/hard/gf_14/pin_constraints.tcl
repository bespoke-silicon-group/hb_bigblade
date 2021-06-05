puts "BSG-info: Running script [info script]\n"

########################################
## Source common scripts
source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_common_variables.tcl

  remove_individual_pin_constraints
  remove_block_pin_constraints
  #remove_placement_blockages -all
  #remove_routing_blockages -all

  # Useful numbers for the master tile
  set core_width [core_width]
  set core_height [core_height]
 
  set core_llx [get_attribute [get_core_area] bounding_box.ll_x]
  set core_lly [get_attribute [get_core_area] bounding_box.ll_y]
  set core_urx [get_attribute [get_core_area] bounding_box.ur_x]
  set core_ury [get_attribute [get_core_area] bounding_box.ur_y]
  
  set k_pitch 0.128
  set c_pitch 0.160

  set clk_pins [get_ports -filter "name=~clk_i"]
  set start_x [expr $core_width / 16]
  set last_loc [bsg_pins_line_constraint $clk_pins "C5" top $start_x "self" {} 1 1 1]

  set misc_pins [get_ports -filter "name=~tag_*"]
  set misc_pins_len [expr [sizeof_collection $misc_pins]]
  set start_x [expr 15 * $core_width / 16]
  set last_loc [bsg_pins_line_constraint $misc_pins "C5" bottom $start_x "self" {} 1 1 1]
  
  # Read horizontal pins from csv file
  set fh [open $::env(BSG_DESIGNS_TARGET_DIR)/../common/sdr_pin_y.csv]
  set contents [read $fh]
  
  set block_offset $core_lly
  set mc_tile_pitch [expr $tile_y_space + $tile_height]
  for {set i 0} {$i < 4} {incr i} {
      puts "Placing link $i, offset $block_offset, tile pitch $mc_tile_pitch"
      foreach line [split $contents] {
        if {$line  == ""} break
        set pin [lindex [split $line ,] 0]
        set pin_base $pin
        set pin_base [regsub -all {\[.*\]} $pin_base {}     ]
        set pin_base [regsub -all {_o$}    $pin_base {_itmp}]
        set pin_base [regsub -all {_i$}    $pin_base {_o}   ]
        set pin_base [regsub -all {_itmp$} $pin_base {_i}   ]

        if {[string length $pin] != [string length $pin_base]} {
          set pin_index [lindex [split $pin {\[.*\]}] 1]
          set pin_len [expr [sizeof_collection [get_ports $pin_base[*]]] / 4]
          set true_pin_index [expr (3-$i)*$pin_len + $pin_index]
          set true_pin ${pin_base}[$true_pin_index]
        } else {
          set true_pin_index [expr 3-$i]
          set true_pin ${pin_base}[$i]
        }
        set pos [lindex [split $line ,] 1]
        set true_pos [expr $block_offset + $i*$mc_tile_pitch + $pos]
        set layer [lindex [split $line ,] 2]
        puts "Placing $pin $pin_base $true_pos $layer"
        set_individual_pin_constraints \
            -ports [get_ports $true_pin] \
            -allowed_layers [get_layers $layer] \
            -location "$core_llx $true_pos"
      }
  }

  #-------------------------------------------------------------------------
  # MISC pins
  #-------------------------------------------------------------------------
  set master_pe "PE_rc__0"

  set pe_llx [lindex [get_attribute [get_cell -hier $master_pe] boundary_bbox] 0 0]
  set pe_lly [lindex [get_attribute [get_cell -hier $master_pe] boundary_bbox] 0 1]
  set pe_width [get_attribute [get_cell -hier $master_pe] width]
  set pe_height [get_attribute [get_cell -hier $master_pe] height]
  set pe_left   $pe_llx
  set pe_right  [expr $pe_llx+$pe_width]
  set pe_bottom $pe_lly
  set pe_top    [expr $pe_lly+$pe_height]

  set misc_pins {}
  append_to_collection misc_pins [get_pins -hier $master_pe/* -filter "name=~clk*"]
  append_to_collection misc_pins [get_pins -hier $master_pe/* -filter "name=~reset*"]
  append_to_collection misc_pins [get_pins -hier $master_pe/* -filter "name=~is_calc*"]
  append_to_collection misc_pins [get_pins -hier $master_pe/* -filter "name=~is_occupied*"]
  append_to_collection misc_pins [get_pins -hier $master_pe/* -filter "name=~x_cord*"]
  append_to_collection misc_pins [get_pins -hier $master_pe/* -filter "name=~y_cord*"]
  set misc_pins_len [sizeof_collection $misc_pins]

  set start_y [expr ($pe_height/2) - (2*$c_pitch*$misc_pins_len/2)]
  set last_loc [bsg_pins_line_constraint $misc_pins "C4" left $start_y $master_pe "" 1 1 1]

  #-------------------------------------------------------------------------
  # Cfg pins
  #-------------------------------------------------------------------------
  set pins_cfg_in [get_pins -hier $master_pe/* -filter "name=~cfg_in*"]
  set pins_cfg_out [get_pins -hier $master_pe/* -filter "name=~cfg_out*"]
  set cfg_pins_len [sizeof_collection $pins_cfg_in]

  set start_x [expr ($pe_width/2) - (2*$c_pitch*$cfg_pins_len/2)]
  set last_loc [bsg_pins_line_constraint $pins_cfg_out "C5" top $start_x $master_pe $pins_cfg_in 1 1 1]

  #-------------------------------------------------------------------------
  # Msg  pins
  #-------------------------------------------------------------------------
  set msg_pins_i [get_pins -hier $master_pe/* -filter "name=~in___msg*"]
  set msg_pins_o [get_pins -hier $master_pe/* -filter "name=~out__msg*"]
  set msg_pin_len [expr [sizeof_collection $msg_pins_o] / 4]

  set msg_pins_o_N [index_collection $msg_pins_o [expr 0*$msg_pin_len] [expr 1*$msg_pin_len-1]]
  append_to_collection msg_pins_o_N [get_pins -hier $master_pe/* -filter "name=~out__val[3]"]
  append_to_collection msg_pins_o_N [get_pins -hier $master_pe/* -filter "name=~in___rdy[3]"]
  set msg_pins_i_N [index_collection $msg_pins_i [expr 0*$msg_pin_len] [expr 1*$msg_pin_len-1]]
  append_to_collection msg_pins_i_N [get_pins -hier $master_pe/* -filter "name=~in___val[3]"]
  append_to_collection msg_pins_i_N [get_pins -hier $master_pe/* -filter "name=~out__rdy[3]"]
  set msg_pins_o_S [index_collection $msg_pins_o [expr 1*$msg_pin_len] [expr 2*$msg_pin_len-1]]
  append_to_collection msg_pins_o_S [get_pins -hier $master_pe/* -filter "name=~out__val[2]"]
  append_to_collection msg_pins_o_S [get_pins -hier $master_pe/* -filter "name=~in___rdy[2]"]
  set msg_pins_i_S [index_collection $msg_pins_i [expr 1*$msg_pin_len] [expr 2*$msg_pin_len-1]]
  append_to_collection msg_pins_i_S [get_pins -hier $master_pe/* -filter "name=~in___val[2]"]
  append_to_collection msg_pins_i_S [get_pins -hier $master_pe/* -filter "name=~out__rdy[2]"]
  set msg_pins_o_W [index_collection $msg_pins_o [expr 2*$msg_pin_len] [expr 3*$msg_pin_len-1]]
  append_to_collection msg_pins_o_W [get_pins -hier $master_pe/* -filter "name=~out__val[1]"]
  append_to_collection msg_pins_o_W [get_pins -hier $master_pe/* -filter "name=~in___rdy[1]"]
  set msg_pins_i_W [index_collection $msg_pins_i [expr 2*$msg_pin_len] [expr 3*$msg_pin_len-1]]
  append_to_collection msg_pins_i_W [get_pins -hier $master_pe/* -filter "name=~in___val[1]"]
  append_to_collection msg_pins_i_W [get_pins -hier $master_pe/* -filter "name=~out__rdy[1]"]
  set msg_pins_o_E [index_collection $msg_pins_o [expr 3*$msg_pin_len] [expr 4*$msg_pin_len-1]]
  append_to_collection msg_pins_o_E [get_pins -hier $master_pe/* -filter "name=~out__val[0]"]
  append_to_collection msg_pins_o_E [get_pins -hier $master_pe/* -filter "name=~in___rdy[0]"]
  set msg_pins_i_E [index_collection $msg_pins_i [expr 3*$msg_pin_len] [expr 4*$msg_pin_len-1]]
  append_to_collection msg_pins_i_E [get_pins -hier $master_pe/* -filter "name=~in___val[0]"]
  append_to_collection msg_pins_i_E [get_pins -hier $master_pe/* -filter "name=~out__rdy[0]"]

  set start_y [expr $pe_height/2 - (2*$k_pitch*$msg_pin_len/2)]
  set start_x [expr $pe_width/2 - (1*$k_pitch*$msg_pin_len/2)]

  set last_loc [bsg_pins_line_constraint $msg_pins_o_N "K1 K3" right  $start_y  $master_pe $msg_pins_i_S 1 0 1]
  set last_loc [bsg_pins_line_constraint $msg_pins_i_N "K1 K3" right  $last_loc $master_pe $msg_pins_o_S 1 0 1]
  set last_loc [bsg_pins_line_constraint $msg_pins_o_E "K2 K4" bottom $start_x  $master_pe $msg_pins_i_W 1 0 1]
  set last_loc [bsg_pins_line_constraint $msg_pins_i_E "K2 K4" bottom $last_loc $master_pe $msg_pins_o_W 1 0 1]

  remove_routing_blockages -all

puts "BSG-info: Completed script [info script]\n"

