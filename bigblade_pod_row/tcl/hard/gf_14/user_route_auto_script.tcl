set all_nets [list]
# manycore
set manycore_cells [get_cells "podrow/px_*__pod/mc_y_*__mc_x_0__mc"]
append_to_collection all_nets [get_nets -of [get_pins -of $manycore_cells -filter "name=~reset*"]]
append_to_collection all_nets [get_nets -of [get_pins -of $manycore_cells -filter "name=~*link_sif_*"]]
append_to_collection all_nets [get_nets -of [get_pins -of $manycore_cells -filter "name=~ruche_link_*"]]
append_to_collection all_nets [get_nets -of [get_pins -of $manycore_cells -filter "name=~global_*"]]
# vcache
set vcache_cells [get_cells "podrow/px_*__pod/*_vc_x_0__*_vc_row"]
append_to_collection all_nets [get_nets -of [get_pins -of $vcache_cells -filter "name=~reset*"]]
append_to_collection all_nets [get_nets -of [get_pins -of $vcache_cells -filter "name=~wh_link_sif*"]]
append_to_collection all_nets [get_nets -of [get_pins -of $vcache_cells -filter "name=~ver_link_sif*"]]
append_to_collection all_nets [get_nets -of [get_pins -of $vcache_cells -filter "name=~global_*"]]
# SDR north
set sdr_north_cells [get_cells "sdr_n_x_*__sdr_n"]
append_to_collection all_nets [get_nets -of [get_pins -of $sdr_north_cells -filter "name=~core_reset_ver_o*"]]
append_to_collection all_nets [get_nets -of [get_pins -of $sdr_north_cells -filter "name=~core_reset_o*"]]
append_to_collection all_nets [get_nets -of [get_pins -of $sdr_north_cells -filter "name=~core_global*"]]
append_to_collection all_nets [get_nets -of [get_pins -of $sdr_north_cells -filter "name=~core_link_sif*"]]
append_to_collection all_nets [get_nets -of [get_pins -of $sdr_north_cells -filter "name=~async_*reset*"]]
append_to_collection all_nets [get_nets -of [get_pins -of $sdr_north_cells -filter "name=~io*"]]
append_to_collection all_nets [get_nets -of [get_pins -of $sdr_north_cells -filter "name=~tag_data_i"]]
append_to_collection all_nets [get_nets -of [get_pins -of $sdr_north_cells -filter "name=~node_id_offset_i*"]]
append_to_collection all_nets [get_nets -of [get_pins -of $sdr_north_cells -filter "name=~async*disable*"]]

# SDR south
set sdr_south_cells [get_cells "sdr_s_x_*__sdr_s"]
append_to_collection all_nets [get_nets -of [get_pins -of $sdr_south_cells -filter "name=~core_link_sif*"]]
append_to_collection all_nets [get_nets -of [get_pins -of $sdr_south_cells -filter "name=~async_*reset*"]]
append_to_collection all_nets [get_nets -of [get_pins -of $sdr_south_cells -filter "name=~io*"]]
append_to_collection all_nets [get_nets -of [get_pins -of $sdr_south_cells -filter "name=~async*disable*"]]

# SDR horizontal
set sdr_horiz_cells [get_cells "sdr_*_y_*__sdr_*"]
append_to_collection all_nets [get_nets -of [get_pins -of $sdr_horiz_cells -filter "name=~core_*_link_sif*"]]
append_to_collection all_nets [get_nets -of [get_pins -of $sdr_horiz_cells -filter "name=~core_ruche_link*"]]
append_to_collection all_nets [get_nets -of [get_pins -of $sdr_horiz_cells -filter "name=~core_global*"]]
append_to_collection all_nets [get_nets -of [get_pins -of $sdr_horiz_cells -filter "name=~core_reset*"]]
append_to_collection all_nets [get_nets -of [get_pins -of $sdr_horiz_cells -filter "name=~async*reset*"]]
append_to_collection all_nets [get_nets -of [get_pins -of $sdr_horiz_cells -filter "name=~io*"]]
append_to_collection all_nets [get_nets -of [get_pins -of $sdr_horiz_cells -filter "name=~async*disable*"]]

# SDR corner
set sdr_corner_cells [list]
append_to_collection sdr_corner_cells [get_cell "sdr_nw"]
append_to_collection sdr_corner_cells [get_cell "sdr_ne"]
append_to_collection sdr_corner_cells [get_cell "sdr_sw"]
append_to_collection sdr_corner_cells [get_cell "sdr_se"]
append_to_collection all_nets [get_nets -of [get_pins -of $sdr_corner_cells -filter "name=~core_reset*"]]
append_to_collection all_nets [get_nets -of [get_pins -of $sdr_corner_cells -filter "name=~core_ver_link_sif*"]]
append_to_collection all_nets [get_nets -of [get_pins -of $sdr_corner_cells -filter "name=~core_wh_link_sif*"]]
append_to_collection all_nets [get_nets -of [get_pins -of $sdr_corner_cells -filter "name=~core_global*"]]
append_to_collection all_nets [get_nets -of [get_pins -of $sdr_corner_cells -filter "name=~async_*"]]
append_to_collection all_nets [get_nets -of [get_pins -of $sdr_corner_cells -filter "name=~io_*"]]
append_to_collection all_nets [get_nets -of [get_pins -of $sdr_corner_cells -filter "name=~tag_data_i"]]
append_to_collection all_nets [get_nets -of [get_pins -of $sdr_corner_cells -filter "name=~tag_node_id_offset_i*"]]
append_to_collection all_nets [get_nets -of [get_pins -of $sdr_corner_cells -filter "name=~async*disable*"]]

# route everything
route_group -nets $all_nets

# locked physical status
set_attribute -objects $all_nets -name physical_status -value locked
