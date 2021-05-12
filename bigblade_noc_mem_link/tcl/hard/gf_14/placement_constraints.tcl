puts "BSG-info: Running script [info script]\n"

source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_common_variables.tcl
#set_app_options -name plan.place.auto_generate_blockages -value false

# Uncomment if you are sourcing this file many times interactively.
#set_fixed_objects -unfix [get_flat_cells]

# grid_width  = 13.44
# grid_height = 5.76


# before-mirror margins
#set keepout_margin_left   0.058
#set keepout_margin_bottom 0.134
#set keepout_margin_right  0.007
#set keepout_margin_top    0.134
#set keepout_margins [list $keepout_margin_left $keepout_margin_bottom $keepout_margin_right $keepout_margin_top]
#
#set boundary_cell_width  [expr 8*[unit_width]]
#set boundary_cell_height [expr 1*[unit_height]]
#
#set harden_fifo_mem [get_cells -hier -filter "ref_name=~gf14_* && full_name=~*downstream/harden*fifo/*"]
#
#set_macro_relative_location \
#  -target_object $harden_fifo_mem \
#  -target_corner tl \
#  -target_orientation MY \
#  -anchor_corner tl \
#  -offset [list [expr $keepout_margin_right+$boundary_cell_width] [expr -$keepout_margin_top-$boundary_cell_height]]
#
#create_keepout_margin -type hard -outer $keepout_margins $harden_fifo_mem


set                ddr_link_0_cell [get_cells "ddr_link_0__link"]
move_object       $ddr_link_0_cell -x 13.44 -y 80.64
set_attribute     $ddr_link_0_cell orientation R0
set_fixed_objects $ddr_link_0_cell

set                ddr_link_1_cell [get_cells "ddr_link_1__link"]
move_object       $ddr_link_1_cell -x 13.44 -y 0
set_attribute     $ddr_link_1_cell orientation R0
set_fixed_objects $ddr_link_1_cell

# placement boundaries next to hardened blocks
create_placement_blockage -boundary {{13.104 80.64} {13.44 155.52}}
create_placement_blockage -boundary {{53.76 80.64} {54.096 155.52}}
create_placement_blockage -boundary {{13.104 0} {13.44 74.88}}
create_placement_blockage -boundary {{53.76 0} {54.096 74.88}}

for {set i 0} {$i < 2} {incr i} {
  foreach {dir} {"in" "out"} {
    set typ [expr {$dir == "in"} ? {"idelay"} : {"odelay"}]
    set ori [expr {$dir == "in"} ? {"R0"} : {"MY"}]
    for {set j 0} {$j < 18} {incr j} {
      create_rp_group -name "RP${dir}_${i}_${j}" -columns 6
      add_to_rp_group "RP${dir}_${i}_${j}" -cells [get_flat_cells -filter "full_name=~ddr_link_${i}__${typ}/sig_${j}__dly0*"] -column 0 -num_columns 1
      add_to_rp_group "RP${dir}_${i}_${j}" -cells [get_flat_cells -filter "full_name=~ddr_link_${i}__${typ}/sig_${j}__dly1*"] -column 1 -num_columns 1
      add_to_rp_group "RP${dir}_${i}_${j}" -cells [get_flat_cells -filter "full_name=~ddr_link_${i}__${typ}/sig_${j}__dly2*"] -column 2 -num_columns 1
      add_to_rp_group "RP${dir}_${i}_${j}" -cells [get_flat_cells -filter "full_name=~ddr_link_${i}__${typ}/sig_${j}__mux*" ] -column 3 -num_columns 3
      set_rp_group_options "RP${dir}_${i}_${j}" -group_orientation $ori
    }
  }
}

for {set i 0} {$i < 2} {incr i} {
  foreach {dir} {"in" "out"} {
    create_rp_group -name "RP${dir}_${i}" -rows 18
    add_to_rp_group "RP${dir}_${i}" -rp_group "RP${dir}_${i}_16" -row 0
    for {set j 0} {$j < 8} {incr j} {add_to_rp_group "RP${dir}_${i}" -rp_group "RP${dir}_${i}_${j}" -row [expr $j+1]}
    add_to_rp_group "RP${dir}_${i}" -rp_group "RP${dir}_${i}_17" -row 9
    for {set j 8} {$j < 16} {incr j} {add_to_rp_group "RP${dir}_${i}" -rp_group "RP${dir}_${i}_${j}" -row [expr $j+2]}
    set_rp_group_options "RP${dir}_${i}" -group_orientation "R0"
  }
}

#set clk_gen_noc_bound [create_bound -name "clk_gen_noc" -type soft -boundary {{26.32 64.88} {40.32 74.88}}]
#set clk_gen_io_bound  [create_bound -name "clk_gen_io"  -type soft -boundary {{26.32 54.88} {40.32 64.88}}]
#add_to_bound ${clk_gen_noc_bound} [get_cells -hier -filter "full_name=~clk_gen_noc/*"]
#add_to_bound ${clk_gen_io_bound}  [get_cells -hier -filter "full_name=~clk_gen_io/*"]
#
#set iddr_bound [create_bound -name "iddr" -type soft -boundary {{0.00 7.50} {15.00 20.00}}]
#set oddr_bound [create_bound -name "oddr" -type soft -boundary {{0.00 0.00} {15.00 7.50}}]
#add_to_bound ${iddr_bound} [get_cells -hier -filter "full_name=~*iddr_phy/*"]
#add_to_bound ${oddr_bound} [get_cells -hier -filter "full_name=~*oddr_phy/*"]

#set downstream_fifo_bound [create_bound -name "downstream_fifo" -type soft -boundary {{26.32 17.92} {40.32 26.88}}]
#add_to_bound ${downstream_fifo_bound} [get_cells -hier -filter "full_name=~*in_sipof/*"]

puts "BSG-info: Completed script [info script]\n"
