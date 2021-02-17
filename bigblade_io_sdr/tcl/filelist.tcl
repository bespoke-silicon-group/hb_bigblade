#------------------------------------------------------------
# Do NOT arbitrarily change the order of files. Some module
# and macro definitions may be needed by the subsequent files
#------------------------------------------------------------

set basejump_stl_dir       $::env(BASEJUMP_STL_DIR)
set bsg_designs_target_dir $::env(BSG_DESIGNS_TARGET_DIR)

set bsg_packaging_dir $::env(BSG_PACKAGING_DIR)
set bsg_package       $::env(BSG_PACKAGE)
set bsg_pinout        $::env(BSG_PINOUT)
set bsg_padmapping    $::env(BSG_PADMAPPING)

set SVERILOG_SOURCE_FILES [join "
    $basejump_stl_dir/bsg_misc/bsg_defines.v
    $basejump_stl_dir/bsg_noc/bsg_noc_pkg.v
    $basejump_stl_dir/bsg_async/bsg_async_fifo.v
    $basejump_stl_dir/bsg_async/bsg_async_ptr_gray.v
    $basejump_stl_dir/bsg_async/bsg_sync_sync.v
    $basejump_stl_dir/bsg_async/bsg_launch_sync_sync.v
    $basejump_stl_dir/bsg_async/bsg_async_credit_counter.v
    $basejump_stl_dir/bsg_misc/bsg_array_reverse.v
    $basejump_stl_dir/bsg_misc/bsg_scan.v
    $basejump_stl_dir/bsg_misc/bsg_mux.v
    $basejump_stl_dir/bsg_misc/bsg_circular_ptr.v
    $basejump_stl_dir/bsg_misc/bsg_gray_to_binary.v
    $basejump_stl_dir/bsg_misc/bsg_binary_plus_one_to_gray.v
    $basejump_stl_dir/bsg_misc/bsg_wait_cycles.v
    $basejump_stl_dir/bsg_misc/bsg_thermometer_count.v
    $basejump_stl_dir/bsg_misc/bsg_counter_set_down.v
    $basejump_stl_dir/bsg_misc/bsg_counter_up_down.v
    $basejump_stl_dir/bsg_misc/bsg_counter_up_down_variable.v
    $basejump_stl_dir/bsg_misc/bsg_counter_clear_up.v
    $basejump_stl_dir/bsg_misc/bsg_decode_with_v.v
    $basejump_stl_dir/bsg_misc/bsg_decode.v
    $basejump_stl_dir/bsg_misc/bsg_round_robin_arb.v
    $basejump_stl_dir/bsg_misc/bsg_crossbar_o_by_i.v
    $basejump_stl_dir/bsg_misc/bsg_mux_one_hot.v
    $basejump_stl_dir/bsg_misc/bsg_dff.v
    $basejump_stl_dir/bsg_misc/bsg_dff_en.v
    $basejump_stl_dir/bsg_misc/bsg_transpose.v
    $basejump_stl_dir/bsg_misc/bsg_dff_reset.v
    $basejump_stl_dir/bsg_misc/bsg_dff_reset_en.v
    $basejump_stl_dir/bsg_mem/bsg_mem_1r1w_synth.v
    $basejump_stl_dir/bsg_mem/bsg_mem_1r1w.v
    $basejump_stl_dir/bsg_mem/bsg_mem_1r1w_sync.v
    $basejump_stl_dir/bsg_mem/bsg_mem_1r1w_sync_synth.v
    $basejump_stl_dir/bsg_mem/bsg_mem_1rw_sync.v
    $basejump_stl_dir/bsg_mem/bsg_mem_1rw_sync_synth.v
    $basejump_stl_dir/bsg_dataflow/bsg_fifo_tracker.v
    $basejump_stl_dir/bsg_dataflow/bsg_fifo_1r1w_small.v
    $basejump_stl_dir/bsg_dataflow/bsg_fifo_1r1w_small_hardened.v
    $basejump_stl_dir/bsg_dataflow/bsg_fifo_1r1w_small_unhardened.v
    $basejump_stl_dir/bsg_dataflow/bsg_one_fifo.v
    $basejump_stl_dir/bsg_dataflow/bsg_two_fifo.v
    $basejump_stl_dir/bsg_dataflow/bsg_fifo_1r1w_large.v
    $basejump_stl_dir/bsg_dataflow/bsg_fifo_1rw_large.v
    $basejump_stl_dir/bsg_dataflow/bsg_channel_tunnel.v
    $basejump_stl_dir/bsg_dataflow/bsg_channel_tunnel_in.v
    $basejump_stl_dir/bsg_dataflow/bsg_channel_tunnel_out.v
    $basejump_stl_dir/bsg_dataflow/bsg_1_to_n_tagged_fifo.v
    $basejump_stl_dir/bsg_dataflow/bsg_1_to_n_tagged.v
    $basejump_stl_dir/bsg_dataflow/bsg_round_robin_1_to_n.v
    $basejump_stl_dir/bsg_dataflow/bsg_round_robin_n_to_1.v
    $basejump_stl_dir/bsg_dataflow/bsg_round_robin_2_to_2.v
    $basejump_stl_dir/bsg_dataflow/bsg_serial_in_parallel_out.v
    $basejump_stl_dir/bsg_dataflow/bsg_fifo_1r1w_pseudo_large.v
    $basejump_stl_dir/bsg_dataflow/bsg_parallel_in_serial_out.v
    $basejump_stl_dir/bsg_dataflow/bsg_serial_in_parallel_out_full.v
    $basejump_stl_dir/bsg_misc/bsg_concentrate_static.v
    $basejump_stl_dir/bsg_misc/bsg_array_concentrate_static.v
    $basejump_stl_dir/bsg_misc/bsg_unconcentrate_static.v
    $basejump_stl_dir/bsg_noc/bsg_noc_pkg.v
    $basejump_stl_dir/bsg_noc/bsg_wormhole_router_decoder_dor.v
    $basejump_stl_dir/bsg_noc/bsg_wormhole_router_input_control.v  
    $basejump_stl_dir/bsg_noc/bsg_wormhole_router_output_control.v 
    $basejump_stl_dir/bsg_noc/bsg_wormhole_router_pkg.v       
    $basejump_stl_dir/bsg_test/test_bsg_data_gen.v
    $basejump_stl_dir/bsg_test/bsg_nonsynth_delay_line.v
    $basejump_stl_dir/bsg_noc/bsg_wormhole_router.v
    $basejump_stl_dir/bsg_noc/bsg_wormhole_concentrator.v
    $basejump_stl_dir/bsg_fsb/bsg_fsb_pkg.v
    $basejump_stl_dir/bsg_link/bsg_link_sdr_downstream.v
    $basejump_stl_dir/bsg_link/bsg_link_sdr_upstream.v
    $basejump_stl_dir/bsg_link/bsg_link_isdr_phy.v
    $basejump_stl_dir/bsg_link/bsg_link_osdr_phy.v
    $basejump_stl_dir/bsg_link/bsg_link_osdr_phy_phase_align.v
    $basejump_stl_dir/bsg_link/bsg_link_source_sync_downstream.v
    $basejump_stl_dir/bsg_link/bsg_link_source_sync_upstream_sync.v

    $bsg_designs_target_dir/v/bsg_chip_pkg.v
    $bsg_designs_target_dir/v/bsg_sdr_one_side.v
"]
