set bsg_designs_dir         $::env(TESTING_BSG_DESIGNS_DIR)
set bsg_designs_target_dir  $::env(TESTING_BSG_DESIGNS_TARGET_DIR)
set bsg_packaging_dir       $::env(TESTING_BSG_PACKAGING_DIR)
set basejump_stl_dir        $::env(TESTING_BASEJUMP_STL_DIR)
set bsg_manycore_dir        $::env(TESTING_BSG_MANYCORE_DIR)
set board_dir               $::env(TESTING_BOARD_DIR)

set TESTING_PACKAGE_FILES [join "
  $basejump_stl_dir/bsg_misc/bsg_defines.v
  $basejump_stl_dir/bsg_cache/bsg_cache_pkg.v
  $basejump_stl_dir/bsg_noc/bsg_noc_pkg.v
  $basejump_stl_dir/bsg_noc/bsg_wormhole_router_pkg.v
  $basejump_stl_dir/bsg_noc/bsg_mesh_router_pkg.v
  $basejump_stl_dir/bsg_tag/bsg_tag_pkg.v
  $bsg_manycore_dir/v/bsg_manycore_addr_pkg.v
  $bsg_manycore_dir/v/bsg_manycore_pkg.v
  $bsg_designs_target_dir/v/bsg_chip_pkg.v
"]

set TESTING_SOURCE_FILES [join "
  $TESTING_PACKAGE_FILES

  $bsg_designs_target_dir/testing/v/testbench.v
  $bsg_designs_target_dir/testing/v/bsg_nonsynth_wormhole_test_mem.v

  $basejump_stl_dir/bsg_test/bsg_nonsynth_clock_gen.v
  $basejump_stl_dir/bsg_test/bsg_nonsynth_reset_gen.v

  $basejump_stl_dir/bsg_misc/bsg_inv.v
  $basejump_stl_dir/bsg_misc/bsg_buf.v
  $basejump_stl_dir/bsg_misc/bsg_dff.v
  $basejump_stl_dir/bsg_misc/bsg_dff_en.v
  $basejump_stl_dir/bsg_misc/bsg_dff_reset.v
  $basejump_stl_dir/bsg_misc/bsg_dff_reset_set_clear.v
  $basejump_stl_dir/bsg_misc/bsg_dff_reset_en.v
  $basejump_stl_dir/bsg_misc/bsg_dff_chain.v
  $basejump_stl_dir/bsg_misc/bsg_counter_clear_up.v
  $basejump_stl_dir/bsg_misc/bsg_counter_up_down.v
  $basejump_stl_dir/bsg_misc/bsg_counter_up_down_variable.v
  $basejump_stl_dir/bsg_misc/bsg_counter_set_down.v
  $basejump_stl_dir/bsg_misc/bsg_mux2_gatestack.v
  $basejump_stl_dir/bsg_misc/bsg_mux_one_hot.v
  $basejump_stl_dir/bsg_misc/bsg_mux.v
  $basejump_stl_dir/bsg_misc/bsg_cycle_counter.v
  $basejump_stl_dir/bsg_misc/bsg_circular_ptr.v
  $basejump_stl_dir/bsg_misc/bsg_gray_to_binary.v
  $basejump_stl_dir/bsg_misc/bsg_scan.v
  $basejump_stl_dir/bsg_misc/bsg_round_robin_arb.v
  $basejump_stl_dir/bsg_misc/bsg_crossbar_o_by_i.v
  $basejump_stl_dir/bsg_misc/bsg_decode_with_v.v
  $basejump_stl_dir/bsg_misc/bsg_decode.v
  $basejump_stl_dir/bsg_misc/bsg_transpose.v
  $basejump_stl_dir/bsg_misc/bsg_concentrate_static.v
  $basejump_stl_dir/bsg_misc/bsg_array_concentrate_static.v
  $basejump_stl_dir/bsg_misc/bsg_unconcentrate_static.v
  $basejump_stl_dir/bsg_misc/bsg_encode_one_hot.v
  $basejump_stl_dir/bsg_misc/bsg_arb_round_robin.v

  $basejump_stl_dir/bsg_mem/bsg_mem_1rw_sync.v
  $basejump_stl_dir/bsg_mem/bsg_mem_1rw_sync_synth.v
  $basejump_stl_dir/bsg_mem/bsg_mem_1r1w.v
  $basejump_stl_dir/bsg_mem/bsg_mem_1r1w_synth.v
  $basejump_stl_dir/bsg_mem/bsg_mem_1rw_sync_mask_write_byte.v
  $basejump_stl_dir/bsg_mem/bsg_mem_1rw_sync_mask_write_byte_synth.v

  $basejump_stl_dir/bsg_async/bsg_launch_sync_sync.v
  $basejump_stl_dir/bsg_async/bsg_sync_sync.v
  $basejump_stl_dir/bsg_async/bsg_async_fifo.v
  $basejump_stl_dir/bsg_async/bsg_async_ptr_gray.v
  $basejump_stl_dir/bsg_async/bsg_async_credit_counter.v

  $basejump_stl_dir/bsg_tag/bsg_tag_trace_replay.v
  $basejump_stl_dir/bsg_tag/bsg_tag_master.v
  $basejump_stl_dir/bsg_tag/bsg_tag_client.v

  $basejump_stl_dir/bsg_noc/bsg_ready_and_link_async_to_wormhole.v
  $basejump_stl_dir/bsg_noc/bsg_noc_repeater_node.v
  $basejump_stl_dir/bsg_noc/bsg_wormhole_router.v
  $basejump_stl_dir/bsg_noc/bsg_wormhole_router_decoder_dor.v
  $basejump_stl_dir/bsg_noc/bsg_wormhole_router_input_control.v
  $basejump_stl_dir/bsg_noc/bsg_wormhole_router_output_control.v
  $basejump_stl_dir/bsg_noc/bsg_wormhole_concentrator.v
  $basejump_stl_dir/bsg_noc/bsg_wormhole_concentrator_in.v
  $basejump_stl_dir/bsg_noc/bsg_wormhole_concentrator_out.v
  $basejump_stl_dir/bsg_noc/bsg_mesh_router_buffered.v
  $basejump_stl_dir/bsg_noc/bsg_mesh_router.v
  $basejump_stl_dir/bsg_noc/bsg_mesh_router_decoder_dor.v


  $basejump_stl_dir/bsg_dataflow/bsg_1_to_n_tagged_fifo.v
  $basejump_stl_dir/bsg_dataflow/bsg_1_to_n_tagged.v
  $basejump_stl_dir/bsg_dataflow/bsg_round_robin_1_to_n.v
  $basejump_stl_dir/bsg_dataflow/bsg_round_robin_n_to_1.v
  $basejump_stl_dir/bsg_dataflow/bsg_parallel_in_serial_out.v
  $basejump_stl_dir/bsg_dataflow/bsg_serial_in_parallel_out_full.v
  $basejump_stl_dir/bsg_dataflow/bsg_two_fifo.v
  $basejump_stl_dir/bsg_dataflow/bsg_one_fifo.v
  $basejump_stl_dir/bsg_dataflow/bsg_fifo_1r1w_small.v
  $basejump_stl_dir/bsg_dataflow/bsg_fifo_1r1w_small_unhardened.v
  $basejump_stl_dir/bsg_dataflow/bsg_channel_tunnel.v
  $basejump_stl_dir/bsg_dataflow/bsg_channel_tunnel_in.v
  $basejump_stl_dir/bsg_dataflow/bsg_channel_tunnel_out.v
  $basejump_stl_dir/bsg_dataflow/bsg_fifo_tracker.v
  $basejump_stl_dir/bsg_dataflow/bsg_fifo_1r1w_pseudo_large.v
  $basejump_stl_dir/bsg_dataflow/bsg_fifo_1rw_large.v
  $basejump_stl_dir/bsg_dataflow/bsg_serial_in_parallel_out.v


  $bsg_manycore_dir/v/bsg_manycore_link_sif_tieoff.v
  $bsg_manycore_dir/v/bsg_manycore_ruche_x_link_sif_tieoff.v
  $bsg_manycore_dir/v/bsg_ruche_link_sif_tieoff.v
  $bsg_manycore_dir/v/bsg_ruche_buffer.v
  $bsg_manycore_dir/v/bsg_ruche_anti_buffer.v
  $bsg_manycore_dir/v/bsg_manycore_mesh_node.v
  $bsg_manycore_dir/v/bsg_manycore_hor_io_router.v
  $bsg_manycore_dir/v/bsg_manycore_hor_io_router_column.v
  $bsg_manycore_dir/v/bsg_manycore_endpoint_standard.v
  $bsg_manycore_dir/v/bsg_manycore_endpoint.v
  $bsg_manycore_dir/v/bsg_manycore_reg_id_parity_decode.v
  $bsg_manycore_dir/v/bsg_manycore_lock_ctrl.v
  $bsg_manycore_dir/v/bsg_1hold.v
  $bsg_manycore_dir/testbenches/common/v/bsg_nonsynth_manycore_io_complex.v
  $bsg_manycore_dir/testbenches/common/v/bsg_nonsynth_manycore_monitor.v
  $bsg_manycore_dir/testbenches/common/v/bsg_nonsynth_manycore_spmd_loader.v


"]
