puts "BSG-info: Running script [info script]\n"

source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_common_variables.tcl

remove_individual_pin_constraints
remove_block_pin_constraints

set_block_pin_constraints -allowed_layers {C4 C5 K1 K2 K3 K4}

set match_ports [list]
append_to_collection match_ports [get_ports "reset_*"]
append_to_collection match_ports [get_ports "ver_link_sif_*"]
append_to_collection match_ports [get_ports "global_*_*"]

for {set i 0} {$i < [expr $HB_LINK_WIDTH_P*$HB_SUBARRAY_NUM_TILES_Y_P]} {incr i} {
  append_to_collection match_ports [get_ports "hor_link_sif_i[$i]"]
  append_to_collection match_ports [get_ports "hor_link_sif_o[$i]"]
}
for {set i 0} {$i < [expr $HB_RUCHE_LINK_WIDTH_P*$HB_RUCHE_FACTOR_P*$HB_SUBARRAY_NUM_TILES_Y_P]} {incr i} {
  append_to_collection match_ports [get_ports "ruche_link_i[$i]"]
  append_to_collection match_ports [get_ports "ruche_link_o[$i]"]
}


bsg_create_macro_matching_ports $match_ports true

set_individual_pin_constraints -ports [get_ports clk_i] -allowed_layers K4 -location "[expr 0.128*9225] [die_ury]"
#set_individual_pin_constraints -ports [get_ports clk_i[0]] -allowed_layers K4 -location "[expr 0.128*4584] [die_ury]"
#set_individual_pin_constraints -ports [get_ports clk_i[1]] -allowed_layers K4 -location "[expr 0.128*13824] [die_ury]"



# place pins on the east side

proc place_ruche_pins_k1_k3 {pins start_y x} {
  set i 0
  set curr_y $start_y

  while {$i < [sizeof_collection $pins]} {

    set pin [index_collection $pins $i]

    set layer ""
    if {$i % 2 == 0} {
      set layer "K1"
    } else {
      set layer "K3"
    }

    if { [bsg_pins_check_location $x $curr_y $layer] == 1} {
      set_individual_pin_constraints -ports $pin -allowed_layers $layer -location "$x $curr_y"
      incr i
    } else {
      set check_below [bsg_pins_check_location $x [expr $curr_y - 0.128] $layer]
      set check_above [bsg_pins_check_location $x [expr $curr_y + 0.128] $layer]
      if {$check_below == 1 || $check_above == 1} {
        set_individual_pin_constraints -ports $pin -allowed_layers $layer -location "$x $curr_y"
        incr i
      }
    }

    set curr_y [expr $curr_y + 0.128]
  }
}




for {set y 0} {$y < $HB_SUBARRAY_NUM_TILES_Y_P} {incr y} {
  set in_ports [list]
  set out_ports [list]
  set base_ruche_idx [expr 840 + ($y*3*140)]
  set base_idx [expr 308 + ($y*154)]

  for {set i 0} {$i < $HB_RUCHE_LINK_WIDTH_P} {incr i} {
    set idx [expr 0*$HB_LINK_WIDTH_P + $i + $base_idx]
    append_to_collection out_ports [get_ports "hor_link_sif_o[${idx}]"]
    set idx [expr 1*$HB_RUCHE_LINK_WIDTH_P + $i + $base_ruche_idx]
    append_to_collection out_ports [get_ports "ruche_link_o[${idx}]"]
    set idx [expr 2*$HB_RUCHE_LINK_WIDTH_P + $i + $base_ruche_idx]
    append_to_collection out_ports [get_ports "ruche_link_o[${idx}]"]
    set idx [expr 0*$HB_RUCHE_LINK_WIDTH_P + $i + $base_ruche_idx]
    append_to_collection out_ports [get_ports "ruche_link_o[${idx}]"]

    set idx [expr 0*$HB_LINK_WIDTH_P + $i + $base_idx]
    append_to_collection in_ports [get_ports "hor_link_sif_i[${idx}]"]
    set idx [expr 1*$HB_RUCHE_LINK_WIDTH_P + $i + $base_ruche_idx]
    append_to_collection in_ports [get_ports "ruche_link_i[${idx}]"]
    set idx [expr 2*$HB_RUCHE_LINK_WIDTH_P + $i + $base_ruche_idx]
    append_to_collection in_ports [get_ports "ruche_link_i[${idx}]"]
    set idx [expr 0*$HB_RUCHE_LINK_WIDTH_P + $i + $base_ruche_idx]
    append_to_collection in_ports [get_ports "ruche_link_i[${idx}]"]
  }

  for {set i $HB_RUCHE_LINK_WIDTH_P} {$i < $HB_LINK_WIDTH_P} {incr i} {
    set idx [expr 0*$HB_LINK_WIDTH_P + $i + $base_idx]
    append_to_collection out_ports [get_ports "hor_link_sif_o[${idx}]"]
    set idx [expr 0*$HB_LINK_WIDTH_P + $i + $base_idx]
    append_to_collection in_ports [get_ports "hor_link_sif_i[${idx}]"]
  
  }
  
  set input_start_y   [expr ((1-$y)*($tile_height+$tile_y_space))+$TILE_WEST_OUTPUT_OFFSET]
  set output_start_y  [expr ((1-$y)*($tile_height+$tile_y_space))+$TILE_WEST_INPUT_OFFSET]

  place_ruche_pins_k1_k3 $in_ports $input_start_y $tile_array_width
  place_ruche_pins_k1_k3 $out_ports $output_start_y $tile_array_width
}






puts "BSG-info: Completed script [info script]\n"
