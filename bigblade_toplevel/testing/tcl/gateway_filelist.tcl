#------------------------------------------------------------
# Do NOT arbitrarily change the order of files. Some module
# and macro definitions may be needed by the subsequent files
#------------------------------------------------------------

set basejump_stl_dir       $::env(TESTING_BASEJUMP_STL_DIR)
set bsg_manycore_dir       $::env(TESTING_BSG_MANYCORE_DIR)
set bsg_replicant_dir      $::env(TESTING_BSG_REPLICANT_DIR)
set bsg_designs_dir        $::env(TESTING_BSG_DESIGNS_DIR)
set bsg_designs_target_dir $::env(TESTING_BSG_DESIGNS_TARGET_DIR)
set board_dir              $::env(TESTING_BOARD_DIR)
set bsg_packaging_dir      $::env(TESTING_BSG_PACKAGING_DIR)
set bsg_out_dir            $::env(TESTING_BSG_OUT_DIR)

set bsg_package       $::env(BSG_PACKAGE)
set bsg_pinout        $::env(BSG_PINOUT)
set bsg_padmapping    $::env(BSG_PADMAPPING)

set TESTING_PACKAGE_FILES [join "
  $basejump_stl_dir/bsg_misc/bsg_defines.v
  $basejump_stl_dir/bsg_cache/bsg_cache_pkg.v
  $basejump_stl_dir/bsg_noc/bsg_noc_pkg.v
  $basejump_stl_dir/bsg_noc/bsg_wormhole_router_pkg.v
  $basejump_stl_dir/bsg_tag/bsg_tag_pkg.v
  $bsg_manycore_dir/v/bsg_manycore_addr_pkg.v
  $bsg_manycore_dir/v/bsg_manycore_pkg.v
  $bsg_designs_target_dir/../common/v/bsg_chip_pkg.v
  $bsg_manycore_dir/testbenches/common/v/bsg_manycore_network_cfg_pkg.v
  $bsg_manycore_dir/testbenches/common/v/bsg_manycore_mem_cfg_pkg.v
  $bsg_out_dir/bsg_bladerunner_pkg.v
  $bsg_replicant_dir/hardware/bsg_manycore_endpoint_to_fifos_pkg.v
"]

set TESTING_SOURCE_FILES [join "
  $TESTING_PACKAGE_FILES
  $basejump_stl_dir/bsg_async/bsg_async_credit_counter.v
  $basejump_stl_dir/bsg_async/bsg_async_fifo.v
  $basejump_stl_dir/bsg_async/bsg_async_ptr_gray.v
  $basejump_stl_dir/bsg_async/bsg_launch_sync_sync.v
  $basejump_stl_dir/bsg_async/bsg_sync_sync.v
  $basejump_stl_dir/bsg_cache/bsg_cache_to_axi_rx.v
  $basejump_stl_dir/bsg_cache/bsg_cache_to_axi_tx.v
  $basejump_stl_dir/bsg_dataflow/bsg_1_to_n_tagged_fifo.v
  $basejump_stl_dir/bsg_dataflow/bsg_1_to_n_tagged.v
  $basejump_stl_dir/bsg_dataflow/bsg_channel_tunnel_in.v
  $basejump_stl_dir/bsg_dataflow/bsg_channel_tunnel_out.v
  $basejump_stl_dir/bsg_dataflow/bsg_channel_tunnel.v
  $basejump_stl_dir/bsg_dataflow/bsg_channel_tunnel_wormhole.v
  $basejump_stl_dir/bsg_dataflow/bsg_fifo_1r1w_large.v
  $basejump_stl_dir/bsg_dataflow/bsg_fifo_1r1w_pseudo_large.v
  $basejump_stl_dir/bsg_dataflow/bsg_fifo_1r1w_small.v
  $basejump_stl_dir/bsg_dataflow/bsg_fifo_1r1w_small_unhardened.v
  $basejump_stl_dir/bsg_dataflow/bsg_fifo_1rw_large.v
  $basejump_stl_dir/bsg_dataflow/bsg_fifo_tracker.v
  $basejump_stl_dir/bsg_dataflow/bsg_one_fifo.v
  $basejump_stl_dir/bsg_dataflow/bsg_parallel_in_serial_out.v
  $basejump_stl_dir/bsg_dataflow/bsg_round_robin_1_to_n.v
  $basejump_stl_dir/bsg_dataflow/bsg_round_robin_2_to_2.v
  $basejump_stl_dir/bsg_dataflow/bsg_round_robin_n_to_1.v
  $basejump_stl_dir/bsg_dataflow/bsg_serial_in_parallel_out_full.v
  $basejump_stl_dir/bsg_dataflow/bsg_serial_in_parallel_out.v
  $basejump_stl_dir/bsg_dataflow/bsg_two_fifo.v
  $basejump_stl_dir/bsg_fsb/bsg_fsb_node_trace_replay.v
  $basejump_stl_dir/bsg_link/bsg_link_ddr_downstream.v
  $basejump_stl_dir/bsg_link/bsg_link_ddr_upstream.v
  $basejump_stl_dir/bsg_link/bsg_link_iddr_phy.v
  $basejump_stl_dir/bsg_link/bsg_link_oddr_phy.v
  $basejump_stl_dir/bsg_link/bsg_link_source_sync_downstream.v
  $basejump_stl_dir/bsg_link/bsg_link_source_sync_upstream.v
  $basejump_stl_dir/bsg_mem/bsg_mem_1r1w_synth.v
  $basejump_stl_dir/bsg_mem/bsg_mem_1r1w.v
  $basejump_stl_dir/bsg_mem/bsg_mem_1rw_sync_mask_write_bit_synth.v
  $basejump_stl_dir/bsg_mem/bsg_mem_1rw_sync_mask_write_bit.v
  $basejump_stl_dir/bsg_mem/bsg_mem_1rw_sync_mask_write_byte_synth.v
  $basejump_stl_dir/bsg_mem/bsg_mem_1rw_sync_mask_write_byte.v
  $basejump_stl_dir/bsg_mem/bsg_mem_1rw_sync_synth.v
  $basejump_stl_dir/bsg_mem/bsg_mem_1rw_sync.v
  $basejump_stl_dir/bsg_mem/bsg_mem_2r1w_sync_synth.v
  $basejump_stl_dir/bsg_mem/bsg_mem_2r1w_sync.v
  $basejump_stl_dir/bsg_mem/bsg_mem_banked_crossbar.v
  $basejump_stl_dir/bsg_misc/bsg_abs.v
  $basejump_stl_dir/bsg_misc/bsg_adder_cin.v
  $basejump_stl_dir/bsg_misc/bsg_array_reverse.v
  $basejump_stl_dir/bsg_misc/bsg_binary_plus_one_to_gray.v
  $basejump_stl_dir/bsg_misc/bsg_buf_ctrl.v
  $basejump_stl_dir/bsg_misc/bsg_buf.v
  $basejump_stl_dir/bsg_misc/bsg_circular_ptr.v
  $basejump_stl_dir/bsg_misc/bsg_counter_clear_up.v
  $basejump_stl_dir/bsg_misc/bsg_counter_set_down.v
  $basejump_stl_dir/bsg_misc/bsg_counter_up_down.v
  $basejump_stl_dir/bsg_misc/bsg_counter_up_down_variable.v
  $basejump_stl_dir/bsg_misc/bsg_crossbar_o_by_i.v
  $basejump_stl_dir/bsg_misc/bsg_cycle_counter.v
  $basejump_stl_dir/bsg_misc/bsg_decode.v
  $basejump_stl_dir/bsg_misc/bsg_decode_with_v.v
  $basejump_stl_dir/bsg_misc/bsg_dff_en_bypass.v
  $basejump_stl_dir/bsg_misc/bsg_dff_en.v
  $basejump_stl_dir/bsg_misc/bsg_dff_reset_en.v
  $basejump_stl_dir/bsg_misc/bsg_dff_reset.v
  $basejump_stl_dir/bsg_misc/bsg_dff.v
  $basejump_stl_dir/bsg_misc/bsg_encode_one_hot.v
  $basejump_stl_dir/bsg_misc/bsg_gray_to_binary.v
  $basejump_stl_dir/bsg_misc/bsg_idiv_iterative_controller.v
  $basejump_stl_dir/bsg_misc/bsg_idiv_iterative.v
  $basejump_stl_dir/bsg_misc/bsg_imul_iterative.v
  $basejump_stl_dir/bsg_misc/bsg_less_than.v
  $basejump_stl_dir/bsg_misc/bsg_mul_synth.v
  $basejump_stl_dir/bsg_misc/bsg_mux2_gatestack.v
  $basejump_stl_dir/bsg_misc/bsg_mux_one_hot.v
  $basejump_stl_dir/bsg_misc/bsg_mux_segmented.v
  $basejump_stl_dir/bsg_misc/bsg_mux.v
  $basejump_stl_dir/bsg_misc/bsg_nor2.v
  $basejump_stl_dir/bsg_misc/bsg_priority_encode_one_hot_out.v
  $basejump_stl_dir/bsg_misc/bsg_priority_encode.v
  $basejump_stl_dir/bsg_misc/bsg_reduce.v
  $basejump_stl_dir/bsg_misc/bsg_round_robin_arb.v
  $basejump_stl_dir/bsg_misc/bsg_scan.v
  $basejump_stl_dir/bsg_misc/bsg_thermometer_count.v
  $basejump_stl_dir/bsg_misc/bsg_transpose.v
  $basejump_stl_dir/bsg_misc/bsg_xnor.v
  $basejump_stl_dir/bsg_noc/bsg_mesh_router_buffered.v
  $basejump_stl_dir/bsg_noc/bsg_mesh_router.v
  $basejump_stl_dir/bsg_noc/bsg_mesh_stitch.v
  $basejump_stl_dir/bsg_noc/bsg_noc_links.vh
  $basejump_stl_dir/bsg_noc/bsg_wormhole_router.v
  $basejump_stl_dir/bsg_misc/bsg_unconcentrate_static.v
  $basejump_stl_dir/bsg_misc/bsg_concentrate_static.v
  $basejump_stl_dir/bsg_misc/bsg_array_concentrate_static.v
  $basejump_stl_dir/bsg_noc/bsg_wormhole_router_output_control.v
  $basejump_stl_dir/bsg_noc/bsg_wormhole_router_input_control.v
  $basejump_stl_dir/bsg_noc/bsg_wormhole_router_decoder_dor.v
  $basejump_stl_dir/bsg_noc/bsg_ready_and_link_async_to_wormhole.v
  $basejump_stl_dir/bsg_tag/bsg_tag_client.v
  $basejump_stl_dir/bsg_tag/bsg_tag_master.v
  $basejump_stl_dir/bsg_tag/bsg_tag_trace_replay.v
  $basejump_stl_dir/bsg_test/bsg_nonsynth_clock_gen.v
  $basejump_stl_dir/bsg_test/bsg_nonsynth_reset_gen.v
  $basejump_stl_dir/bsg_test/bsg_nonsynth_delay_line.v
  $basejump_stl_dir/testing/bsg_dataflow/bsg_fifo_1r1w_small_hardened/bsg_fifo_1r1w_small_hardened_test_node.v
  $basejump_stl_dir/testing/bsg_link/bsg_link_ddr_downstream_encode.v

  $bsg_manycore_dir/testbenches/common/v/bsg_nonsynth_manycore_io_complex.v
  $bsg_manycore_dir/testbenches/common/v/bsg_nonsynth_manycore_monitor.v
  $bsg_manycore_dir/testbenches/common/v/bsg_nonsynth_manycore_spmd_loader.v
  $bsg_manycore_dir/testbenches/common/v/bsg_nonsynth_wormhole_test_mem.v
  
  $bsg_manycore_dir/testbenches/dpi/bsg_nonsynth_dpi_manycore.v
  $basejump_stl_dir/bsg_test/bsg_nonsynth_dpi_clock_gen.v
  $basejump_stl_dir/bsg_test/bsg_nonsynth_dpi_gpio.v
  $basejump_stl_dir/bsg_test/bsg_nonsynth_dpi_from_fifo.v
  $basejump_stl_dir/bsg_test/bsg_nonsynth_dpi_to_fifo.v
  $basejump_stl_dir/bsg_test/bsg_nonsynth_dpi_rom.v
  $basejump_stl_dir/bsg_test/bsg_nonsynth_dpi_cycle_counter.v
  $bsg_replicant_dir/hardware/bsg_manycore_endpoint_to_fifos.v

  $basejump_stl_dir/testing/bsg_link/bsg_link_ddr_downstream_encode.v

  $bsg_manycore_dir/v/bsg_manycore_endpoint_standard.v
  $bsg_manycore_dir/v/bsg_manycore_endpoint_fc.v
  $bsg_manycore_dir/v/bsg_manycore_endpoint.v
  $bsg_manycore_dir/v/bsg_manycore_reg_id_decode.v
  $bsg_manycore_dir/v/bsg_manycore_pod_ruche_array.v
  $bsg_manycore_dir/v/bsg_manycore_link_sif_tieoff.v
  $bsg_manycore_dir/v/bsg_manycore_ruche_x_link_sif_tieoff.v
  $bsg_manycore_dir/v/bsg_manycore_pod_ruche.v
  $bsg_manycore_dir/v/bsg_manycore_tile_vcache_array.v
  $bsg_manycore_dir/v/bsg_manycore_tile_vcache.v
  $bsg_manycore_dir/v/bsg_cache_dma_to_wormhole.v
  $bsg_manycore_dir/v/bsg_manycore_tile_compute_array_ruche.v
  $bsg_manycore_dir/v/bsg_manycore_tile_compute_ruche.v
  $bsg_manycore_dir/v/bsg_manycore_hetero_socket.v
  $bsg_manycore_dir/v/bsg_manycore_link_to_cache.v

  $bsg_manycore_dir/v/bsg_manycore_mesh_node.v
  $bsg_manycore_dir/v/bsg_ruche_buffer.v
  $bsg_manycore_dir/v/bsg_ruche_anti_buffer.v
  $bsg_manycore_dir/v/bsg_manycore_eva_to_npa.v

  $board_dir/pcb/bigblade/v/bsg_asic_socket.v
  $board_dir/pcb/bigblade/v/bsg_gateway_socket.v
  $board_dir/pcb/bigblade/v/bsg_bigblade_pcb.v

  $bsg_designs_target_dir/testing/v/bsg_gateway_chip.v
  $bsg_designs_target_dir/testing/v/bsg_gateway_chip_core_complex.v
  $bsg_designs_target_dir/testing/v/bsg_gateway_chip_dpi_manycore.v
  $bsg_designs_target_dir/testing/v/bsg_gateway_chip_io_link_ddr.v
  $bsg_designs_target_dir/testing/v/bsg_gateway_chip_noc_mem_link.v
  $bsg_designs_target_dir/testing/v/bsg_gateway_chip_noc_io_link.v

  $bsg_designs_target_dir/../common/v/bsg_manycore_link_resp_credit_to_ready_and_handshake.v
  $bsg_designs_target_dir/../bigblade_noc_mem_link/v/bsg_ready_and_link_round_robin_static.v
  $bsg_designs_target_dir/../bigblade_noc_io_link/v/bsg_then_ready_link_round_robin_static.v
  $bsg_designs_target_dir/../bigblade_noc_io_link/v/bsg_wide_link_to_then_ready_link.v

"]

