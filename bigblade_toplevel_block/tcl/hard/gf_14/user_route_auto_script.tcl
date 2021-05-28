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

reset_app_options custom.route.*

create_routing_rule ss_x2_ndr -multiplier_spacing 2
create_routing_rule ss_x4_ndr -multiplier_spacing 4
create_routing_rule ss_x8_ndr -multiplier_spacing 8

set ss_WH_nets [list]
for {set i 0} {$i < 8} {incr i} {
  append_to_collection ss_WH_nets [get_nets -of_object [get_pins "mem_link_${i}__link/io_wh_link_*"]]
}
set ss_mc_nets [get_nets -of_object [get_pins "io_link/mc_*_link_*"]]
set_routing_rule -rule ss_x2_ndr -min_routing_layer K1 -max_routing_layer K4 $ss_WH_nets
set_routing_rule -rule ss_x4_ndr -min_routing_layer K1 -max_routing_layer K4 $ss_mc_nets

foreach {side} {"DL" "DR" "IT"} {
  set limit [expr {$side == "IT"} ? 2 : 8]
  for {set i 0} {$i < $limit} {incr i} {
    foreach {dir} {"i" "o"} {
      set ss_link_nets [get_nets -of_object [get_ports "pad_${side}${i}_*_${dir}_int"]]
      set ss_link_nets [remove_from_collection $ss_link_nets [get_ports "pad_${side}${i}_extra_${dir}_int"]]
      set ndr [expr {$side == "IT"} ? {"x8"} : {[expr {$i == 0 || $i == 7} ? {"x8"} : {"x4"}]}]
      set_routing_rule -rule "ss_${ndr}_ndr" -min_routing_layer K1 -max_routing_layer K4 $ss_link_nets
    }
  }
}



#set_app_options -name route.global.timing_driven -value false
#set_app_options -name route.track.timing_driven -value false
#set_app_options -name route.detail.timing_driven -value false
#set_app_options -name route.global.crosstalk_driven -value false
#set_app_options -name route.track.crosstalk_driven -value false

# First, route vertical links and lock
#set ver_nets [get_nets *ver_io_*_link_*_lo*]
#route_group -nets $ver_nets



# flow default timing_driven true
#set_app_options -name route.global.timing_driven -value true
#set_app_options -name route.track.timing_driven -value true
#set_app_options -name route.detail.timing_driven -value true

# disable crosstalk driven to avoid zigzag shaped routing
if {[string match "R-2020.09*" [get_app_option_value -name shell.common.product_version]]} {
  set_app_options -name route.global.crosstalk_driven -value true
  set_app_options -name route.track.crosstalk_driven -value true
} else {
  set_app_options -name route.global.crosstalk_driven -value false
  set_app_options -name route.track.crosstalk_driven -value false
}

# This option takes effect only if timing-driven routing is enabled
#set_app_options -name route.common.rc_driven_setup_effort_level -value high

route_global
route_track
route_detail


# # First run, route wires
# set ss_nets [list]
# foreach {side} {"DL" "DR" "IT"} {
#   set limit [expr {$side == "IT"} ? 2 : 8]
#   for {set i 0} {$i < $limit} {incr i} {
#     foreach {dir} {"i" "o"} {
#       set num  [expr {$side == "DL"} ? {$i/2} : {$i/2+4}]
#       set cell "mem_link_${num}__link"
#       if {$side == "IT"} {set cell "io_link"}
#       append_to_collection "ss_nets" [get_propagated_nets [get_ports "pad_${side}${i}_clk_${dir}_int"] [get_cells $cell]]
#       append_to_collection "ss_nets" [get_propagated_nets [get_ports "pad_${side}${i}_v_${dir}_int"] [get_cells $cell]]
#       append_to_collection "ss_nets" [get_propagated_nets [get_ports "pad_${side}${i}_tkn_${dir}_int"] [get_cells $cell]]
#       for {set j 0} {$j < 16} {incr j} {
#         append_to_collection "ss_nets" [get_propagated_nets [get_ports "pad_${side}${i}_${j}_${dir}_int"] [get_cells $cell]]
#       }
#     }
#   }
# }
# 
# create_routing_rule ss_ndr -multiplier_spacing 4
# set_routing_rule -rule ss_ndr -min_routing_layer K1 -max_routing_layer K4 $ss_nets
# route_custom -nets $ss_nets
# 
# 
# Second run, match length
# set_app_options -list {
#   custom.route.single_loop_match              true
#   custom.route.single_loop_match_min_spacing  0
#   custom.route.single_loop_match_max_spacing  0
#   custom.route.single_loop_match_offset_layer true
# }
# 
# set side "DL"
#   set limit 2 ;# [expr {$side == "IT"} ? 2 : 8]
#   for {set i 0} {$i < $limit} {incr i} {
#     foreach {dir} {"i" "o"} {
#       set ss_ch_nets [list]
#       set num  [expr {$side == "DL"} ? {$i/2} : {$i/2+4}]
#       set cell "mem_link_${num}__link"
#       if {$side == "IT"} {set cell "io_link"}
#       append_to_collection "ss_ch_nets" [get_propagated_nets [get_ports "pad_${side}${i}_clk_${dir}_int"] [get_cells $cell]]
#       append_to_collection "ss_ch_nets" [get_propagated_nets [get_ports "pad_${side}${i}_v_${dir}_int"] [get_cells $cell]]
#       append_to_collection "ss_ch_nets" [get_propagated_nets [get_ports "pad_${side}${i}_tkn_${dir}_int"] [get_cells $cell]]
#       for {set j 0} {$j < 16} {incr j} {
#         append_to_collection "ss_ch_nets" [get_propagated_nets [get_ports "pad_${side}${i}_${j}_${dir}_int"] [get_cells $cell]]
#       }
#       create_bundle -name "ss_bundle_${side}${i}_${dir}" $ss_ch_nets
#       create_wire_matching -for [get_bundles "ss_bundle_${side}${i}_${dir}"] -match_type length -tolerance 5 -force "ss_match_${side}${i}_${dir}"
#     }
#   }
# 
# route_custom -nets [get_bundles ss_bundle_*]


# Third run, insert buffer
### CHANGE ROUTING RULES TO ALLOW ROUTING DOWN TO M2
set ss_WH_nets [list]
for {set i 0} {$i < 8} {incr i} {
  append_to_collection ss_WH_nets [get_nets -of_object [get_pins "mem_link_${i}__link/io_wh_link_*"]]
}
set ss_mc_nets [get_nets -of_object [get_pins "io_link/mc_*_link_*"]]
set_routing_rule -rule ss_x2_ndr -min_routing_layer M2 -max_routing_layer K4 $ss_WH_nets
set_routing_rule -rule ss_x4_ndr -min_routing_layer M2 -max_routing_layer K4 $ss_mc_nets

foreach {side} {"DL" "DR" "IT"} {
  set limit [expr {$side == "IT"} ? 2 : 8]
  for {set i 0} {$i < $limit} {incr i} {
    foreach {dir} {"i" "o"} {
      set ss_link_nets [get_nets -of_object [get_ports "pad_${side}${i}_*_${dir}_int"]]
      set ss_link_nets [remove_from_collection $ss_link_nets [get_ports "pad_${side}${i}_extra_${dir}_int"]]
      set ndr [expr {$side == "IT"} ? {"x8"} : {[expr {$i == 0 || $i == 7} ? {"x8"} : {"x4"}]}]
      set_routing_rule -rule "ss_${ndr}_ndr" -min_routing_layer M2 -max_routing_layer K4 $ss_link_nets
    }
  }
}


# set length_(DL0_i) 3567.388
# set length_(DL0_o) 3475.088
# set length_(DL1_i) 1092.080
# set length_(DL1_o) 1183.856
# set length_(DL2_i) 2637.256
# set length_(DL2_o) 2529.712
# set length_(DL3_i) 1058.824
# set length_(DL3_o)  966.664
# set length_(DL4_i) 1095.496
# set length_(DL4_o)  987.464
# set length_(DL5_i) 2309.336
# set length_(DL5_o) 2401.416
# set length_(DL6_i) [expr 3501.820-(1209.6+107.52+369.63)]
# set length_(DL6_o) [expr 3417.084-(1209.6+107.52+369.63)]
# set length_(DL7_i) [expr 5078.076-(1209.6+107.52+369.63)]
# set length_(DL7_o) [expr 4957.988-(1209.6+107.52+369.63)]
# 
# set length_(DR0_i) 3331.140
# set length_(DR0_o) 3398.172
# set length_(DR1_i) 1116.808
# set length_(DR1_o) 1188.640
# set length_(DR2_i) 2631.008
# set length_(DR2_o) 2543.200
# set length_(DR3_i) 1052.576
# set length_(DR3_o)  981.024
# set length_(DR4_i) 1089.504
# set length_(DR4_o) 1001.440
# set length_(DR5_i) 2334.088
# set length_(DR5_o) 2405.640
# set length_(DR6_i) [expr 3555.364-(1417.92+107.52+369.63)]
# set length_(DR6_o) [expr 3643.068-(1417.92+107.52+369.63)]
# set length_(DR7_i) [expr 5109.348-(1417.92+107.52+369.63)]
# set length_(DR7_o) [expr 5175.292-(1417.92+107.52+369.63)]


# source-synchronous buffers
set ss_buffer "SC7P5T_CKBUFX16_SSC14SL"

set ss_WH_nets [list]
for {set i 0} {$i < 8} {incr i} {
  append_to_collection ss_WH_nets [get_nets -of_object [get_pins "mem_link_${i}__link/io_wh_link_*"]]
}
set ss_mc_nets [get_nets -of_object [get_pins "io_link/mc_*_link_*"]]
add_buffer_on_route -net_prefix bsg_ss -cell_prefix bsg_ss -repeater_distance 100.00 -respect_blockages $ss_WH_nets $ss_buffer
add_buffer_on_route -net_prefix bsg_ss -cell_prefix bsg_ss -repeater_distance 100.00 -respect_blockages $ss_mc_nets $ss_buffer

foreach {side} {"DL" "DR" "IT"} {
  set limit [expr {$side == "IT"} ? 2 : 8]
  for {set i 0} {$i < $limit} {incr i} {
    foreach {dir} {"i" "o"} {
      set ss_link_nets [get_nets -of_object [get_ports "pad_${side}${i}_*_${dir}_int"]]
      set ss_link_nets [remove_from_collection $ss_link_nets [get_nets -of_object [get_ports "pad_${side}${i}_extra_${dir}_int"]]]
      # estimate wire length
      set max_length 0
      foreach_in_collection net $ss_link_nets {set max_length [expr max($max_length, [get_estimated_wirelength -nets $net])]}
      set ratio [expr 100.00/$max_length]
      add_buffer_on_route -net_prefix bsg_ss -cell_prefix bsg_ss -repeater_distance_length_ratio $ratio -respect_blockages $ss_link_nets $ss_buffer
    }
  }
}


# miscellaneous buffers
set msc_buffer "SC7P5T_CKBUFX16_SSC14R"
set msc_nets [list]
append_to_collection msc_nets [get_nets -of_object [get_ports "pad_CT0_0_i_int"]]
set TAG_AND_cell [get_cells -of_object [get_nets -of_object [get_ports "pad_CT0_1_i_int"]]]
foreach_in_collection cell $TAG_AND_cell {
  append_to_collection -unique msc_nets [get_nets -of_object $cell -filter "(full_name!=VSS)&&(full_name!=VDD)"]
}

append_to_collection msc_nets [get_nets -of_object [get_ports "pad_CT0_v_i_int"]]
append_to_collection msc_nets [get_nets -of_object [get_ports "pad_CT0_tkn_i_int"]]
append_to_collection msc_nets [get_nets -of_object [get_ports "pad_CT0_clk_i_int"]]

append_to_collection msc_nets [get_nets -of_object [get_ports "pad_CT0_3_i_int"]]
append_to_collection msc_nets [get_nets -of_object [get_ports "pad_CT0_4_i_int"]]
append_to_collection msc_nets [get_nets -of_object [get_ports "pad_CT0_5_i_int"]]
append_to_collection msc_nets [get_nets -of_object [get_ports "pad_CT0_6_i_int"]]
append_to_collection msc_nets [get_nets -of_object [get_ports "pad_CT0_7_i_int"]]

append_to_collection msc_nets [get_nets -of_object [get_ports "pad_ML0_0_i_int"]]
append_to_collection msc_nets [get_nets -of_object [get_ports "pad_ML0_1_i_int"]]
append_to_collection msc_nets [get_nets -of_object [get_ports "pad_ML0_2_i_int"]]
append_to_collection msc_nets [get_nets -of_object [get_ports "pad_ML0_3_i_int"]]

set MUX_cell [get_cells -hier -filter "full_name=~*mux*BSG_DONT_TOUCH*"]
foreach_in_collection cell $MUX_cell {
  append_to_collection -unique msc_nets [get_nets -of_object $cell -filter "(full_name!=VSS)&&(full_name!=VDD)"]
}

add_buffer_on_route -net_prefix bsg_msc -cell_prefix bsg_msc -repeater_distance 100.00 -respect_blockages $msc_nets $msc_buffer


# Legalize buffer locations
legalize_placement -cells [get_cells {bsg_ss* bsg_msc*}]
check_legality -cells [get_cells {bsg_ss* bsg_msc*}]

# Connect wires to inserted buffers
route_eco

# Speed up wires, runtime long but significantly improve timing
add_redundant_vias

# Fix DRCs
route_eco

# Redo extraction if needed
update_timing


# set ss_nets [list]
# foreach {side} {"DL" "DR" "IT"} {
#   set limit [expr {$side == "IT"} ? 2 : 8]
#   for {set i 0} {$i < $limit} {incr i} {
#     foreach {dir} {"i" "o"} {
#       set num  [expr {$side == "DL"} ? {$i/2} : {$i/2+4}]
#       set cell "mem_link_${num}__link"
#       if {$side == "IT"} {set cell "io_link"}
#       append_to_collection "ss_nets" [get_propagated_nets [get_ports "pad_${side}${i}_clk_${dir}_int"] [get_cells $cell]]
#       append_to_collection "ss_nets" [get_propagated_nets [get_ports "pad_${side}${i}_v_${dir}_int"] [get_cells $cell]]
#       append_to_collection "ss_nets" [get_propagated_nets [get_ports "pad_${side}${i}_tkn_${dir}_int"] [get_cells $cell]]
#       for {set j 0} {$j < 16} {incr j} {
#         append_to_collection "ss_nets" [get_propagated_nets [get_ports "pad_${side}${i}_${j}_${dir}_int"] [get_cells $cell]]
#       }
#     }
#   }
# }
# 
# set_attribute [get_shapes -of_object $ss_nets] shape_use "user_route"
# set_attribute [get_vias   -of_object $ss_nets] shape_use "user_route"
# 
# set_attribute [get_shapes -of_object $ss_nets] physical_status "minor_change"
# set_attribute [get_vias   -of_object $ss_nets] physical_status "minor_change"
# 
# route_eco -nets $ss_nets -reroute modified_nets_only



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
