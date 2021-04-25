puts "BSG-info: Running script [info script]\n"

source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_common_variables.tcl

remove_individual_pin_constraints
remove_block_pin_constraints

set_block_pin_constraints -allowed_layers {C4 C5 K1 K2 K3 K4}

set match_ports [list]
append_to_collection match_ports [get_ports "reset_*"]
append_to_collection match_ports [get_ports "ver_link_sif_*"]
append_to_collection match_ports [get_ports "global_*_*"]
for {set i 0} {$i < [expr $HB_WH_LINK_WIDTH_P*$HB_WH_RUCHE_FACTOR_P]} {incr i} {
  append_to_collection match_ports [get_ports "wh_link_sif_i[$i]"]
  append_to_collection match_ports [get_ports "wh_link_sif_o[$i]"]
}

bsg_create_macro_matching_ports $match_ports true
set_individual_pin_constraints -ports [get_ports clk_i] -allowed_layers K4 -location "[expr 0.128*9225] [die_ury]"
#set_individual_pin_constraints -ports [get_ports clk_i[0]] -allowed_layers K4 -location "[expr 0.128*4584] [die_ury]"
#set_individual_pin_constraints -ports [get_ports clk_i[1]] -allowed_layers K4 -location "[expr 0.128*13824] [die_ury]"




# place pins on the east side


proc place_wh_pins_k1_k3 {pins start_y x} {
  set i 0
  set curr_y $start_y
  set count 0

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
      incr count
    }

    if {$count == 2} {
      set curr_y [expr $curr_y + 0.128*2]
      set count 0
    }

    set curr_y [expr $curr_y + 0.128]
  }
}


set in_ports [list]
set out_ports [list]
set base_idx [expr ($HB_WH_LINK_WIDTH_P*$HB_WH_RUCHE_FACTOR_P)]
for {set i 0} {$i < $HB_WH_LINK_WIDTH_P} {incr i} {
  set idx [expr $base_idx + ($HB_WH_LINK_WIDTH_P*0) + $i]
  append_to_collection in_ports [get_ports "wh_link_sif_i[$idx]"]
  set idx [expr $base_idx + ($HB_WH_LINK_WIDTH_P*1) + $i]
  append_to_collection in_ports [get_ports "wh_link_sif_i[$idx]"]
  set idx [expr $base_idx + ($HB_WH_LINK_WIDTH_P*0) + $i]
  append_to_collection out_ports [get_ports "wh_link_sif_o[$idx]"]
  set idx [expr $base_idx + ($HB_WH_LINK_WIDTH_P*1) + $i]
  append_to_collection out_ports [get_ports "wh_link_sif_o[$idx]"]
}

place_wh_pins_k1_k3 $in_ports $VCACHE_WEST_OUTPUT_OFFSET $vcache_array_width
place_wh_pins_k1_k3 $out_ports $VCACHE_WEST_INPUT_OFFSET $vcache_array_width








puts "BSG-info: Completed script [info script]\n"
