
set keepout_margin_x [expr 6*[unit_width]]
set keepout_margin_y [expr 1*[unit_height]]
set keepout_margins [list $keepout_margin_x $keepout_margin_y $keepout_margin_x $keepout_margin_y]

set harden_fifo_mem [get_cells -hier -filter "ref_name=~gf14_* && full_name=~*downstream/harden*fifo/*"]

set_macro_relative_location \
  -target_object $harden_fifo_mem \
  -target_corner tl \
  -target_orientation MY \
  -anchor_corner tl \
  -offset [list $keepout_margin_x -$keepout_margin_y]

create_keepout_margin -type hard -outer $keepout_margins $harden_fifo_mem

set clk_gen_noc_bound [create_bound -name "clk_gen_noc" -type soft -boundary {{26.32 64.88} {40.32 74.88}}]
set clk_gen_io_bound  [create_bound -name "clk_gen_io"  -type soft -boundary {{26.32 54.88} {40.32 64.88}}]
add_to_bound ${clk_gen_noc_bound} [get_cells -hier -filter "full_name=~clk_gen_noc/*"]
add_to_bound ${clk_gen_io_bound}  [get_cells -hier -filter "full_name=~clk_gen_io/*"]

set iddr_bound [create_bound -name "iddr" -type soft -boundary {{0.00 7.00} {20.00 20.00}}]
set oddr_bound [create_bound -name "oddr" -type soft -boundary {{0.00 0.00} {20.00 13.00}}]
add_to_bound ${iddr_bound} [get_cells -hier -filter "full_name=~*iddr_phy/*"]
add_to_bound ${oddr_bound} [get_cells -hier -filter "full_name=~*oddr_phy/*"]

#set downstream_fifo_bound [create_bound -name "downstream_fifo" -type soft -boundary {{26.32 17.92} {40.32 26.88}}]
#add_to_bound ${downstream_fifo_bound} [get_cells -hier -filter "full_name=~*in_sipof/*"]
