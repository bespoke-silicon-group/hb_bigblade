
set keepout_margin_x [expr 6*[unit_width]]
set keepout_margin_y [expr 1*[unit_height]]
set keepout_margins [list $keepout_margin_x $keepout_margin_y $keepout_margin_x $keepout_margin_y]

set harden_fifo_mem [get_cells -hier -filter "ref_name=~gf14_* && full_name=~*mem*/*"]

set_macro_relative_location \
  -target_object $harden_fifo_mem \
  -target_corner tl \
  -target_orientation R0 \
  -anchor_corner tl \
  -offset [list $keepout_margin_x -5]

create_keepout_margin -type hard -outer $keepout_margins $harden_fifo_mem

set isdr_bound [create_bound -name "isdr" -type hard -boundary {{0.00 58.664} {25.92 63.664}}]
set osdr_bound [create_bound -name "osdr" -type hard -boundary {{0.00 0.00} {25.92 5.00}}]
add_to_bound ${isdr_bound} [get_cells -hier -filter "full_name=~*isdr*"]
add_to_bound ${osdr_bound} [get_cells -hier -filter "full_name=~*osdr*"]
