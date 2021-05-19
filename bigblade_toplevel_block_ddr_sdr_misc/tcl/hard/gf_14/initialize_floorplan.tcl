  
#initialize_floorplan -control_type core -coincident_boundary true -shape R -side_length {10526.04 8526.24} -core_offset {0 0}

# Original core area dimensions
set original_x 10526.04
set original_y 8526.24

# Extra gap allocated for core
set extra_gap_x 70
set extra_gap_y 70

# New dimensions
set new_x [expr $original_x+2*$extra_gap_x]
set new_y [expr $original_y+2*$extra_gap_y]

# Init floorplan
initialize_floorplan -control_type core -coincident_boundary true -shape R -side_length {10666.04 8666.24} -core_offset {0 0}
