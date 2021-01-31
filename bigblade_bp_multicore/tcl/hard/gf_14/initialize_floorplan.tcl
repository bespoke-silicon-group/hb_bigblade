# TODO: Move to common
set bp_pod_width [expr 400]
set bp_pod_height [expr 1500]

# constraints
if { ${DESIGN_NAME} == "bsg_blackparrot_multicore_tile_node" } {
  set keepout_margin_x [expr 6*[unit_width]]
  set keepout_margin_y [expr 1*[unit_height]]
  set keepout_margins [list $keepout_margin_x $keepout_margin_y $keepout_margin_x $keepout_margin_y]

  set dcache_data_mems [get_cells -hier -filter "ref_name=~gf14_* && full_name=~*dcache*data_mem_*"]

  set data_mem_width         [lindex [get_attribute [get_cell -hier $dcache_data_mems] width ] 0]
  set data_mem_height        [lindex [get_attribute [get_cell -hier $dcache_data_mems] height] 0]

  set tile_height [round_up_to_nearest [expr 8*($data_mem_height + $keepout_margin_y)+$keepout_margin_y] [unit_height]]

  initialize_floorplan        \
    -control_type die         \
    -coincident_boundary true \
    -shape R                  \
    -core_offset 0.0          \
    -side_length [list $bp_pod_width $tile_height]

} elseif { ${DESIGN_NAME} == "bsg_blackparrot_multicore_pod" } {

  initialize_floorplan        \
    -control_type die         \
    -coincident_boundary true \
    -shape R                  \
    -core_offset 0.0          \
    -side_length [list $bp_pod_width $bp_pod_height]
}

