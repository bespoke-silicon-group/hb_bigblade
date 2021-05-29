puts "BSG-info running [info script]"


derive_pin_access_routing_guides -cells [get_cells "mem_link_*__link"] -layers {K1 K3} -x_width [expr 0.084*4] -y_width 0.001

#derive_pin_access_routing_guides -cells [get_cells "io_link"] -layers {K1 K3} -x_width [expr 0.084*4] -y_width 0.001
#derive_pin_access_routing_guides -cells [get_cells "io_link"] -layers {K2 K4} -x_width 0.001 -y_width [expr 0.084*4]

derive_pin_access_routing_guides -cells [get_cells "core_complex_core_*__podrow"] -layers {K1 K3} -x_width [expr 0.084*4] -y_width 0.001




source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_common_variables.tcl
set_app_options -name plan.place.auto_generate_blockages -value false

# Uncomment if you are sourcing this file many times interactively.
#set_fixed_objects -unfix [get_flat_cells]



# core area 
set core_llx [get_attribute [get_core_area] bounding_box.ll_x]
set core_lly [get_attribute [get_core_area] bounding_box.ll_y]
set core_urx [get_attribute [get_core_area] bounding_box.ur_x]
set core_ury [get_attribute [get_core_area] bounding_box.ur_y]



# block dimensions
set bp_width   295.68
set cgra_width 510.72
set pod_width  $pod_row_width

set pod_height $pod_row_height
set pod_gap    [expr 11.5*$grid_height]

set noc_mem_width  [expr 8*$grid_width]
set noc_mem_height [expr 27*$grid_height]

set core_width  [expr $core_urx-$core_llx]
set core_height [expr $core_ury-$core_lly]

set ver_shift 0
set hor_gap [expr ($core_width-$bp_width-$cgra_width-$pod_width)/2]
set bottom_ver_gap [expr ($core_height-4*$pod_height-3*$pod_gap)/2-$ver_shift]


# pod row placement
set pod_row_start_x [expr $core_llx+[round_down_to_nearest [expr $hor_gap+$bp_width] $grid_width]]
set pod_row_start_y [expr $core_lly+[round_down_to_nearest $bottom_ver_gap $grid_height]]

for {set i 1} {$i < 4} {incr i} {
  set lly [expr $pod_row_start_y+$i*($pod_height+$pod_gap)-$pod_gap]
  set ury [expr $pod_row_start_y+$i*($pod_height+$pod_gap)]
  create_routing_blockage -name rb_clk_gen -layers [get_layers {M2 C4 K1 K3 H1 G1}] -boundary "{{5225 $lly} {5269 $ury}}"
}


# bp blockages
set bp_start_x [expr $core_llx+[round_down_to_nearest $hor_gap $grid_width]]
for {set i 0} {$i < 4} {incr i} {
  set lly [expr $pod_row_start_y+$i*($pod_height+$pod_gap)+$sdr_vert_row_height+$vcache_array_height]
  set ury [expr $pod_row_start_y+$i*($pod_height+$pod_gap)+$sdr_vert_row_height+$vcache_array_height+3.5*$tile_array_height+2*$grid_height]
  # gap routing blockages
  create_routing_blockage -name rb_bp_gap -layers [get_layers {M3 C5 K2 K4 H2 G2}] -boundary "{{[expr $pod_row_start_x-0.5*$grid_width] $lly} {$pod_row_start_x $ury}}"
}


# cgra blockages
set cgra_start_x [expr $pod_row_start_x+$pod_width+0.5*$grid_width]
for {set i 0} {$i < 4} {incr i} {
  set lly [expr $core_lly+$bottom_ver_gap+$i*($pod_height+$pod_gap)+$sdr_vert_row_height+$vcache_array_height]
  set ury [expr $core_lly+$bottom_ver_gap+$i*($pod_height+$pod_gap)+$pod_height-$sdr_vert_row_height-$vcache_array_height]
  # gap routing blockages
  create_routing_blockage -name rb_cgra_gap -layers [get_layers {M3 C5 K2 K4 H2 G2}] -boundary "{{[expr $cgra_start_x-0.5*$grid_width] $lly} {$cgra_start_x $ury}}"
}



#set esd_width  72.00
#set esd_height 53.00
#
#set esd_start_x    [expr $pod_row_start_x + 162.3]
#set esd_step_x     147.84
#set esd_start_y    [expr $pod_row_start_y - ($pod_gap+$esd_height)/2]
#set esd_step_y     [expr $pod_height+$pod_gap]
#
#set esd_curr_y $esd_start_y
#for {set j 0} {$j < 5} {incr j} {
#  set esd_curr_x $esd_start_x
#  for {set i 0} {$i < 62} {incr i} {
#    set esd_curr_x [expr $esd_curr_x + $esd_step_x]
#    if {$i == 14 || $i == 15 || $i == 45 || $i == 46} {
#      set esd_curr_x [expr $esd_curr_x + 6.72]
#    }
#    if {$i == 30} {
#      set esd_curr_x [expr $esd_curr_x + $esd_step_x + 13.44]
#    }
#  }
#  create_routing_blockage -layers [get_layers {M2 C4 K1 K3 H1 G1}] -boundary "{{$esd_start_x $esd_curr_y} {[expr $esd_curr_x-$esd_step_x+$esd_width] [expr $esd_curr_y+$esd_height]}}"
#  set esd_curr_y [expr $esd_curr_y + $esd_step_y]
#}


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


# global route tag lines
set tag_nets [get_nets {pad_CT0_0_i_int tag_data_lo pad_CT0_v_i_int}]
route_group -nets $tag_nets
remove_routing_blockages [get_routing_blockages {rb_clk_gen*}]


# global route other nets
route_global


# track assignment
route_track


# detail routing
route_detail


for {set i 1} {$i < 4} {incr i} {
  set lly [expr $pod_row_start_y+$i*($pod_height+$pod_gap)-$pod_gap]
  set ury [expr $pod_row_start_y+$i*($pod_height+$pod_gap)]
  # gap placement blockages
  create_placement_blockage -name "pb_pod_gap_${i}_start" -boundary "{{$pod_row_start_x $lly} {[expr $pod_row_start_x+39] $ury}}"
  set curr_llx [expr $pod_row_start_x+95]
  for {set j 0} {$j < 64} {incr j} {
    create_placement_blockage -name "pb_pod_gap_${i}_${j}" -boundary "{{$curr_llx $lly} {[expr $curr_llx+60] $ury}}"
    set curr_llx [expr $curr_llx+11*$grid_width]
    if {[expr $j%16] == 15} { set curr_llx [expr $curr_llx+$grid_width] }
  }
  create_placement_blockage -name "pb_pod_gap_${i}_end" -boundary "{{[expr $pod_row_start_x+$pod_width-42] $lly} {[expr $pod_row_start_x+$pod_width] $ury}}"
}


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


# Length estimation is too slow in toplevel design
# Hardcode length below to speedup routing
set length_(DL0_i) 3243.140
set length_(DL0_o) 3166.468
set length_(DL1_i) 1588.557
set length_(DL1_o) 1680.077
set length_(DL2_i) 2654.077
set length_(DL2_o) 2562.557
set length_(DL3_i) 1031.037
set length_(DL3_o)  938.493
set length_(DL4_i) 1215.996
set length_(DL4_o) 1123.837
set length_(DL5_i) 2235.213
set length_(DL5_o) 2327.756
set length_(DL6_i) 1932.476
set length_(DL6_o) 1829.693
set length_(DL7_i) 3544.125
set length_(DL7_o) 3442.109

set length_(DR0_i) 3027.220
set length_(DR0_o) 3120.276
set length_(DR1_i) 1605.389
set length_(DR1_o) 1677.453
set length_(DR2_i) 2639.933
set length_(DR2_o) 2567.869
set length_(DR3_i) 1016.509
set length_(DR3_o)  945.341
set length_(DR4_i) 1202.365
set length_(DR4_o) 1129.789
set length_(DR5_i) 2252.428
set length_(DR5_o) 2323.725
set length_(DR6_i) 1622.349
set length_(DR6_o) 1709.261
set length_(DR7_i) 3233.741
set length_(DR7_o) 3320.524

set length_(IT0_i) 1799.821
set length_(IT0_o) 1893.005
set length_(IT1_i) 2257.789
set length_(IT1_o) 2180.604


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
      #set max_length 0
      #foreach_in_collection net $ss_link_nets {set max_length [expr max($max_length, [get_estimated_wirelength -nets $net])]}
      set length_idx "${side}${i}_${dir}"
      set max_length $length_($length_idx)
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

# remove routing blockages
remove_routing_blockages [get_routing_blockages {rb_bp_gap* rb_cgra_gap*}]

# Remove placement blockages
remove_placement_blockages [get_placement_blockages pb_pod_gap*]


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
