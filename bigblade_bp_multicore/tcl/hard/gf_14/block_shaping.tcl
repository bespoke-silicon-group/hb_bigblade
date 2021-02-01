# TODO: Move to common
set bp_pod_width [expr 400]
set bp_pod_height [expr 1500]

set bp_tile_width [expr 350]
set bp_tile_height [expr 730]

if { ${DESIGN_NAME} == "bsg_blackparrot_unicore_tile_node" } {

} elseif { ${DESIGN_NAME} == "bsg_blackparrot_unicore_pod" } {
    set tile_rows 2
    set tile_cols 1
    set tile_width $bp_tile_width
    set tile_height $bp_tile_height
    set channel_width [expr 10]
    set channel_height [expr 10]
    set tile_x [expr 10]
    set tile_y [expr 10]

    foreach {n} {0 1} {
      append_to_collection bp_tile_cells [get_cells -hier n_${n}__tile_node]
    }

    # Shape the BP tile blocks
    bsg_create_block_array_grid $bp_tile_cells \
      -grid mib_placement_grid \
      -relative_to core \
      -x $tile_x \
      -y $tile_y \
      -rows $tile_rows \
      -cols $tile_cols \
      -min_channel [list $channel_width $channel_height] \
      -width $tile_width \
      -height $tile_height
}

