source $::env(BSG_DESIGNS_TARGET_TCL_HARD_DIR)/hb_common_variables.tcl



proc place_ruche_pins_k1_k3 {pins start_y x going_up} {
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
      set_individual_pin_constraints -pins $pin -allowed_layers $layer -location "$x $curr_y"
      incr i
    } else {
      set check_below [bsg_pins_check_location $x [expr $curr_y - 0.128] $layer]
      set check_above [bsg_pins_check_location $x [expr $curr_y + 0.128] $layer]
      if {$check_below == 1 || $check_above == 1} {
        set_individual_pin_constraints -pins $pin -allowed_layers $layer -location "$x $curr_y"
        incr i
      }
    }
    if {$going_up == 1} {
      set curr_y [expr $curr_y + 0.128]
    } else {
      set curr_y [expr $curr_y - 0.128]
    }
  }
}


### MANYCORE TILE PIN PLACE   #########################
set master_tile   [get_cells "pod_mc_y_0__x_0__tile"]
set tile_llx      [get_attribute $master_tile boundary_bounding_box.ll_x]
set tile_lly      [get_attribute $master_tile boundary_bounding_box.ll_y]
set tile_urx      [get_attribute $master_tile boundary_bounding_box.ur_x]
set tile_ury      [get_attribute $master_tile boundary_bounding_box.ur_y]


# west output pins
set west_out_pins [list]
for {set i 0} {$i < $HB_RUCHE_LINK_WIDTH_P} {incr i} {
  set idx [expr 0*$HB_LINK_WIDTH_P + $i]
  append_to_collection west_out_pins [get_pins -filter "name=~link_o[${idx}]" -of_object $master_tile]
  set idx [expr 2*$HB_RUCHE_LINK_WIDTH_P + $i]
  append_to_collection west_out_pins [get_pins -filter "name=~ruche_link_o[${idx}]" -of_object $master_tile]
  set idx [expr 4*$HB_RUCHE_LINK_WIDTH_P + $i]
  append_to_collection west_out_pins [get_pins -filter "name=~ruche_link_o[${idx}]" -of_object $master_tile]
  set idx [expr 0*$HB_RUCHE_LINK_WIDTH_P + $i]
  append_to_collection west_out_pins [get_pins -filter "name=~ruche_link_o[${idx}]" -of_object $master_tile]
}

for {set i $HB_RUCHE_LINK_WIDTH_P} {$i < $HB_LINK_WIDTH_P} {incr i} {
  set idx [expr 0*$HB_LINK_WIDTH_P + $i]
  append_to_collection west_out_pins [get_pins -filter "name=~link_o[${idx}]" -of_object $master_tile]
}


# west input pins
set west_in_pins [list]
for {set i 0} {$i < $HB_RUCHE_LINK_WIDTH_P} {incr i} {
  set idx [expr 0*$HB_LINK_WIDTH_P + $i]
  append_to_collection west_in_pins [get_pins -filter "name=~link_i[${idx}]" -of_object $master_tile]
  set idx [expr 2*$HB_RUCHE_LINK_WIDTH_P + $i]
  append_to_collection west_in_pins [get_pins -filter "name=~ruche_link_i[${idx}]" -of_object $master_tile]
  set idx [expr 4*$HB_RUCHE_LINK_WIDTH_P + $i]
  append_to_collection west_in_pins [get_pins -filter "name=~ruche_link_i[${idx}]" -of_object $master_tile]
  set idx [expr 0*$HB_RUCHE_LINK_WIDTH_P + $i]
  append_to_collection west_in_pins [get_pins -filter "name=~ruche_link_i[${idx}]" -of_object $master_tile]
}

for {set i $HB_RUCHE_LINK_WIDTH_P} {$i < $HB_LINK_WIDTH_P} {incr i} {
  set idx [expr 0*$HB_LINK_WIDTH_P + $i]
  append_to_collection west_in_pins [get_pins -filter "name=~link_i[${idx}]" -of_object $master_tile]
}


# east input pins
set east_in_pins [list]
for {set i 0} {$i < $HB_RUCHE_LINK_WIDTH_P} {incr i} {
  set idx [expr 1*$HB_LINK_WIDTH_P + $i]
  append_to_collection east_in_pins [get_pins -filter "name=~link_i[${idx}]" -of_object $master_tile]
  set idx [expr 3*$HB_RUCHE_LINK_WIDTH_P + $i]
  append_to_collection east_in_pins [get_pins -filter "name=~ruche_link_i[${idx}]" -of_object $master_tile]
  set idx [expr 5*$HB_RUCHE_LINK_WIDTH_P + $i]
  append_to_collection east_in_pins [get_pins -filter "name=~ruche_link_i[${idx}]" -of_object $master_tile]
  set idx [expr 1*$HB_RUCHE_LINK_WIDTH_P + $i]
  append_to_collection east_in_pins [get_pins -filter "name=~ruche_link_i[${idx}]" -of_object $master_tile]
}

for {set i $HB_RUCHE_LINK_WIDTH_P} {$i < $HB_LINK_WIDTH_P} {incr i} {
  set idx [expr 1*$HB_LINK_WIDTH_P + $i]
  append_to_collection east_in_pins [get_pins -filter "name=~link_i[${idx}]" -of_object $master_tile]
}


# east output pins
set east_out_pins [list]
for {set i 0} {$i < $HB_RUCHE_LINK_WIDTH_P} {incr i} {
  set idx [expr 1*$HB_LINK_WIDTH_P + $i]
  append_to_collection east_out_pins [get_pins -filter "name=~link_o[${idx}]" -of_object $master_tile]
  set idx [expr 3*$HB_RUCHE_LINK_WIDTH_P + $i]
  append_to_collection east_out_pins [get_pins -filter "name=~ruche_link_o[${idx}]" -of_object $master_tile]
  set idx [expr 5*$HB_RUCHE_LINK_WIDTH_P + $i]
  append_to_collection east_out_pins [get_pins -filter "name=~ruche_link_o[${idx}]" -of_object $master_tile]
  set idx [expr 1*$HB_RUCHE_LINK_WIDTH_P + $i]
  append_to_collection east_out_pins [get_pins -filter "name=~ruche_link_o[${idx}]" -of_object $master_tile]
}

for {set i $HB_RUCHE_LINK_WIDTH_P} {$i < $HB_LINK_WIDTH_P} {incr i} {
  set idx [expr 1*$HB_LINK_WIDTH_P + $i]
  append_to_collection east_out_pins [get_pins -filter "name=~link_o[${idx}]" -of_object $master_tile]
}


place_ruche_pins_k1_k3 $west_out_pins [expr $tile_lly+$TILE_WEST_OUTPUT_OFFSET]  $tile_llx 1
place_ruche_pins_k1_k3 $east_in_pins  [expr $tile_lly+$TILE_WEST_OUTPUT_OFFSET]  $tile_urx 1

place_ruche_pins_k1_k3 $west_in_pins  [expr $tile_lly+$TILE_WEST_INPUT_OFFSET] $tile_llx 1
place_ruche_pins_k1_k3 $east_out_pins [expr $tile_lly+$TILE_WEST_INPUT_OFFSET] $tile_urx 1



# North output / south input
set north_output_pins [list]
set south_input_pins [list]
for {set i 0} {$i < $HB_LINK_WIDTH_P} {incr i} {
  set link_idx [expr $i + (2*$HB_LINK_WIDTH_P)]
  append_to_collection north_output_pins [get_pins -of $master_tile -filter "name=~link_o[$link_idx]"]
  set link_idx [expr $i + (3*$HB_LINK_WIDTH_P)]
  append_to_collection south_input_pins [get_pins -of $master_tile -filter "name=~link_i[$link_idx]"]
}

place_pins_k2_k4 $north_output_pins [expr $tile_llx+$NORTH_OUTPUT_OFFSET] $tile_ury
place_pins_k2_k4 $south_input_pins  [expr $tile_llx+$NORTH_OUTPUT_OFFSET] $tile_lly



# north input / south output
set north_input_pins [list]
set south_output_pins [list]
for {set i 0} {$i < $HB_LINK_WIDTH_P} {incr i} {
  set link_idx [expr $i + (2*$HB_LINK_WIDTH_P)]
  append_to_collection north_input_pins [get_pins -of $master_tile -filter "name=~link_i[$link_idx]"]
  set link_idx [expr $i + (3*$HB_LINK_WIDTH_P)]
  append_to_collection south_output_pins [get_pins -of $master_tile -filter "name=~link_o[$link_idx]"]
}

place_pins_k2_k4 $north_input_pins  [expr $tile_llx+$NORTH_INPUT_OFFSET] $tile_ury
place_pins_k2_k4 $south_output_pins [expr $tile_llx+$NORTH_INPUT_OFFSET] $tile_lly


# clock reset
set clk_pin   [get_pins -of $master_tile -filter "name=~clk_i"]
set reset_pin [get_pins -of $master_tile -filter "name=~reset_i"]
set_individual_pin_constraints -pins $clk_pin   -allowed_layers "K4" -location "[expr $tile_llx+(0.128*230)] $tile_ury"
set_individual_pin_constraints -pins $reset_pin -allowed_layers "K4" -location "[expr $tile_llx+(0.128*234)] $tile_ury"


# my cord
set cord_pins [list]
append_to_collection cord_pins [get_pins -of $master_tile -filter "name=~my_*_i*"]
append_to_collection cord_pins [get_pins -of $master_tile -filter "name=~pod_*_i*"]
place_pins_k2_k4 $cord_pins [expr $tile_llx+(0.128*882)] $tile_lly



###########################################################
