puts "BSG-info: Running script [info script]\n"


source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_common_variables.tcl


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
########################################################



#### VCACHE PIN PLACEMENT #################################
set vcache_llx  [get_attribute [get_core_area] bounding_box.ll_x]
set vcache_lly  [get_attribute [get_core_area] bounding_box.ll_y]
set vcache_urx  [get_attribute [get_core_area] bounding_box.ur_x]
set vcache_ury  [get_attribute [get_core_area] bounding_box.ur_y]




# north output / south input
set north_output_pins [list]
set south_input_pins [list]
for {set i 0} {$i < $HB_LINK_WIDTH_P} {incr i} {
  set link_idx [expr $i+(0*$HB_LINK_WIDTH_P)]
  append_to_collection north_output_pins [get_ports -filter "name=~ver_link_sif_o[$link_idx]"]
  set link_idx [expr $i+(1*$HB_LINK_WIDTH_P)]
  append_to_collection south_input_pins [get_ports -filter "name=~ver_link_sif_i[$link_idx]"]
}

place_pins_k2_k4 $north_output_pins [expr $vcache_llx+$NORTH_OUTPUT_OFFSET] $vcache_ury
place_pins_k2_k4 $south_input_pins  [expr $vcache_llx+$NORTH_OUTPUT_OFFSET] $vcache_lly


# north input / south output
set north_input_pins [list]
set south_output_pins [list]
for {set i 0} {$i < $HB_LINK_WIDTH_P} {incr i} {
  set link_idx [expr $i+(0*$HB_LINK_WIDTH_P)]
  append_to_collection north_input_pins [get_ports -filter "name=~ver_link_sif_i[$link_idx]"]
  set link_idx [expr $i+(1*$HB_LINK_WIDTH_P)]
  append_to_collection south_output_pins [get_ports -filter "name=~ver_link_sif_o[$link_idx]"]
}

place_pins_k2_k4 $north_input_pins  [expr $vcache_llx+$NORTH_INPUT_OFFSET] $vcache_ury
place_pins_k2_k4 $south_output_pins [expr $vcache_llx+$NORTH_INPUT_OFFSET] $vcache_lly




# west output pins
set west_output_pins [list]
for {set i 0} {$i < $HB_WH_LINK_WIDTH_P} {incr i} {
  set link_idx [expr $i+($HB_WH_LINK_WIDTH_P*0)]
  append_to_collection west_output_pins [get_ports -filter "name=~wh_link_sif_o[$link_idx]"] 
  set link_idx [expr $i+($HB_WH_LINK_WIDTH_P*2)]
  append_to_collection west_output_pins [get_ports -filter "name=~wh_link_sif_o[$link_idx]"] 
}
 
# east input pins
set east_input_pins [list]
for {set i 0} {$i < $HB_WH_LINK_WIDTH_P} {incr i} {
  set link_idx [expr $i+($HB_WH_LINK_WIDTH_P*1)]
  append_to_collection east_input_pins [get_ports -filter "name=~wh_link_sif_i[$link_idx]"] 
  set link_idx [expr $i+($HB_WH_LINK_WIDTH_P*3)]
  append_to_collection east_input_pins [get_ports -filter "name=~wh_link_sif_i[$link_idx]"] 
}

place_wh_pins_k1_k3 $west_output_pins [expr $vcache_lly+$VCACHE_WEST_OUTPUT_OFFSET] $vcache_llx
place_wh_pins_k1_k3 $east_input_pins  [expr $vcache_lly+$VCACHE_WEST_OUTPUT_OFFSET] $vcache_urx




# west input pins
set west_input_pins [list]
for {set i 0} {$i < $HB_WH_LINK_WIDTH_P} {incr i} {
  set link_idx [expr $i+($HB_WH_LINK_WIDTH_P*0)]
  append_to_collection west_input_pins [get_ports -filter "name=~wh_link_sif_i[$link_idx]"] 
  set link_idx [expr $i+($HB_WH_LINK_WIDTH_P*2)]
  append_to_collection west_input_pins [get_ports -filter "name=~wh_link_sif_i[$link_idx]"] 
}

# east output pins
set east_output_pins [list]
for {set i 0} {$i < $HB_WH_LINK_WIDTH_P} {incr i} {
  set link_idx [expr $i+($HB_WH_LINK_WIDTH_P*1)]
  append_to_collection east_output_pins [get_ports -filter "name=~wh_link_sif_o[$link_idx]"] 
  set link_idx [expr $i+($HB_WH_LINK_WIDTH_P*3)]
  append_to_collection east_output_pins [get_ports -filter "name=~wh_link_sif_o[$link_idx]"] 
}

place_wh_pins_k1_k3 $west_input_pins  [expr $vcache_lly+$VCACHE_WEST_INPUT_OFFSET] $vcache_llx
place_wh_pins_k1_k3 $east_output_pins [expr $vcache_lly+$VCACHE_WEST_INPUT_OFFSET] $vcache_urx



# clock pin
set clk_pin   [get_ports -filter "name=~clk_i"]
set_individual_pin_constraints -ports $clk_pin   -allowed_layers "K3" -location "$vcache_urx [expr 0.128*588]"


# cord reset pins
set cord_reset_in_pins [list]
append_to_collection cord_reset_in_pins [get_ports "reset_i"]
append_to_collection cord_reset_in_pins [sort_collection [get_ports "global_*_i*"] name]
place_pins_k2_k4 $cord_reset_in_pins [expr $vcache_llx+(0.128*234)] $vcache_ury

set cord_reset_out_pins [list]
append_to_collection cord_reset_out_pins [get_ports "reset_o"]
append_to_collection cord_reset_out_pins [sort_collection [get_ports "global_*_o*"] name]
place_pins_k2_k4 $cord_reset_out_pins [expr $vcache_llx+(0.128*234)] $vcache_lly







#############################################################







puts "BSG-info: Completed script [info script]\n"
