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


  # isolate output port
  #for {set i 0} {$i < 4} {incr i} {
  #  set idx [expr ($i*$HB_LINK_WIDTH_P)+54]
  #  set_isolate_ports [get_ports "link_o[$idx]"]
  #  set idx [expr ($i*$HB_LINK_WIDTH_P)+153]
  #  set_isolate_ports [get_ports "link_o[$idx]"]
  #}

  #for {set i 0} {$i < 2} {incr i} {
  #  set idx [expr ($i*$HB_RUCHE_LINK_WIDTH_P)+47]
  #  set_isolate_ports [get_ports "ruche_link_o[$idx]"]
  #  set idx [expr ($i*$HB_RUCHE_LINK_WIDTH_P)+139]
  #  set_isolate_ports [get_ports "ruche_link_o[$idx]"]
  #}

} elseif {$DESIGN_NAME == "bsg_manycore_tile_vcache"} {

  remove_buffers [get_cells FTB*]
  for {set i [expr 2*$HB_WH_LINK_WIDTH_P]} {$i < [expr 2*$HB_WH_RUCHE_FACTOR_P*$HB_WH_LINK_WIDTH_P]} {incr i} {
    set_dont_touch [get_nets "wh_link_sif_i[${i}]"] true
  }

}

puts "BSG-info: Completed script [info script]\n"
