puts "BSG-info: Running script [info script]\n"

source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_common_variables.tcl
#set_app_options -name plan.place.auto_generate_blockages -value false

# Uncomment if you are sourcing this file many times interactively.
#set_fixed_objects -unfix [get_flat_cells]

# grid_width  = 13.44
# grid_height = 5.76


# before-mirror margins
set keepout_margin_left   0.058
set keepout_margin_bottom 0.134
set keepout_margin_right  0.007
set keepout_margin_top    0.134
set keepout_margins [list $keepout_margin_left $keepout_margin_bottom $keepout_margin_right $keepout_margin_top]
#
set boundary_cell_width  [expr 8*[unit_width]]
set boundary_cell_height [expr 1*[unit_height]]
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
move_object       $ddr_link_0_cell -x 0 -y 40.32
set_attribute     $ddr_link_0_cell orientation R0
set_fixed_objects $ddr_link_0_cell

set                ddr_link_1_cell [get_cells "ddr_link_1__link"]
move_object       $ddr_link_1_cell -x 208.32 -y 40.32
set_attribute     $ddr_link_1_cell orientation MY
set_fixed_objects $ddr_link_1_cell


set harden_fifo_mem0 [get_cells -hier -filter "ref_name=~gf14_* && full_name=~tunnel/*b1_ntf/rof*0*buff*fifo/harden*fifo/*"]
set harden_fifo_mem1 [get_cells -hier -filter "ref_name=~gf14_* && full_name=~tunnel/*b1_ntf/rof*1*buff*fifo/harden*fifo/*"]

set_macro_relative_location \
  -target_object $harden_fifo_mem0 \
  -target_corner tr \
  -target_orientation R0 \
  -anchor_corner tl \
  -offset [list [expr 103.16] [expr -$keepout_margin_top-$boundary_cell_height]]

set_macro_relative_location \
  -target_object $harden_fifo_mem1 \
  -target_corner tl \
  -target_orientation MY \
  -anchor_corner tl \
  -offset [list [expr 105.16] [expr -$keepout_margin_top-$boundary_cell_height]]


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
