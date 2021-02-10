
set tile_width [round_up_to_nearest 50 [unit_width]]
set tile_height [round_up_to_nearest 50 [unit_height]]

initialize_floorplan        \
  -control_type die         \
  -coincident_boundary true \
  -shape R                  \
  -core_offset 0.0          \
  -side_length [list $tile_width $tile_height]

