
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

proc insert_buffers_on_propagated_nets {port cell num start_num prefix buffer} {
  set opt_nets [get_propagated_nets $port $cell]
  for {set i $start_num} {$i < [expr $num+$start_num]} {incr i} {
    # FIXME: assume no overflow
    set curr_net [get_nets [index_collection $opt_nets $i]]
    add_buffer_on_route -net_prefix $prefix -cell_prefix $prefix -repeater_distance_length_ratio 0.5 -respect_blockages $curr_net $buffer
  }
}

# BSG-STD: In R-2020.09*, extract.starrc_mode attribute type changed from bool to string
if {[string match "R-2020.09*" [get_app_option_value -name shell.common.product_version]]} {
  set BSG_STARRC_MODE_TRUE "in_design"
} else {
  set BSG_STARRC_MODE_TRUE "true"
}

# Enable StarRC extraction before route optimization
# WARNING: DISABLED because it crashes ICC2
#if {[file exists [which $ROUTE_OPT_STARRC_CONFIG_FILE]]} {
#	set_app_options -name extract.starrc_mode -value $BSG_STARRC_MODE_TRUE
#	set_starrc_in_design -config $ROUTE_OPT_STARRC_CONFIG_FILE ;# example: route_opt.starrc_config_example.txt
#	
#	## Update timing with StarRC extraction
#	;#
#	;# The tool automatically performs RC extraction when it updates the timing information.
#	;#
#	;# Timing is automatically updated by commands that need the information, such as the
#	;# report_timing command. The update_timing command explicitly prepares the design for
#	;# further analysis. The default is to perform an incremental analysis, which updates
#	;# only out-of-date information and runs more quickly. Since there is no change in design
#	;# between first and second route_opt runs, automatic incremental analysis means no
#	;# analysis at all. Therefore, second route_opt run will use out-of-date timing and
#	;# RC extraction, resulting in poor QoR.
#	;#
#	;# To use the parasitic information from the StarRC extraction, we override this default
#	;# behavior using the -full option, which causes the entire timing update to be performed
#	;# from the beginning. Runtime is longer with -full option.
#	puts "RM-info: Running update_timing with StarRC extraction"
#	update_timing -full
#} elseif {$ROUTE_OPT_STARRC_CONFIG_FILE != ""} {
#	puts "RM-error: ROUTE_OPT_STARRC_CONFIG_FILE($ROUTE_OPT_STARRC_CONFIG_FILE) is invalid. Please correct it."
#}


if {[string match "R-2020.09*" [get_app_option_value -name shell.common.product_version]]} {
  remove_routing_rules [get_routing_rules {ss_*_ndr}]
  create_routing_rule opt_x2_ndr -multiplier_spacing 2

  set ss_nets  [get_nets bsg_ss*]
  append_to_collection ss_nets [get_nets {wh_link_*_l* mc_*_link_*_l*}]
  append_to_collection ss_nets [get_nets {pad_D*_*_*_int pad_IT*_*_*_int}]
  set_routing_rule -rule opt_x2_ndr -min_routing_layer M2 -max_routing_layer K4 $ss_nets
}


# Route optimization setup
set opt_buffer "SC7P5T_CKBUFX8_SSC14R"
set opt_prefix "bsg_opt"
set opt_buffer_delay(i) 17.68 ;# Estimated value
set opt_buffer_delay(o) 17.68 ;# Estimated value
set channel_width 16
set start_buffer_offset 1

set calib_scenatio "sspg_0p72v_125c_sigcmax"
set calib_num_buffers 5
set calib_side "DR"
set calib_ch 5
set calib_bit 0


# calibrate buffer delay
create_undo_marker calib_undo_marker

set calib_shift_list [list]
foreach {dir} {"i" "o"} {
  set calib_port  [get_ports "pad_${calib_side}${calib_ch}_${calib_bit}_${dir}_int"]
  set calib_setup [get_attribute -name slack -object [get_timing_paths -scenario $calib_scenatio -through $calib_port -delay_type max]]
  set calib_hold  [get_attribute -name slack -object [get_timing_paths -scenario $calib_scenatio -through $calib_port -delay_type min]]
  set calib_shift [expr ($calib_hold-$calib_setup)/2.0]
  lappend calib_shift_list $calib_shift
}
foreach {dir} {"i" "o"} {
  set cell_num  [expr {$calib_side == "DR"} ? {$calib_ch/2+4} : {$calib_ch/2}]
  set cell_name [expr {$calib_side == "IT"} ? {"io_link"} : {"mem_link_${cell_num}__link"}]
  set calib_port  [get_ports "pad_${calib_side}${calib_ch}_clk_${dir}_int"]
  set calib_cell  [get_cells $cell_name]
  insert_buffers_on_propagated_nets $calib_port $calib_cell $calib_num_buffers $start_buffer_offset $opt_prefix $opt_buffer
}
set calib_idx 0
foreach {dir} {"i" "o"} {
  set calib_port  [get_ports "pad_${calib_side}${calib_ch}_${calib_bit}_${dir}_int"]
  set calib_setup [get_attribute -name slack -object [get_timing_paths -scenario $calib_scenatio -through $calib_port -delay_type max]]
  set calib_hold  [get_attribute -name slack -object [get_timing_paths -scenario $calib_scenatio -through $calib_port -delay_type min]]
  set calib_shift_post [expr ($calib_hold-$calib_setup)/2.0]
  set calib_shift_pre  [lindex $calib_shift_list $calib_idx]
  set opt_buffer_delay($dir) [expr ($calib_shift_pre-$calib_shift_post)/$calib_num_buffers]
  incr calib_idx
}
puts "Buffer delay for input has been calibrated to $opt_buffer_delay(i)"
puts "Buffer delay for output has been calibrated to $opt_buffer_delay(o)"

undo -marker calib_undo_marker
update_timing -full ;# must update timing full after undo


# Report Pre Timing
set pre_in_setup  [get_attribute -name slack -object [get_timing_paths -group REGIN  -delay_type max]]
set pre_in_hold   [get_attribute -name slack -object [get_timing_paths -group REGIN  -delay_type min]]
set pre_out_setup [get_attribute -name slack -object [get_timing_paths -group REGOUT -delay_type max]]
set pre_out_hold  [get_attribute -name slack -object [get_timing_paths -group REGOUT -delay_type min]]
puts "BSG-info: REGIN  group SETUP pre route_opt slack: ${pre_in_setup}"
puts "BSG-info: REGIN  group HOLD  pre route_opt slack: ${pre_in_hold}"
puts "BSG-info: REGOUT group SETUP pre route_opt slack: ${pre_out_setup}"
puts "BSG-info: REGOUT group HOLD  pre route_opt slack: ${pre_out_hold}"


# Step 1: fix setup by inserting buffers to clock line
set clk_num_buffers_list [list]
foreach {side} {"DL" "DR" "IT"} {
  set limit [expr {$side == "IT"} ? 2 : 8]
  for {set i 0} {$i < $limit} {incr i} {
    foreach {dir} {"i" "o"} {
      set point     [expr {$dir == "i"} ? {"startpoint"} : {"endpoint"}]
      set all_ports [get_ports "pad_${side}${i}_*_${dir}_int"]
      set wns_port  [get_attribute -name $point -object [get_timing_paths -through $all_ports -delay_type max]]
      set clk_setup [get_attribute -name slack -object [get_timing_paths -through $wns_port -delay_type max]]
      set clk_hold  [get_attribute -name slack -object [get_timing_paths -through $wns_port -delay_type min]]
      set clk_shift [expr ($clk_hold-$clk_setup)/2.0]
      lappend clk_num_buffers_list [expr max(0, round($clk_shift/$opt_buffer_delay($dir)))]
    }
  }
}
set clk_idx 0
foreach {side} {"DL" "DR" "IT"} {
  set limit [expr {$side == "IT"} ? 2 : 8]
  for {set i 0} {$i < $limit} {incr i} {
    foreach {dir} {"i" "o"} {
      set cell_num  [expr {$side == "DR"} ? {$i/2+4} : {$i/2}]
      set cell_name [expr {$side == "IT"} ? {"io_link"} : {"mem_link_${cell_num}__link"}]
      set clk_port  [get_ports "pad_${side}${i}_clk_${dir}_int"]
      set clk_cell  [get_cells $cell_name]
      set clk_num_buffers [lindex $clk_num_buffers_list $clk_idx]
      insert_buffers_on_propagated_nets $clk_port $clk_cell $clk_num_buffers $start_buffer_offset $opt_prefix $opt_buffer
      incr clk_idx
    }
  }
}


# Step 2: fix hold by inserting buffers to data lines
set data_num_buffers_list [list]
foreach {side} {"DL" "DR" "IT"} {
  set limit [expr {$side == "IT"} ? 2 : 8]
  for {set i 0} {$i < $limit} {incr i} {
    foreach {dir} {"i" "o"} {
      for {set w 0} {$w < [expr $channel_width+1]} {incr w} {
        set dv [expr {$w == $channel_width} ? {"v"} : {$w}]
        set data_port  [get_ports "pad_${side}${i}_${dv}_${dir}_int"]
        set data_setup [get_attribute -name slack -object [get_timing_paths -through $data_port -delay_type max]]
        set data_hold  [get_attribute -name slack -object [get_timing_paths -through $data_port -delay_type min]]
        set data_shift [expr ($data_setup-$data_hold)/2.0]
        lappend data_num_buffers_list [expr max(0, round($data_shift/$opt_buffer_delay($dir)))]
      }
    }
  }
}
set data_idx 0
foreach {side} {"DL" "DR" "IT"} {
  set limit [expr {$side == "IT"} ? 2 : 8]
  for {set i 0} {$i < $limit} {incr i} {
    foreach {dir} {"i" "o"} {
      for {set w 0} {$w < [expr $channel_width+1]} {incr w} {
        set dv [expr {$w == $channel_width} ? {"v"} : {$w}]
        set cell_num  [expr {$side == "DR"} ? {$i/2+4} : {$i/2}]
        set cell_name [expr {$side == "IT"} ? {"io_link"} : {"mem_link_${cell_num}__link"}]
        set data_port [get_ports "pad_${side}${i}_${dv}_${dir}_int"]
        set data_cell [get_cells $cell_name]
        set data_num  [lindex $data_num_buffers_list $data_idx]
        insert_buffers_on_propagated_nets $data_port $data_cell $data_num $start_buffer_offset $opt_prefix $opt_buffer
        incr data_idx
      }
    }
  }
}


# Step 3: Legalize buffer locations
legalize_placement
check_legality


# Step 4: Fix DRCs
route_eco


# create vertical link clocks
set num_ver_links [expr 64+2]
for {set i 0} {$i < 4} {incr i} {
  set wh_master_clk_name   "pod_row_${i}_master_clk"
  set start_idx [expr {$i == 0} ? {$num_ver_links} : {0}]
  set end_idx   [expr {$i == 3} ? {$num_ver_links} : {2*$num_ver_links}]
  for {set j $start_idx} {$j < $end_idx} {incr j} {
    foreach {k} {"fwd" "rev"} {
      create_generated_clock \
          -divide_by 1 \
          -invert \
          -master_clock $wh_master_clk_name \
          -add \
          -source [get_attribute [get_clocks $wh_master_clk_name] sources] \
          -name "ver_link_${i}_${j}_${k}_clk" \
          [get_pins "core_complex_core_${i}__podrow/ver_io_${k}_link_clk_o[${j}]"]
      set_propagated_clock [get_clocks "ver_link_${i}_${j}_${k}_clk"] 
    }
  }
}

update_timing -full ;# Extract design again before report timing


# Report Post Timing
set post_in_setup  [get_attribute -name slack -object [get_timing_paths -group REGIN  -delay_type max]]
set post_in_hold   [get_attribute -name slack -object [get_timing_paths -group REGIN  -delay_type min]]
set post_out_setup [get_attribute -name slack -object [get_timing_paths -group REGOUT -delay_type max]]
set post_out_hold  [get_attribute -name slack -object [get_timing_paths -group REGOUT -delay_type min]]
puts "BSG-info: REGIN  group SETUP post route_opt slack: ${post_in_setup}"
puts "BSG-info: REGIN  group HOLD  post route_opt slack: ${post_in_hold}"
puts "BSG-info: REGOUT group SETUP post route_opt slack: ${post_out_setup}"
puts "BSG-info: REGOUT group HOLD  post route_opt slack: ${post_out_hold}"


