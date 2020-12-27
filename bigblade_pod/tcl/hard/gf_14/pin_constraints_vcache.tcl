source $::env(BSG_DESIGNS_TARGET_TCL_HARD_DIR)/hb_common_variables.tcl


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
      set_individual_pin_constraints -pins $pin -allowed_layers $layer -location "$x $curr_y"
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


#### VCACHE PIN PLACEMENT #################################
set master_vcache [get_cell "pod/north_vc_row/vc_x_0__vc"]
set vcache_llx  [get_attribute $master_vcache boundary_bounding_box.ll_x]
set vcache_lly  [get_attribute $master_vcache boundary_bounding_box.ll_y]
set vcache_urx  [get_attribute $master_vcache boundary_bounding_box.ur_x]
set vcache_ury  [get_attribute $master_vcache boundary_bounding_box.ur_y]




# north output / south input
set north_output_pins [list]
set south_input_pins [list]
for {set i 0} {$i < $HB_LINK_WIDTH_P} {incr i} {
  set link_idx [expr $i+(0*$HB_LINK_WIDTH_P)]
  append_to_collection north_output_pins [get_pins -of $master_vcache -filter "name=~ver_link_sif_o[$link_idx]"]
  set link_idx [expr $i+(1*$HB_LINK_WIDTH_P)]
  append_to_collection south_input_pins [get_pins -of $master_vcache -filter "name=~ver_link_sif_i[$link_idx]"]
}

place_pins_k2_k4 $north_output_pins [expr $vcache_llx+$NORTH_OUTPUT_OFFSET] $vcache_ury
place_pins_k2_k4 $south_input_pins  [expr $vcache_llx+$NORTH_OUTPUT_OFFSET] $vcache_lly


# north input / south output
set north_input_pins [list]
set south_output_pins [list]
for {set i 0} {$i < $HB_LINK_WIDTH_P} {incr i} {
  set link_idx [expr $i+(0*$HB_LINK_WIDTH_P)]
  append_to_collection north_input_pins [get_pins -of $master_vcache -filter "name=~ver_link_sif_i[$link_idx]"]
  set link_idx [expr $i+(1*$HB_LINK_WIDTH_P)]
  append_to_collection south_output_pins [get_pins -of $master_vcache -filter "name=~ver_link_sif_o[$link_idx]"]
}

place_pins_k2_k4 $north_input_pins  [expr $vcache_llx+$NORTH_INPUT_OFFSET] $vcache_ury
place_pins_k2_k4 $south_output_pins [expr $vcache_llx+$NORTH_INPUT_OFFSET] $vcache_lly




# west output pins
set west_output_pins [list]
for {set i 0} {$i < $HB_WH_LINK_WIDTH_P} {incr i} {
  set link_idx [expr $i+($HB_WH_LINK_WIDTH_P*0)]
  append_to_collection west_output_pins [get_pins -of $master_vcache -filter "name=~wh_link_sif_o[$link_idx]"] 
  set link_idx [expr $i+($HB_WH_LINK_WIDTH_P*2)]
  append_to_collection west_output_pins [get_pins -of $master_vcache -filter "name=~wh_link_sif_o[$link_idx]"] 
}
 
# east input pins
set east_input_pins [list]
for {set i 0} {$i < $HB_WH_LINK_WIDTH_P} {incr i} {
  set link_idx [expr $i+($HB_WH_LINK_WIDTH_P*1)]
  append_to_collection east_input_pins [get_pins -of $master_vcache -filter "name=~wh_link_sif_i[$link_idx]"] 
  set link_idx [expr $i+($HB_WH_LINK_WIDTH_P*3)]
  append_to_collection east_input_pins [get_pins -of $master_vcache -filter "name=~wh_link_sif_i[$link_idx]"] 
}

place_wh_pins_k1_k3 $west_output_pins [expr $vcache_lly+$VCACHE_WEST_OUTPUT_OFFSET] $vcache_llx
place_wh_pins_k1_k3 $east_input_pins  [expr $vcache_lly+$VCACHE_WEST_OUTPUT_OFFSET] $vcache_urx




# west input pins
set west_input_pins [list]
for {set i 0} {$i < $HB_WH_LINK_WIDTH_P} {incr i} {
  set link_idx [expr $i+($HB_WH_LINK_WIDTH_P*0)]
  append_to_collection west_input_pins [get_pins -of $master_vcache -filter "name=~wh_link_sif_i[$link_idx]"] 
  set link_idx [expr $i+($HB_WH_LINK_WIDTH_P*2)]
  append_to_collection west_input_pins [get_pins -of $master_vcache -filter "name=~wh_link_sif_i[$link_idx]"] 
}

# east output pins
set east_output_pins [list]
for {set i 0} {$i < $HB_WH_LINK_WIDTH_P} {incr i} {
  set link_idx [expr $i+($HB_WH_LINK_WIDTH_P*1)]
  append_to_collection east_output_pins [get_pins -of $master_vcache -filter "name=~wh_link_sif_o[$link_idx]"] 
  set link_idx [expr $i+($HB_WH_LINK_WIDTH_P*3)]
  append_to_collection east_output_pins [get_pins -of $master_vcache -filter "name=~wh_link_sif_o[$link_idx]"] 
}

place_wh_pins_k1_k3 $west_input_pins  [expr $vcache_lly+$VCACHE_WEST_INPUT_OFFSET] $vcache_llx
place_wh_pins_k1_k3 $east_output_pins [expr $vcache_lly+$VCACHE_WEST_INPUT_OFFSET] $vcache_urx



# clock reset
set clk_pin   [get_pins -of $master_vcache -filter "name=~clk_i"]
set reset_pin [get_pins -of $master_vcache -filter "name=~reset_i"]
set_individual_pin_constraints -pins $clk_pin   -allowed_layers "K4" -location "[expr $vcache_llx+(0.128*230)] $vcache_ury"
set_individual_pin_constraints -pins $reset_pin -allowed_layers "K4" -location "[expr $vcache_llx+(0.128*234)] $vcache_ury"



# cord pins
set cord_pins [list]
append_to_collection cord_pins [get_pins -of $master_vcache -filter "name=~global_*_i*"]
append_to_collection cord_pins [get_pins -of $master_vcache -filter "name=~my_wh_cord_i*"]
append_to_collection cord_pins [get_pins -of $master_vcache -filter "name=~dest_wh_cord_i*"]
append_to_collection cord_pins [get_pins -of $master_vcache -filter "name=~my_wh_cid_i*"]

place_pins_k2_k4 $cord_pins [expr $vcache_llx+(0.128*935)] $vcache_lly








#############################################################



