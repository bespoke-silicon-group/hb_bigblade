puts "BSG-info: Running script [info script]\n"

# ==============================================================================
# Move the tap cells
# ==============================================================================

set tap_cells [get_cells -filter ref_name=~*_TAP*]
set_fixed_object -unfix $tap_cells
move_object $tap_cells -x $decap_w
set_fixed_object $tap_cells

# ==============================================================================
# Surround the block with DECAP
# ==============================================================================

create_boundary_cells \
  -left_boundary_cell               $decap_boundary_cell \
  -right_boundary_cell              $decap_boundary_cell \
  -top_boundary_cells               [list $decap_top_bot_boundary_cell $filler_x3_cell $filler_x2_cell] \
  -bottom_boundary_cells            [list $decap_top_bot_boundary_cell $filler_x3_cell $filler_x2_cell] \
  -top_right_outside_corner_cell    $decap_boundary_cell \
  -top_left_outside_corner_cell     $decap_boundary_cell \
  -bottom_right_outside_corner_cell $decap_boundary_cell \
  -bottom_left_outside_corner_cell  $decap_boundary_cell \
  -no_1x

puts "BSG-info: Completed script [info script]\n"
