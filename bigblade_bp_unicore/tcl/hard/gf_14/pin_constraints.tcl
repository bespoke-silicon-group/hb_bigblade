puts "BSG-info: Running script [info script]\n"

########################################
## Source common scripts
source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_common_variables.tcl

remove_individual_pin_constraints
remove_block_pin_constraints

# Useful numbers for the master tile
set core_width [core_width]
set core_height [core_height]

set core_llx [get_attribute [get_core_area] bounding_box.ll_x]
set core_lly [get_attribute [get_core_area] bounding_box.ll_y]
set core_urx [get_attribute [get_core_area] bounding_box.ur_x]
set core_ury [get_attribute [get_core_area] bounding_box.ur_y]

set k_pitch 0.128
set c_pitch 0.160

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
for {set i 0} {$i < 3} {incr i} {
    puts "Placing link $i, offset $block_offset, tile pitch $mc_tile_pitch"
    foreach line [split $contents] {
      if {$line  == ""} break
      set pin [lindex [split $line ,] 0]
      set rel_pos [lindex [split $line ,] 1]
      set abs_pos [expr $block_offset + $i*$mc_tile_pitch + $rel_pos]
      set layer [lindex [split $line ,] 2]
      puts "Placing $pin $abs_pos $layer"
      set_individual_pin_constraints \
          -ports [get_ports $pin] \
          -allowed_layers [get_layers $layer] \
          -location "$core_urx $abs_pos"
    }
}

puts "BSG-info: Completed script [info script]\n"

