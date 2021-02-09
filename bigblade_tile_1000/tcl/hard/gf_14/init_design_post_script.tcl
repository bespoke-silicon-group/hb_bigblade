puts "BSG-info: Running script [info script]\n"

source $::env(BSG_DESIGNS_TARGET_TCL_HARD_DIR)/hb_common_variables.tcl

if { $DESIGN_NAME == "bsg_chip_pod" } {

  proc bsg_dont_touch_regexp {arg1} {
    set pattern "full_name=~$arg1";
    set mycells [get_cells -hier -filter $pattern]
    puts [concat "BSG: set dont_touch'ing " $pattern "=" [collection_to_list $mycells]]
    set_dont_touch $mycells
  }

  proc bsg_dont_touch_regexp_type {arg1} {
    set pattern "ref_name=~$arg1";
    set mycells [get_cells -hier -filter $pattern]
    puts [concat "BSG: set dont_touch'ing " $pattern "=" [collection_to_list $mycells]]
    set_dont_touch $mycells
  }

  #bsg_dont_touch_regexp *DONT_TOUCH*
  #bsg_dont_touch_regexp_type *SYNC*SDFF*

  set_dont_touch [get_cells -hier -filter "name=~*hard_inv*"] true
  set_dont_touch [get_cells -hier -filter "name=~*hard_buf*"] true

  set_dont_touch [get_nets -of [get_pins pod_mc_y_*__x_*__tile/ruche_link_*]] true
  set_dont_touch [get_nets -of [get_pins pod_*_vc_row_vc_x_*__vc/wh_link_sif_*]] true

} elseif { $DESIGN_NAME == "bsg_manycore_tile_compute_ruche"} {
  # remove feedthrough buffers
  #remove_buffers [get_cells FTB*]
  for {set i [expr 2*$HB_RUCHE_LINK_WIDTH_P]} {$i < [expr 2*$HB_RUCHE_FACTOR_P*$HB_RUCHE_LINK_WIDTH_P]} {incr i} {
    set_dont_touch [get_nets "ruche_link_i[${i}]"] true
  }


  # clock skew group
  # grab valid/ready bits and put them in a skew group
  set local_link_input_pins [sort_collection [get_ports "link_i*"] name]  
  set local_link_output_pins [sort_collection [get_ports "link_o*"] name]  
  set ruche_link_input_pins [sort_collection [get_ports "ruche_link_i*"] name]  
  set ruche_link_output_pins [sort_collection [get_ports "ruche_link_o*"] name]  

  set skew_group_ports [list]
  for {set i 0} {$i < 4} {incr i} {
    set rev_valid_idx [expr ($i*$HB_LINK_WIDTH_P)+54]
    set rev_ready_idx [expr ($i*$HB_LINK_WIDTH_P)+53]
    set fwd_valid_idx [expr ($i*$HB_LINK_WIDTH_P)+153]
    set fwd_ready_idx [expr ($i*$HB_LINK_WIDTH_P)+152]
    append_to_collection skew_group_ports [index_collection $local_link_input_pins $rev_valid_idx]
    append_to_collection skew_group_ports [index_collection $local_link_input_pins $rev_ready_idx]
    append_to_collection skew_group_ports [index_collection $local_link_input_pins $fwd_valid_idx]
    append_to_collection skew_group_ports [index_collection $local_link_input_pins $fwd_ready_idx]
    append_to_collection skew_group_ports [index_collection $local_link_output_pins $rev_valid_idx]
    append_to_collection skew_group_ports [index_collection $local_link_output_pins $rev_ready_idx]
    append_to_collection skew_group_ports [index_collection $local_link_output_pins $fwd_valid_idx]
    append_to_collection skew_group_ports [index_collection $local_link_output_pins $fwd_ready_idx]
  }

  for {set i 0} {$i < 2} {incr i} {
    set rev_valid_idx [expr ($i*$HB_LINK_WIDTH_P)+47]
    set rev_ready_idx [expr ($i*$HB_LINK_WIDTH_P)+46]
    set fwd_valid_idx [expr ($i*$HB_LINK_WIDTH_P)+139]
    set fwd_ready_idx [expr ($i*$HB_LINK_WIDTH_P)+138]
    append_to_collection skew_group_ports [index_collection $ruche_link_input_pins $rev_valid_idx]
    append_to_collection skew_group_ports [index_collection $ruche_link_input_pins $rev_ready_idx]
    append_to_collection skew_group_ports [index_collection $ruche_link_input_pins $fwd_valid_idx]
    append_to_collection skew_group_ports [index_collection $ruche_link_input_pins $fwd_ready_idx]
    append_to_collection skew_group_ports [index_collection $ruche_link_output_pins $rev_valid_idx]
    append_to_collection skew_group_ports [index_collection $ruche_link_output_pins $rev_ready_idx]
    append_to_collection skew_group_ports [index_collection $ruche_link_output_pins $fwd_valid_idx]
    append_to_collection skew_group_ports [index_collection $ruche_link_output_pins $fwd_ready_idx]
  }

  
  set skew_group_clk_pins [get_pins -of [all_transitive_fanout -from $skew_group_ports -only_cells -flat -endpoints_only] -filter "is_clock_pin"]
  create_clock_skew_group -name "bsg_csg" -objects $skew_group_clk_pins


} elseif {$DESIGN_NAME == "bsg_manycore_tile_vcache"} {

  remove_buffers [get_cells FTB*]
  for {set i [expr 2*$HB_WH_LINK_WIDTH_P]} {$i < [expr 2*$HB_WH_RUCHE_FACTOR_P*$HB_WH_LINK_WIDTH_P]} {incr i} {
    set_dont_touch [get_nets "wh_link_sif_i[${i}]"] true
  }

}

puts "BSG-info: Completed script [info script]\n"
