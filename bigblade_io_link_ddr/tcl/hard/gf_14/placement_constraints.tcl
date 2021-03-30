
set keepout_margin_x [expr 6*[unit_width]]
set keepout_margin_y [expr 1*[unit_height]]
set keepout_margins [list $keepout_margin_x $keepout_margin_y $keepout_margin_x $keepout_margin_y]

set harden_fifo_mem [get_cells -hier -filter "ref_name=~gf14_* && full_name=~*downstream/harden_fifo/*"]

set_macro_relative_location \
  -target_object $harden_fifo_mem \
  -target_corner tl \
  -target_orientation R0 \
  -anchor_corner tl \
  -offset [list $keepout_margin_x [expr -$keepout_margin_y-13.00]]

create_keepout_margin -type hard -outer $keepout_margins $harden_fifo_mem

set clk_gen_bound [create_bound -name "clk_gen" -type soft -boundary {{0 83.00} {13 96.00}}]
add_to_bound ${clk_gen_bound} [get_cells -hier -filter "full_name=~clk_gen/*"]