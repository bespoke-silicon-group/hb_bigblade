puts "BSG-info: Running script [info script]\n"

########################################
## Source common scripts
source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_common_variables.tcl

remove_individual_pin_constraints
remove_block_pin_constraints


  # Useful numbers for the master tile
  set core_width [core_width]
  set core_height [core_height]
 
  set core_margin_t 0
  set core_margin_b 0
  set core_margin_r 0
  set core_margin_l 0
 
  set core_llx [get_attribute [get_core_area] bounding_box.ll_x]
  set core_lly [get_attribute [get_core_area] bounding_box.ll_y]
  set core_urx [get_attribute [get_core_area] bounding_box.ur_x]
  set core_ury [get_attribute [get_core_area] bounding_box.ur_y]
  
  set k_pitch 0.128
  set c_pitch 0.160
 
  set array_margin 12
  set welltab_margin 3

  set reserved_width 56
  # set reserved_height 20

  # PE array
  set pe_width  [round_up_to_nearest 50 [unit_width]]
  set pe_height [round_up_to_nearest 85 [unit_height]]

  set pe_num_x 8
  set pe_num_y 8

  set pe_width  50
  set pe_height 74.5
  set pe_margin_x 2
  set pe_margin_y 2

  set pe_origin_x [expr $core_margin_l+$welltab_margin+$reserved_width+$array_margin]
  set pe_origin_y [expr $core_margin_b+$welltab_margin+$array_margin]

  set array_width  [expr $pe_num_x*$pe_width + ($pe_num_x-1)*$pe_margin_x]
  set array_height [expr $pe_num_y*$pe_height+ ($pe_num_y-1)*$pe_margin_y]

  set sp_lx [expr $core_margin_l+$welltab_margin+1]
  set sp_ly [expr $core_margin_b+$welltab_margin+$array_margin]
  set sp_rx [expr $sp_lx+$reserved_width]
  set sp_ry [expr $sp_ly+$array_margin+$array_height]

  set rf_width 54
  set rf_height 83
  set rf_margin [expr ($sp_ry-$sp_ly)/4-$rf_height]

  set total_width  [expr $core_margin_l+$core_margin_r+$welltab_margin*2+$reserved_width+$array_margin+$array_width]
  set total_height [expr $core_margin_b+$core_margin_t+$welltab_margin*2+$array_margin+$array_height+$array_margin]
 
  set                  misc_pins [get_ports -filter "name=~clk_i"]
  append_to_collection misc_pins [get_ports -filter "name=~reset_i"]
  append_to_collection misc_pins [get_ports -filter "name=~global_y_cord_i*"]
  append_to_collection misc_pins [get_ports -filter "name=~async_*"]
  
  set misc_pins_len [expr [sizeof_collection $misc_pins]]
  set start_x [expr ($core_width / 2)  - (2*$c_pitch*$misc_pins_len/2)]
  set last_loc [bsg_pins_line_constraint $misc_pins "C5" top $start_x "self" {} 2 0]
  
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
        set pin_base [regsub -all {\[.*\]} $pin {}]
        if {$pin != $pin_base} {
          set pin_index [lindex [split $pin {\[.*\]}] 1]
          set pin_len [expr [sizeof_collection [get_ports $pin_base[*]]] / 4]
          set true_pin_index [expr $i*$pin_len + $pin_index]
          set true_pin ${pin_base}[$true_pin_index]
        } else {
          set true_pin_index [expr $i]
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

  set num_misc_pins [expr [llength $misc_pins]]
  set misc_spacing  [expr 4*0.16]
  set start_y [expr $pe_height/2 - $misc_spacing*$num_misc_pins/2]
  set last_loc [bsg_pins_line_constraint $misc_pins "C4" left $start_y $master_pe "" 2 0]

  #-------------------------------------------------------------------------
  # Cfg pins
  #-------------------------------------------------------------------------
  set pins_cfg_in [get_pins -hier $master_pe/* -filter "name=~cfg_in*"]
  set pins_cfg_out [get_pins -hier $master_pe/* -filter "name=~cfg_out*"]
  set cfg_pins_len [expr [llength $pins_cfg_in]]

  set cfg_spacing [expr 4*0.16]
  set start_x [expr $pe_width/2 - $cfg_pins_len*$cfg_spacing/2]
  set last_loc [bsg_pins_line_constraint $pins_cfg_in "C5" top $start_x $master_pe $pins_cfg_out 2 2]

  #-------------------------------------------------------------------------
  # Msg  pins
  #-------------------------------------------------------------------------
  set msg_pins_i [get_pins -hier $master_pe/* -filter "name=~in__*"]
  set msg_pins_o [get_pins -hier $master_pe/* -filter "name=~out__*"]
  set msg_pin_len [expr [sizeof_collection $msg_pins_o] / 4]

  set msg_pins_o_N [index_collection $msg_pins_o [expr 0*$msg_pin_len] [expr 1*$msg_pin_len-1]]
  set msg_pins_i_N [index_collection $msg_pins_i [expr 0*$msg_pin_len] [expr 1*$msg_pin_len-1]]
  set msg_pins_o_S [index_collection $msg_pins_o [expr 1*$msg_pin_len] [expr 2*$msg_pin_len-1]]
  set msg_pins_i_S [index_collection $msg_pins_i [expr 1*$msg_pin_len] [expr 2*$msg_pin_len-1]]
  set msg_pins_o_W [index_collection $msg_pins_o [expr 2*$msg_pin_len] [expr 3*$msg_pin_len-1]]
  set msg_pins_i_W [index_collection $msg_pins_i [expr 2*$msg_pin_len] [expr 3*$msg_pin_len-1]]
  set msg_pins_o_E [index_collection $msg_pins_o [expr 3*$msg_pin_len] [expr 4*$msg_pin_len-1]]
  set msg_pins_i_E [index_collection $msg_pins_i [expr 3*$msg_pin_len] [expr 4*$msg_pin_len-1]]

  set msg_spacing [expr 0.128*4]
  set start_y [expr $pe_height/2 - $msg_spacing*$msg_pin_len/2]
  set start_x [expr $pe_width/2 - $msg_spacing*$msg_pin_len/2]

  set last_loc [bsg_pins_line_constraint $msg_pins_o_N "K2 K4" top $start_x $master_pe $msg_pins_i_S 2 2]
  set last_loc [bsg_pins_line_constraint $msg_pins_i_N "K2 K4" top $last_loc $master_pe $msg_pins_o_S 2 2]
  set last_loc [bsg_pins_line_constraint $msg_pins_o_E "K1 K3" right $start_y $master_pe $msg_pins_i_W 2 2]
  set last_loc [bsg_pins_line_constraint $msg_pins_i_E "K1 K3" right $last_loc $master_pe $msg_pins_o_W 2 2]

puts "BSG-info: Completed script [info script]\n"

