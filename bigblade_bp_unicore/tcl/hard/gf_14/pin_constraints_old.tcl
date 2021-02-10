remove_individual_pin_constraints
remove_block_pin_constraints

# Useful numbers for the master tile
set tile_width  [core_width]
set tile_height [core_height]

set keepout_margin_x [expr 6*[unit_width]]
set keepout_margin_y [expr 1*[unit_height]]
set keepout_margins [list $keepout_margin_x $keepout_margin_y $keepout_margin_x $keepout_margin_y]

set k_pitch 0.128
set c_pitch 0.160

set ver_link_pins_i [get_ports -filter "name=~mc_ver_links_i*"]
set ver_link_pins_o [get_ports -filter "name=~mc_ver_links_o*"]

set ver_link_pin_len  [expr [sizeof_collection $ver_link_pins_i ] / 2]

set link_pin_i_N [index_collection $ver_link_pins_i [expr 1*$ver_link_pin_len] [expr 2*$ver_link_pin_len-1]]
set link_pin_o_N [index_collection $ver_link_pins_o [expr 1*$ver_link_pin_len] [expr 2*$ver_link_pin_len-1]]
set link_pin_i_S [index_collection $ver_link_pins_i [expr 0*$ver_link_pin_len] [expr 1*$ver_link_pin_len-1]]
set link_pin_o_S [index_collection $ver_link_pins_o [expr 0*$ver_link_pin_len] [expr 1*$ver_link_pin_len-1]]

set link_pin_N $link_pin_i_N
append_to_collection link_pin_N $link_pin_o_N
set link_pin_S $link_pin_o_S
append_to_collection link_pin_S $link_pin_i_S

set dcache_stat_mem [get_cells -hier -filter "ref_name=~gf14_* && full_name=~*dcache*stat_mem*"]
set dcache_tag_mems [get_cells -hier -filter "ref_name=~gf14_* && full_name=~*dcache*tag_mem*"]
set dcache_data_mems_east [index_collection [get_cells -hier -filter "ref_name=~gf14_* && full_name=~*dcache*data_mem*"] 4 7]
set fp_regfile_mems [get_cells -hier -filter "ref_name=~gf14_* && full_name=~*/fp_regfile/*"]

set stat_mem_width    [lindex [get_attribute [get_cell -hier $dcache_stat_mem] width ] 0]
set tag_mem_width     [lindex [get_attribute [get_cell -hier $dcache_tag_mems] width ] 0]
set data_mem_width    [lindex [get_attribute [get_cell -hier $dcache_data_mems_east] width ] 0]
set freg_mem_width    [lindex [get_attribute [get_cell -hier $fp_regfile_mems] width ] 0]

set link_pin_N_len [sizeof_collection $link_pin_N]
set start_x [expr $tile_width - $k_pitch*($link_pin_N_len+10)]
set last_loc [bsg_pins_line_constraint $link_pin_N "K2 K4" top $start_x "self" $link_pin_S 1 0]

set                  misc_pins [get_ports -filter "name=~*clk*"]
append_to_collection misc_pins [get_ports -filter "name=~*reset*"]
append_to_collection misc_pins [get_ports -filter "name=~*bsg_tag*"]

set misc_pins_len [expr [sizeof_collection $misc_pins]]
set start_x [expr ($tile_width / 2)  - (2*$c_pitch*$misc_pins_len/2)]
set last_loc [bsg_pins_line_constraint $misc_pins "C5" top $start_x "self" {} 2 0]

# Read horizontal pins from csv file

set fh [open $::env(BSG_DESIGNS_TARGET_DIR)/tcl/hard/gf_14/bp_pin_y.csv r]
set contents [read $fh]

set i 0
foreach line [split $contents] {
  set pin [lindex [split $line ,] 0]
  set pos [lindex [split $line ,] 1]

  if {$i % 2 == 0} {
    set layer "K1"
  } else {
    set layer "K3"
  }
  incr i

  #puts "Placing $pin $layer $pos"
  if {$line  == ""} break
  set_individual_pin_constraints -ports [get_ports $pin] -allowed_layers [get_layers $layer] -location "$tile_width $pos"
}

