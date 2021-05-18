puts "BSG-info running [info script]"


proc get_propagated_nets {port cell} {

  set start_net  [get_nets  -of_object $port     ]
  set start_cell [get_cells -of_object $start_net]

  set result [list]
  append_to_collection result $start_net

  set curr_net_name  [get_attribute $start_net  name]
  set curr_cell_name [get_attribute $start_cell name]
  set end_cell_name  [get_attribute $cell       name]

  while {$curr_cell_name != $end_cell_name} {
    set curr_cell [get_cells $curr_cell_name]
    set next_net  [get_nets -of_object $curr_cell -filter "(full_name!=$curr_net_name)&&(full_name!=VSS)&&(full_name!=VDD)"]
    set next_cell [get_cells -of_object $next_net -filter "(full_name!=$curr_cell_name)"]
    set curr_net_name  [get_attribute $next_net  name]
    set curr_cell_name [get_attribute $next_cell name]
    append_to_collection result $next_net
  }

  return $result
}


# First run, route wires
set ss_nets [list]
foreach {side} {"DL" "DR" "IT"} {
  set limit [expr {$side == "IT"} ? 2 : 8]
  for {set i 0} {$i < $limit} {incr i} {
    foreach {dir} {"i" "o"} {
      set num  [expr {$side == "DL"} ? {$i/2} : {$i/2+4}]
      set cell "mem_link_${num}__link"
      if {$side == "IT"} {set cell "io_link"}
      append_to_collection "ss_nets" [get_propagated_nets [get_ports "pad_${side}${i}_clk_${dir}_int"] [get_cells $cell]]
      append_to_collection "ss_nets" [get_propagated_nets [get_ports "pad_${side}${i}_v_${dir}_int"] [get_cells $cell]]
      append_to_collection "ss_nets" [get_propagated_nets [get_ports "pad_${side}${i}_tkn_${dir}_int"] [get_cells $cell]]
      for {set j 0} {$j < 16} {incr j} {
        append_to_collection "ss_nets" [get_propagated_nets [get_ports "pad_${side}${i}_${j}_${dir}_int"] [get_cells $cell]]
      }
    }
  }
}

create_routing_rule ss_ndr -multiplier_spacing 4
set_routing_rule -rule ss_ndr -min_routing_layer K1 -max_routing_layer K4 $ss_nets
route_custom -nets $ss_nets


# Second run, match length
set_app_options -list {
  custom.route.single_loop_match              true
  custom.route.single_loop_match_min_spacing  0
  custom.route.single_loop_match_max_spacing  0
  custom.route.single_loop_match_offset_layer true
}

foreach {side} {"DL" "DR" "IT"} {
  set limit [expr {$side == "IT"} ? 2 : 8]
  for {set i 0} {$i < $limit} {incr i} {
    foreach {dir} {"i" "o"} {
      set ss_ch_nets [list]
      set num  [expr {$side == "DL"} ? {$i/2} : {$i/2+4}]
      set cell "mem_link_${num}__link"
      if {$side == "IT"} {set cell "io_link"}
      append_to_collection "ss_ch_nets" [get_propagated_nets [get_ports "pad_${side}${i}_clk_${dir}_int"] [get_cells $cell]]
      append_to_collection "ss_ch_nets" [get_propagated_nets [get_ports "pad_${side}${i}_v_${dir}_int"] [get_cells $cell]]
      append_to_collection "ss_ch_nets" [get_propagated_nets [get_ports "pad_${side}${i}_tkn_${dir}_int"] [get_cells $cell]]
      for {set j 0} {$j < 16} {incr j} {
        append_to_collection "ss_ch_nets" [get_propagated_nets [get_ports "pad_${side}${i}_${j}_${dir}_int"] [get_cells $cell]]
      }
      create_bundle -name "ss_bundle_${side}${i}_${dir}" $ss_ch_nets
      create_wire_matching -for [get_bundles "ss_bundle_${side}${i}_${dir}"] -match_type length -tolerance 5 -force "ss_match_${side}${i}_${dir}"
    }
  }
}

route_custom -nets [get_bundles ss_bundle_*]


# Third run, insert buffer
### CHANGE ROUTING RULES TO ALLOW ROUTING DOWN TO M2
set_routing_rule -rule ss_ndr -min_routing_layer M2 -max_routing_layer K4 $ss_nets

set ss_buffer "SC7P5T_CKBUFX4_SSC14R"

# WATCHOUT, THIS INSERTS 9 INVERTS AND BREAKS THE WIRE
#add_buffer_on_route -net_prefix bsg_ss -cell_prefix bsg_ss -repeater_distance_length_ratio 0.1 -respect_blockages $ss_nets $ss_buffer
add_buffer_on_route -net_prefix bsg_ss -cell_prefix bsg_ss -repeater_distance 250.00 -respect_blockages $ss_nets $ss_buffer

legalize_placement -cells [get_cells bsg_ss*]
check_legality -cells [get_cells bsg_ss*]


set ss_nets [list]
foreach {side} {"DL" "DR" "IT"} {
  set limit [expr {$side == "IT"} ? 2 : 8]
  for {set i 0} {$i < $limit} {incr i} {
    foreach {dir} {"i" "o"} {
      set num  [expr {$side == "DL"} ? {$i/2} : {$i/2+4}]
      set cell "mem_link_${num}__link"
      if {$side == "IT"} {set cell "io_link"}
      append_to_collection "ss_nets" [get_propagated_nets [get_ports "pad_${side}${i}_clk_${dir}_int"] [get_cells $cell]]
      append_to_collection "ss_nets" [get_propagated_nets [get_ports "pad_${side}${i}_v_${dir}_int"] [get_cells $cell]]
      append_to_collection "ss_nets" [get_propagated_nets [get_ports "pad_${side}${i}_tkn_${dir}_int"] [get_cells $cell]]
      for {set j 0} {$j < 16} {incr j} {
        append_to_collection "ss_nets" [get_propagated_nets [get_ports "pad_${side}${i}_${j}_${dir}_int"] [get_cells $cell]]
      }
    }
  }
}

set_attribute [get_shapes -of_object $ss_nets] shape_use "user_route"
set_attribute [get_vias   -of_object $ss_nets] shape_use "user_route"

set_attribute [get_shapes -of_object $ss_nets] physical_status "minor_change"
set_attribute [get_vias   -of_object $ss_nets] physical_status "minor_change"

route_eco -nets $ss_nets -reroute modified_nets_only
update_timing -full


# IF THINGS ARE GOOD, LOCK THESE NETS SO FUTURE STEPS DON"T MODIFY THEM
#set_attribute [get_shapes -of_object $ss_nets] physical_status "locked"
#set_attribute [get_vias   -of_object $ss_nets] physical_status "locked"
#if {[file exists [which $TCL_USER_REDUNDANT_VIA_MAPPING_FILE]]} {                                                                                                                                                                    
#  puts "RM-info: Sourcing [which $TCL_USER_REDUNDANT_VIA_MAPPING_FILE]"                                                                                                                                                              
#  source $TCL_USER_REDUNDANT_VIA_MAPPING_FILE                                                                                                                                                                                        
#  report_via_mapping                                                                                                                                                                                                                 
#} elseif {[file exists [which $TCL_USER_ICC_REDUNDANT_VIA_MAPPING_FILE]]} {                                                                                                                                                          
#  puts "RM-info: Sourcing [which $TCL_USER_ICC_REDUNDANT_VIA_MAPPING_FILE]"                                                                                                                                                          
#  add_via_mapping -from_icc_file $TCL_USER_ICC_REDUNDANT_VIA_MAPPING_FILE                                                                                                                                                            
#  report_via_mapping                                                                                                                                                                                                                 
#} else {                                                                                                                                                                                                                             
#  puts "RM-warning: No valid redundant via mapping file has been specified."                                                                                                                                                         
#}                                                                                                                                                                                                                                    
#                                                                                                                                                                                                                                     
#add_redundant_vias -nets $ss_nets
#
#update_timing -full
#
#remove_sdc -exclude pvt
#create_clock -name vclk -period 1000
#set_input_delay 0 -source_latency_included -network_latency_included -clock vclk [all_inputs]
#
#for {set i 0} {$i < 16} {incr i} {
#  set_data_check -from DRAM_CH_L1/io_link_clk_i[0] -to DRAM_CH_L1/io_link_data_i[$i] -setup -50
#  set_data_check -from DRAM_CH_L1/io_link_clk_i[0] -to DRAM_CH_L1/io_link_data_i[$i] -hold -50
#
#  set_multicycle_path   0 -setup -to DRAM_CH_L1/io_link_data_i[$i]
#  set_multicycle_path  -1 -hold  -to DRAM_CH_L1/io_link_data_i[$i]
#}
#update_timing -full
#
#reset_app_options custom.route.*
#set_app_options -list {
#  route.detail.timing_driven true
#}
#set_attribute [get_shapes -of_object $ss_nets] shape_use "detail_route"
#set_attribute [get_vias   -of_object $ss_nets] shape_use "detail_route"
#route_detail -incremental true
#update_timing -full

puts "BSG-info finished [info script]"
