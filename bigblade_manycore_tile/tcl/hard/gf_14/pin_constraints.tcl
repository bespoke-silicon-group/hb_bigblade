puts "BSG-info: Running script [info script]\n"



source -echo -verbose $::env(BSG_DESIGNS_TARGET_TCL_HARD_DIR)/hb_common_variables.tcl

remove_individual_pin_constraints
remove_block_pin_constraints
set_block_pin_constraints -allowed_layers {C4 C5 K1 K2 K3 K4}


## common proc #########################################
proc place_pins_k2_k4 {pins start_x y} {
  set curr_x $start_x
  set i 0

  while {$i < [sizeof_collection $pins]} {
    set pin [index_collection $pins $i]

    set layer ""
    if {$i % 2 == 0} {
      set layer "K2"
    } else {
      set layer "K4"
    }

    if { [bsg_pins_check_location $curr_x $y $layer] == 1 } {
      set_individual_pin_constraints -ports $pin -allowed_layers $layer -location "$curr_x $y"
      incr i
    }

    set curr_x [expr $curr_x + 0.128]
  }
}


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
########################################################


set tile_llx      [get_attribute [get_core_area] bounding_box.ll_x]
set tile_lly      [get_attribute [get_core_area] bounding_box.ll_y]
set tile_urx      [get_attribute [get_core_area] bounding_box.ur_x]
set tile_ury      [get_attribute [get_core_area] bounding_box.ur_y]


# west output pins
set west_out_pins [list]
for {set i 0} {$i < $HB_RUCHE_LINK_WIDTH_P} {incr i} {
  set idx [expr 0*$HB_LINK_WIDTH_P + $i]
  append_to_collection west_out_pins [get_ports -filter "name=~link_o[${idx}]"]
  set idx [expr 2*$HB_RUCHE_LINK_WIDTH_P + $i]
  append_to_collection west_out_pins [get_ports -filter "name=~ruche_link_o[${idx}]"]
  set idx [expr 4*$HB_RUCHE_LINK_WIDTH_P + $i]
  append_to_collection west_out_pins [get_ports -filter "name=~ruche_link_o[${idx}]"]
  set idx [expr 0*$HB_RUCHE_LINK_WIDTH_P + $i]
  append_to_collection west_out_pins [get_ports -filter "name=~ruche_link_o[${idx}]"]
}

for {set i $HB_RUCHE_LINK_WIDTH_P} {$i < $HB_LINK_WIDTH_P} {incr i} {
  set idx [expr 0*$HB_LINK_WIDTH_P + $i]
  append_to_collection west_out_pins [get_ports -filter "name=~link_o[${idx}]"]
}


# west input pins
set west_in_pins [list]
for {set i 0} {$i < $HB_RUCHE_LINK_WIDTH_P} {incr i} {
  set idx [expr 0*$HB_LINK_WIDTH_P + $i]
  append_to_collection west_in_pins [get_ports -filter "name=~link_i[${idx}]"]
  set idx [expr 2*$HB_RUCHE_LINK_WIDTH_P + $i]
  append_to_collection west_in_pins [get_ports -filter "name=~ruche_link_i[${idx}]"]
  set idx [expr 4*$HB_RUCHE_LINK_WIDTH_P + $i]
  append_to_collection west_in_pins [get_ports -filter "name=~ruche_link_i[${idx}]"]
  set idx [expr 0*$HB_RUCHE_LINK_WIDTH_P + $i]
  append_to_collection west_in_pins [get_ports -filter "name=~ruche_link_i[${idx}]"]
}

for {set i $HB_RUCHE_LINK_WIDTH_P} {$i < $HB_LINK_WIDTH_P} {incr i} {
  set idx [expr 0*$HB_LINK_WIDTH_P + $i]
  append_to_collection west_in_pins [get_ports -filter "name=~link_i[${idx}]"]
}


# east input pins
set east_in_pins [list]
for {set i 0} {$i < $HB_RUCHE_LINK_WIDTH_P} {incr i} {
  set idx [expr 1*$HB_LINK_WIDTH_P + $i]
  append_to_collection east_in_pins [get_ports -filter "name=~link_i[${idx}]"]
  set idx [expr 3*$HB_RUCHE_LINK_WIDTH_P + $i]
  append_to_collection east_in_pins [get_ports -filter "name=~ruche_link_i[${idx}]"]
  set idx [expr 5*$HB_RUCHE_LINK_WIDTH_P + $i]
  append_to_collection east_in_pins [get_ports -filter "name=~ruche_link_i[${idx}]"]
  set idx [expr 1*$HB_RUCHE_LINK_WIDTH_P + $i]
  append_to_collection east_in_pins [get_ports -filter "name=~ruche_link_i[${idx}]"]
}

for {set i $HB_RUCHE_LINK_WIDTH_P} {$i < $HB_LINK_WIDTH_P} {incr i} {
  set idx [expr 1*$HB_LINK_WIDTH_P + $i]
  append_to_collection east_in_pins [get_ports -filter "name=~link_i[${idx}]"]
}


# east output pins
set east_out_pins [list]
for {set i 0} {$i < $HB_RUCHE_LINK_WIDTH_P} {incr i} {
  set idx [expr 1*$HB_LINK_WIDTH_P + $i]
  append_to_collection east_out_pins [get_ports -filter "name=~link_o[${idx}]"]
  set idx [expr 3*$HB_RUCHE_LINK_WIDTH_P + $i]
  append_to_collection east_out_pins [get_ports -filter "name=~ruche_link_o[${idx}]"]
  set idx [expr 5*$HB_RUCHE_LINK_WIDTH_P + $i]
  append_to_collection east_out_pins [get_ports -filter "name=~ruche_link_o[${idx}]"]
  set idx [expr 1*$HB_RUCHE_LINK_WIDTH_P + $i]
  append_to_collection east_out_pins [get_ports -filter "name=~ruche_link_o[${idx}]"]
}

for {set i $HB_RUCHE_LINK_WIDTH_P} {$i < $HB_LINK_WIDTH_P} {incr i} {
  set idx [expr 1*$HB_LINK_WIDTH_P + $i]
  append_to_collection east_out_pins [get_ports -filter "name=~link_o[${idx}]"]
}


place_ruche_pins_k1_k3 $west_out_pins [expr $tile_lly+$TILE_WEST_OUTPUT_OFFSET]  $tile_llx
place_ruche_pins_k1_k3 $east_in_pins  [expr $tile_lly+$TILE_WEST_OUTPUT_OFFSET]  $tile_urx

place_ruche_pins_k1_k3 $west_in_pins  [expr $tile_lly+$TILE_WEST_INPUT_OFFSET] $tile_llx
place_ruche_pins_k1_k3 $east_out_pins [expr $tile_lly+$TILE_WEST_INPUT_OFFSET] $tile_urx



# North output / south input
set north_output_pins [list]
set south_input_pins [list]
for {set i 0} {$i < $HB_LINK_WIDTH_P} {incr i} {
  set link_idx [expr $i + (2*$HB_LINK_WIDTH_P)]
  append_to_collection north_output_pins [get_ports -filter "name=~link_o[$link_idx]"]
  set link_idx [expr $i + (3*$HB_LINK_WIDTH_P)]
  append_to_collection south_input_pins [get_ports -filter "name=~link_i[$link_idx]"]
}

place_pins_k2_k4 $north_output_pins [expr $tile_llx+$NORTH_OUTPUT_OFFSET] $tile_ury
place_pins_k2_k4 $south_input_pins  [expr $tile_llx+$NORTH_OUTPUT_OFFSET] $tile_lly



# north input / south output
set north_input_pins [list]
set south_output_pins [list]
for {set i 0} {$i < $HB_LINK_WIDTH_P} {incr i} {
  set link_idx [expr $i + (2*$HB_LINK_WIDTH_P)]
  append_to_collection north_input_pins [get_ports  -filter "name=~link_i[$link_idx]"]
  set link_idx [expr $i + (3*$HB_LINK_WIDTH_P)]
  append_to_collection south_output_pins [get_ports  -filter "name=~link_o[$link_idx]"]
}

place_pins_k2_k4 $north_input_pins  [expr $tile_llx+$NORTH_INPUT_OFFSET] $tile_ury
place_pins_k2_k4 $south_output_pins [expr $tile_llx+$NORTH_INPUT_OFFSET] $tile_lly


# clock
set clk_pin   [get_ports -filter "name=~clk_i"]
set_individual_pin_constraints -ports $clk_pin   -allowed_layers "K4" -location "$tile_urx [expr 0.128*732]"
# reset
set reset_in_pin [get_ports  -filter "name=~reset_i"]
set_individual_pin_constraints -ports $reset_in_pin -allowed_layers "K4" -location "[expr $tile_llx+(0.128*234)] $tile_ury"
set reset_out_pin [get_ports  -filter "name=~reset_o"]
set_individual_pin_constraints -ports $reset_out_pin -allowed_layers "K4" -location "[expr $tile_llx+(0.128*234)] $tile_lly"


# my cord
set cord_in_pins [list]
append_to_collection cord_in_pins [get_ports -filter "name=~my_*_i*"]
append_to_collection cord_in_pins [get_ports -filter "name=~pod_*_i*"]
place_pins_k2_k4 $cord_in_pins [expr $tile_llx+(0.128*238)] $tile_ury

set cord_out_pins [list]
append_to_collection cord_out_pins [get_ports -filter "name=~my_*_o*"]
append_to_collection cord_out_pins [get_ports -filter "name=~pod_*_o*"]
place_pins_k2_k4 $cord_out_pins [expr $tile_llx+(0.128*238)] $tile_lly



puts "BSG-info: Completed script [info script]\n"
