
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

proc insert_buffers_on_propagated_nets {port cell num prefix buffer} {
  set opt_nets [get_propagated_nets $port $cell]
  for {set i 0} {$i < $num} {incr i} {
    # FIXME: assume no overflow
    set curr_net [get_nets [index_collection $opt_nets $i]]
    add_buffer_on_route -net_prefix $prefix -cell_prefix $prefix -repeater_distance_length_ratio 0.5 -respect_blockages $curr_net $buffer
  }
}


# Speed up wires, runtime long but significantly improve timing
add_redundant_vias

# Fix DRCs
route_eco


# Enable StarRC extraction before route optimization
if {[file exists [which $ROUTE_OPT_STARRC_CONFIG_FILE]]} {
	set_app_options -name extract.starrc_mode -value true
	set_starrc_in_design -config $ROUTE_OPT_STARRC_CONFIG_FILE ;# example: route_opt.starrc_config_example.txt
	
	## Update timing with StarRC extraction
	;#
	;# The tool automatically performs RC extraction when it updates the timing information.
	;#
	;# Timing is automatically updated by commands that need the information, such as the
	;# report_timing command. The update_timing command explicitly prepares the design for
	;# further analysis. The default is to perform an incremental analysis, which updates
	;# only out-of-date information and runs more quickly. Since there is no change in design
	;# between first and second route_opt runs, automatic incremental analysis means no
	;# analysis at all. Therefore, second route_opt run will use out-of-date timing and
	;# RC extraction, resulting in poor QoR.
	;#
	;# To use the parasitic information from the StarRC extraction, we override this default
	;# behavior using the -full option, which causes the entire timing update to be performed
	;# from the beginning. Runtime is longer with -full option.
	puts "RM-info: Running update_timing with StarRC extraction"
	update_timing -full
} elseif {$ROUTE_OPT_STARRC_CONFIG_FILE != ""} {
	puts "RM-error: ROUTE_OPT_STARRC_CONFIG_FILE($ROUTE_OPT_STARRC_CONFIG_FILE) is invalid. Please correct it."
}


# Report Timing
set pre_in_setup  [get_attribute -name slack -object [get_timing_paths -group REGIN  -delay_type max]]
set pre_in_hold   [get_attribute -name slack -object [get_timing_paths -group REGIN  -delay_type min]]
set pre_out_setup [get_attribute -name slack -object [get_timing_paths -group REGOUT -delay_type max]]
set pre_out_hold  [get_attribute -name slack -object [get_timing_paths -group REGOUT -delay_type min]]
puts "BSG-info: REGIN  group SETUP pre route_opt slack: ${pre_in_setup}"
puts "BSG-info: REGIN  group HOLD  pre route_opt slack: ${pre_in_hold}"
puts "BSG-info: REGOUT group SETUP pre route_opt slack: ${pre_out_setup}"
puts "BSG-info: REGOUT group HOLD  pre route_opt slack: ${pre_out_hold}"




# Route optimization
set opt_buffer "SC7P5T_CKBUFX8_SSC14R"
set opt_prefix "bsg_opt"
set opt_buffer_delay 17.68 ;# Estimated value
set channel_width 16

# Step 0: detect buffer delay


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
      lappend clk_num_buffers_list [expr max(0, round($clk_shift/$opt_buffer_delay))]
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
      insert_buffers_on_propagated_nets $clk_port $clk_cell $clk_num_buffers $opt_prefix $opt_buffer
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
        lappend data_num_buffers_list [expr max(0, round($data_shift/$opt_buffer_delay))]
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
        insert_buffers_on_propagated_nets $data_port $data_cell $data_num $opt_prefix $opt_buffer
        incr data_idx
      }
    }
  }
}


# Step 3: Legalize buffer locations
legalize_placement -cells [get_cells ${opt_prefix}*]
check_legality -cells [get_cells ${opt_prefix}*]


# Step 4: Fix DRCs
route_eco


# Step 5: Report Timing
set post_in_setup  [get_attribute -name slack -object [get_timing_paths -group REGIN  -delay_type max]]
set post_in_hold   [get_attribute -name slack -object [get_timing_paths -group REGIN  -delay_type min]]
set post_out_setup [get_attribute -name slack -object [get_timing_paths -group REGOUT -delay_type max]]
set post_out_hold  [get_attribute -name slack -object [get_timing_paths -group REGOUT -delay_type min]]
puts "BSG-info: REGIN  group SETUP post route_opt slack: ${post_in_setup}"
puts "BSG-info: REGIN  group HOLD  post route_opt slack: ${post_in_hold}"
puts "BSG-info: REGOUT group SETUP post route_opt slack: ${post_out_setup}"
puts "BSG-info: REGOUT group HOLD  post route_opt slack: ${post_out_hold}"


