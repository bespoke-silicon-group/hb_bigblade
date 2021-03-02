remove_individual_pin_constraints
remove_block_pin_constraints

# Useful numbers for the master tile
set tile_width  [core_width]
set tile_height [core_height]

set k_pitch 0.128
set c_pitch 0.160

set                  misc_pins [get_ports -filter "name=~clk_i"]
append_to_collection misc_pins [get_ports -filter "name=~reset_i"]
append_to_collection misc_pins [get_ports -filter "name=~global_y_cord_i*"]
append_to_collection misc_pins [get_ports -filter "name=~async_*"]

set misc_pins_len [expr [sizeof_collection $misc_pins]]
set start_x [expr ($tile_width / 2)  - (2*$c_pitch*$misc_pins_len/2)]
set last_loc [bsg_pins_line_constraint $misc_pins "C5" top $start_x "self" {} 2 0]

# Read horizontal pins from csv file

set hor_pins [get_ports -filter "name=~io_*link*"]
set hor_pins_len [expr [sizeof_collection $hor_pins]]

set start_y [expr ($tile_height / 2) - ($k_pitch*$hor_pins_len/2)]
#set start_y [expr 100]
set last_loc [bsg_pins_line_constraint $hor_pins "K1 K3" right $start_y "self" {} 1 0]

#set fh [open $::env(BSG_DESIGNS_TARGET_DIR)/tcl/hard/gf_14/bp_pin_y.csv r]
#set contents [read $fh]
#
#set i 0
#foreach line [split $contents] {
#  set pin [lindex [split $line ,] 0]
#  set pos [lindex [split $line ,] 1]
#
#  if {$i % 2 == 0} {
#    set layer "K1"
#  } else {
#    set layer "K3"
#  }
#  incr i
#
#  #puts "Placing $pin $layer $pos"
#  if {$line  == ""} break
#  set_individual_pin_constraints -ports [get_ports $pin] -allowed_layers [get_layers $layer] -location "$tile_width $pos"
#}

