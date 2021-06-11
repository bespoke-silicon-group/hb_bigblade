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
          set true_pin ${pin_base}[$true_pin_index]
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

puts "BSG-info: Completed script [info script]\n"