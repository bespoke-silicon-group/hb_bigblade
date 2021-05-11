#------------------------------------------------------------
# Do NOT arbitrarily change the order of files. Some module
# and macro definitions may be needed by the subsequent files
#------------------------------------------------------------

set basejump_stl_dir       $::env(BASEJUMP_STL_DIR)
set bsg_designs_target_dir $::env(BSG_DESIGNS_TARGET_DIR)
set bsg_manycore_dir       $::env(BSG_MANYCORE_DIR)

set bsg_packaging_dir $::env(BSG_PACKAGING_DIR)
set bsg_package       $::env(BSG_PACKAGE)
set bsg_pinout        $::env(BSG_PINOUT)
set bsg_padmapping    $::env(BSG_PADMAPPING)

set brg_cgra_xcel_dir $bsg_designs_target_dir/brg_cgra_xcel
set hardfloat_dir     $bsg_designs_target_dir/HardFloat
set bigblade_dir      $bsg_designs_target_dir/..

set cgra_dir $bsg_designs_target_dir/cgra

set SVERILOG_SOURCE_FILES [join "

  $basejump_stl_dir/bsg_noc/bsg_noc_pkg.v
  $basejump_stl_dir/bsg_cache/bsg_cache_pkg.v
  $basejump_stl_dir/bsg_noc/bsg_mesh_router_pkg.v
  $basejump_stl_dir/bsg_tag/bsg_tag_pkg.v
  $basejump_stl_dir/bsg_noc/bsg_wormhole_router_pkg.v
  $bsg_manycore_dir/v/bsg_manycore_pkg.v
  $basejump_stl_dir/bsg_misc/bsg_less_than.v
  $basejump_stl_dir/bsg_misc/bsg_reduce.v
  $basejump_stl_dir/bsg_misc/bsg_abs.v
  $basejump_stl_dir/bsg_misc/bsg_mul_synth.v
  $basejump_stl_dir/bsg_misc/bsg_priority_encode.v
  $basejump_stl_dir/bsg_misc/bsg_priority_encode_one_hot_out.v
  $basejump_stl_dir/bsg_misc/bsg_encode_one_hot.v
  $basejump_stl_dir/bsg_misc/bsg_scan.v
  $basejump_stl_dir/bsg_misc/bsg_mux.v
  $basejump_stl_dir/bsg_misc/bsg_mux_one_hot.v
  $basejump_stl_dir/bsg_misc/bsg_mux_segmented.v
  $basejump_stl_dir/bsg_misc/bsg_mux_bitwise.v
  $basejump_stl_dir/bsg_misc/bsg_dff.v
  $basejump_stl_dir/bsg_misc/bsg_dff_chain.v
  $basejump_stl_dir/bsg_misc/bsg_dff_en_bypass.v
  $basejump_stl_dir/bsg_misc/bsg_dff_en.v
  $basejump_stl_dir/bsg_misc/bsg_dff_reset.v
  $basejump_stl_dir/bsg_misc/bsg_dff_reset_en.v
  $basejump_stl_dir/bsg_misc/bsg_dff_reset_set_clear.v
  $basejump_stl_dir/bsg_misc/bsg_transpose.v
  $basejump_stl_dir/bsg_misc/bsg_crossbar_o_by_i.v
  $basejump_stl_dir/bsg_misc/bsg_decode_with_v.v
  $basejump_stl_dir/bsg_misc/bsg_decode.v
  $basejump_stl_dir/bsg_misc/bsg_counter_clear_up.v
  $basejump_stl_dir/bsg_misc/bsg_counter_up_down.v
  $basejump_stl_dir/bsg_misc/bsg_counter_set_down.v
  $basejump_stl_dir/bsg_misc/bsg_round_robin_arb.v
  $basejump_stl_dir/bsg_misc/bsg_arb_round_robin.v
  $basejump_stl_dir/bsg_misc/bsg_circular_ptr.v
  $basejump_stl_dir/bsg_misc/bsg_imul_iterative.v
  $basejump_stl_dir/bsg_misc/bsg_idiv_iterative.v
  $basejump_stl_dir/bsg_misc/bsg_idiv_iterative_controller.v
  $basejump_stl_dir/bsg_misc/bsg_inv.v
  $basejump_stl_dir/bsg_misc/bsg_buf.v
  $basejump_stl_dir/bsg_misc/bsg_buf_ctrl.v
  $basejump_stl_dir/bsg_misc/bsg_xnor.v
  $basejump_stl_dir/bsg_misc/bsg_nor2.v
  $basejump_stl_dir/bsg_misc/bsg_adder_cin.v
  $basejump_stl_dir/bsg_misc/bsg_expand_bitmask.v
  $basejump_stl_dir/bsg_misc/bsg_lru_pseudo_tree_decode.v
  $basejump_stl_dir/bsg_misc/bsg_lru_pseudo_tree_encode.v
  $basejump_stl_dir/bsg_misc/bsg_lru_pseudo_tree_backup.v
  $basejump_stl_dir/bsg_misc/bsg_thermometer_count.v
  $basejump_stl_dir/bsg_misc/bsg_id_pool.v
  $basejump_stl_dir/bsg_misc/bsg_concentrate_static.v
  $basejump_stl_dir/bsg_misc/bsg_array_concentrate_static.v
  $basejump_stl_dir/bsg_misc/bsg_unconcentrate_static.v
  $basejump_stl_dir/bsg_misc/bsg_mux2_gatestack.v
  $basejump_stl_dir/bsg_dataflow/bsg_fifo_1r1w_large.v
  $basejump_stl_dir/bsg_dataflow/bsg_fifo_1rw_large.v
  $basejump_stl_dir/bsg_dataflow/bsg_fifo_1r1w_small.v
  $basejump_stl_dir/bsg_dataflow/bsg_fifo_1r1w_small_unhardened.v
  $basejump_stl_dir/bsg_dataflow/bsg_two_fifo.v
  $basejump_stl_dir/bsg_dataflow/bsg_round_robin_n_to_1.v
  $basejump_stl_dir/bsg_dataflow/bsg_round_robin_2_to_2.v
  $basejump_stl_dir/bsg_dataflow/bsg_parallel_in_serial_out.v
  $basejump_stl_dir/bsg_dataflow/bsg_serial_in_parallel_out.v
  $basejump_stl_dir/bsg_dataflow/bsg_fifo_tracker.v
  $basejump_stl_dir/bsg_dataflow/bsg_make_2D_array.v
  $basejump_stl_dir/bsg_dataflow/bsg_flatten_2D_array.v
  
  $basejump_stl_dir/bsg_mem/bsg_mem_1r1w.v
  $basejump_stl_dir/bsg_mem/bsg_mem_1r1w_synth.v
  $basejump_stl_dir/bsg_mem/bsg_mem_1r1w_sync.v
  $basejump_stl_dir/bsg_mem/bsg_mem_1r1w_sync_synth.v
  $basejump_stl_dir/bsg_mem/bsg_mem_1rw_sync.v
  $basejump_stl_dir/bsg_mem/bsg_mem_1rw_sync_synth.v
  $basejump_stl_dir/bsg_mem/bsg_mem_2r1w_sync.v
  $basejump_stl_dir/bsg_mem/bsg_mem_2r1w_sync_synth.v
  $basejump_stl_dir/bsg_mem/bsg_mem_3r1w_sync.v
  $basejump_stl_dir/bsg_mem/bsg_mem_3r1w_sync_synth.v
  $basejump_stl_dir/bsg_mem/bsg_mem_1rw_sync_mask_write_byte.v
  $basejump_stl_dir/bsg_mem/bsg_mem_1rw_sync_mask_write_byte_synth.v
  $basejump_stl_dir/bsg_mem/bsg_mem_1rw_sync_mask_write_bit.v
  $basejump_stl_dir/bsg_mem/bsg_mem_1rw_sync_mask_write_bit_synth.v
  
  $basejump_stl_dir/bsg_noc/bsg_mesh_stitch.v
  $basejump_stl_dir/bsg_noc/bsg_mesh_router.v
  $basejump_stl_dir/bsg_noc/bsg_mesh_router_decoder_dor.v
  $basejump_stl_dir/bsg_noc/bsg_mesh_router_buffered.v
  $basejump_stl_dir/bsg_noc/bsg_wormhole_router.v
  $basejump_stl_dir/bsg_noc/bsg_wormhole_router_decoder_dor.v
  $basejump_stl_dir/bsg_noc/bsg_wormhole_router_input_control.v
  $basejump_stl_dir/bsg_noc/bsg_wormhole_router_output_control.v
  $basejump_stl_dir/bsg_noc/bsg_wormhole_concentrator.v
  $basejump_stl_dir/bsg_noc/bsg_wormhole_concentrator_in.v
  $basejump_stl_dir/bsg_noc/bsg_wormhole_concentrator_out.v
  
  $basejump_stl_dir/bsg_async/bsg_launch_sync_sync.v
  $basejump_stl_dir/bsg_async/bsg_sync_sync.v
  $basejump_stl_dir/bsg_async/bsg_async_fifo.v
  $basejump_stl_dir/bsg_async/bsg_async_ptr_gray.v
  $hardfloat_dir/source/fNToRecFN.v
  $hardfloat_dir/source/compareRecFN.v
  $hardfloat_dir/source/divSqrtRecFN_small.v
  $hardfloat_dir/source/iNToRecFN.v
  $hardfloat_dir/source/mulAddRecFN.v
  $hardfloat_dir/source/recFNToFN.v
  $hardfloat_dir/source/HardFloat_rawFN.v
  $hardfloat_dir/source/HardFloat_primitives.v
  $hardfloat_dir/source/isSigNaNRecFN.v
  $hardfloat_dir/source/recFNToIN.v
  $hardfloat_dir/source/RISCV/HardFloat_specialize.v
  
  $bsg_manycore_dir/v/bsg_cache_dma_to_wormhole.v
  $bsg_manycore_dir/v/bsg_manycore_hetero_socket.v
  $bsg_manycore_dir/v/bsg_manycore_mesh_node.v
  $bsg_manycore_dir/v/bsg_manycore_endpoint.v
  $bsg_manycore_dir/v/bsg_manycore_endpoint_fc.v
  $bsg_manycore_dir/v/bsg_manycore_endpoint_standard.v
  $bsg_manycore_dir/v/bsg_manycore_reg_id_decode.v
  $bsg_manycore_dir/v/bsg_manycore_eva_to_npa.v
  $bsg_manycore_dir/v/bsg_manycore_link_sif_tieoff.v
  $bsg_manycore_dir/v/bsg_manycore_ruche_x_link_sif_tieoff.v
  $bsg_manycore_dir/v/bsg_ruche_buffer.v
  $bsg_manycore_dir/v/bsg_ruche_anti_buffer.v
  
  $basejump_stl_dir/bsg_misc/bsg_xor.v
  $basejump_stl_dir/bsg_async/bsg_async_credit_counter.v
  $basejump_stl_dir/bsg_misc/bsg_array_reverse.v
  $basejump_stl_dir/bsg_misc/bsg_gray_to_binary.v
  $basejump_stl_dir/bsg_misc/bsg_binary_plus_one_to_gray.v
  $basejump_stl_dir/bsg_misc/bsg_wait_cycles.v
  $basejump_stl_dir/bsg_misc/bsg_counter_up_down_variable.v
  $basejump_stl_dir/bsg_dataflow/bsg_channel_tunnel.v
  $basejump_stl_dir/bsg_dataflow/bsg_channel_tunnel_in.v
  $basejump_stl_dir/bsg_dataflow/bsg_channel_tunnel_out.v
  $basejump_stl_dir/bsg_dataflow/bsg_1_to_n_tagged_fifo.v
  $basejump_stl_dir/bsg_dataflow/bsg_1_to_n_tagged.v
  $basejump_stl_dir/bsg_dataflow/bsg_fifo_1r1w_pseudo_large.v
  $basejump_stl_dir/bsg_fsb/bsg_fsb_pkg.v
  $basejump_stl_dir/bsg_link/bsg_link_sdr.v
  $basejump_stl_dir/bsg_link/bsg_link_sdr_downstream.v
  $basejump_stl_dir/bsg_link/bsg_link_sdr_upstream.v
  
  $basejump_stl_dir/hard/gf_14/bsg_link/bsg_link_isdr_phy.v
  $basejump_stl_dir/hard/gf_14/bsg_link/bsg_link_osdr_phy.v
  
  $basejump_stl_dir/bsg_link/bsg_link_osdr_phy_phase_align.v
  $basejump_stl_dir/bsg_link/bsg_link_source_sync_downstream.v
  $basejump_stl_dir/bsg_link/bsg_link_source_sync_upstream_sync.v
  $bigblade_dir/common/sdr/sdr_horizontal/v/bsg_manycore_link_ruche_to_sdr_east.v
  
  $bsg_manycore_dir/v/bsg_manycore_hor_io_router.v
  $bsg_manycore_dir/v/bsg_manycore_hor_io_router_column.v
  $cgra_dir/v/hard/gf_14/sram/SramWrapper.v
  $cgra_dir/v/HBEndpointCGRAXcel_8x8Array_4x4KBSpads__pickled.v
  $cgra_dir/v/brg_8x8_cgra_xcel.v
  $cgra_dir/v/brg_cgra_pod.v
"]
