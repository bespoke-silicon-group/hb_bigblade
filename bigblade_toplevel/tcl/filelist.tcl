### filelist.tcl

#-------------------------------------------------------------------------------
# Do NOT arbitrarily change the order of files. Some module and macro
# definitions may be needed by the subsequent files
#-------------------------------------------------------------------------------

set bsg_designs_target_dir  $::env(BSG_DESIGNS_TARGET_DIR)
set bsg_packaging_dir       $::env(BSG_PACKAGING_DIR)
set bsg_package             $::env(BSG_PACKAGE)
set bsg_pinout              $::env(BSG_PINOUT)
set bsg_padmapping          $::env(BSG_PADMAPPING)
set basejump_stl_dir       $::env(BASEJUMP_STL_DIR)
set bsg_manycore_dir       $::env(BSG_MANYCORE_DIR)

set SVERILOG_PACKAGE_FILES [join "
  $basejump_stl_dir/bsg_misc/bsg_defines.v
  $basejump_stl_dir/bsg_cache/bsg_cache_pkg.v
  $basejump_stl_dir/bsg_noc/bsg_noc_pkg.v
  $basejump_stl_dir/bsg_noc/bsg_mesh_router_pkg.v
  $basejump_stl_dir/bsg_tag/bsg_tag_pkg.v
  $basejump_stl_dir/bsg_noc/bsg_wormhole_router_pkg.v
  $bsg_manycore_dir/v/bsg_manycore_pkg.v
  $bsg_manycore_dir/v/bsg_manycore_addr_pkg.v
  $bsg_manycore_dir/v/vanilla_bean/bsg_vanilla_pkg.v
  $bsg_manycore_dir/imports/HardFloat/source/bsg_hardfloat_pkg.v
  $bsg_designs_target_dir/../common/v/bsg_chip_pkg.v
"]

set SVERILOG_SOURCE_FILES [join "
  $SVERILOG_PACKAGE_FILES
  $basejump_stl_dir/bsg_async/bsg_async_credit_counter.v
  $basejump_stl_dir/bsg_async/bsg_async_fifo.v
  $basejump_stl_dir/bsg_async/bsg_async_ptr_gray.v
  $basejump_stl_dir/bsg_async/bsg_launch_sync_sync.v
  $basejump_stl_dir/bsg_async/bsg_sync_sync.v
  $basejump_stl_dir/bsg_cache/bsg_cache_dma.v
  $basejump_stl_dir/bsg_cache/bsg_cache_miss.v
  $basejump_stl_dir/bsg_cache/bsg_cache_sbuf_queue.v
  $basejump_stl_dir/bsg_cache/bsg_cache_sbuf.v
  $basejump_stl_dir/bsg_cache/bsg_cache.v
  $basejump_stl_dir/bsg_clk_gen/bsg_clk_gen.v
  $basejump_stl_dir/bsg_dataflow/bsg_1_to_n_tagged_fifo.v
  $basejump_stl_dir/bsg_dataflow/bsg_1_to_n_tagged.v
  $basejump_stl_dir/bsg_dataflow/bsg_channel_tunnel_in.v
  $basejump_stl_dir/bsg_dataflow/bsg_channel_tunnel_out.v
  $basejump_stl_dir/bsg_dataflow/bsg_channel_tunnel.v
  $basejump_stl_dir/bsg_dataflow/bsg_channel_tunnel_wormhole.v
  $basejump_stl_dir/bsg_dataflow/bsg_fifo_1r1w_large.v
  $basejump_stl_dir/bsg_dataflow/bsg_fifo_1r1w_pseudo_large.v
  $basejump_stl_dir/bsg_dataflow/bsg_fifo_1r1w_small.v
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
  $basejump_stl_dir/bsg_misc/bsg_arb_fixed.v
  $basejump_stl_dir/bsg_misc/bsg_array_reverse.v
  $basejump_stl_dir/bsg_misc/bsg_binary_plus_one_to_gray.v
  $basejump_stl_dir/bsg_misc/bsg_buf_ctrl.v
  $basejump_stl_dir/bsg_misc/bsg_buf.v
  $basejump_stl_dir/bsg_misc/bsg_circular_ptr.v
  $basejump_stl_dir/bsg_misc/bsg_counter_clear_up.v
  $basejump_stl_dir/bsg_misc/bsg_counter_clock_downsample.v
  $basejump_stl_dir/bsg_misc/bsg_counter_set_down.v
  $basejump_stl_dir/bsg_misc/bsg_counter_up_down.v
  $basejump_stl_dir/bsg_misc/bsg_counter_up_down_variable.v
  $basejump_stl_dir/bsg_misc/bsg_crossbar_o_by_i.v
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
  $basejump_stl_dir/bsg_misc/bsg_muxi2_gatestack.v
  $basejump_stl_dir/bsg_misc/bsg_mux_one_hot.v
  $basejump_stl_dir/bsg_misc/bsg_mux_segmented.v
  $basejump_stl_dir/bsg_misc/bsg_mux.v
  $basejump_stl_dir/bsg_misc/bsg_nand.v
  $basejump_stl_dir/bsg_misc/bsg_nor2.v
  $basejump_stl_dir/bsg_misc/bsg_nor3.v
  $basejump_stl_dir/bsg_misc/bsg_priority_encode_one_hot_out.v
  $basejump_stl_dir/bsg_misc/bsg_priority_encode.v
  $basejump_stl_dir/bsg_misc/bsg_reduce.v
  $basejump_stl_dir/bsg_misc/bsg_round_robin_arb.v
  $basejump_stl_dir/bsg_misc/bsg_scan.v
  $basejump_stl_dir/bsg_misc/bsg_strobe.v
  $basejump_stl_dir/bsg_misc/bsg_thermometer_count.v
  $basejump_stl_dir/bsg_misc/bsg_transpose.v
  $basejump_stl_dir/bsg_misc/bsg_xnor.v
  $basejump_stl_dir/bsg_misc/bsg_unconcentrate_static.v
  $basejump_stl_dir/bsg_misc/bsg_concentrate_static.v
  $basejump_stl_dir/bsg_misc/bsg_array_concentrate_static.v

  $basejump_stl_dir/bsg_cache/bsg_cache_decode.v
  $basejump_stl_dir/bsg_dataflow/bsg_fifo_1r1w_small_unhardened.v
  $basejump_stl_dir/bsg_misc/bsg_inv.v
  $basejump_stl_dir/bsg_misc/bsg_dff_chain.v
  $basejump_stl_dir/bsg_misc/bsg_lru_pseudo_tree_encode.v
  $basejump_stl_dir/bsg_misc/bsg_lru_pseudo_tree_decode.v
  $basejump_stl_dir/bsg_misc/bsg_expand_bitmask.v
  $basejump_stl_dir/bsg_misc/bsg_arb_round_robin.v

  $basejump_stl_dir/bsg_noc/bsg_mesh_stitch.v
  $basejump_stl_dir/bsg_noc/bsg_wormhole_router.v
  $basejump_stl_dir/bsg_noc/bsg_wormhole_router_decoder_dor.v
  $basejump_stl_dir/bsg_noc/bsg_wormhole_router_input_control.v
  $basejump_stl_dir/bsg_noc/bsg_wormhole_router_output_control.v
  $basejump_stl_dir/bsg_noc/bsg_mesh_router_buffered.v
  $basejump_stl_dir/bsg_noc/bsg_mesh_router.v
  $basejump_stl_dir/bsg_noc/bsg_mesh_router_decoder_dor.v
  $basejump_stl_dir/bsg_noc/bsg_wormhole_concentrator.v
  $basejump_stl_dir/bsg_noc/bsg_wormhole_concentrator_in.v
  $basejump_stl_dir/bsg_noc/bsg_wormhole_concentrator_out.v
  $basejump_stl_dir/bsg_noc/bsg_noc_repeater_node.v
  $basejump_stl_dir/bsg_tag/bsg_tag_client_unsync.v
  $basejump_stl_dir/bsg_tag/bsg_tag_client.v
  $basejump_stl_dir/bsg_tag/bsg_tag_master.v
  
  $basejump_stl_dir/bsg_dataflow/bsg_fifo_1r1w_small_hardened.v
  $basejump_stl_dir/bsg_mem/bsg_mem_1r1w_sync.v
  $basejump_stl_dir/bsg_mem/bsg_mem_1r1w_sync_synth.v
  $basejump_stl_dir/bsg_misc/bsg_xor.v
  $basejump_stl_dir/bsg_misc/bsg_lru_pseudo_tree_backup.v
  $basejump_stl_dir/bsg_misc/bsg_mux_bitwise.v
  $basejump_stl_dir/bsg_misc/bsg_dff_reset_en_bypass.v
  $basejump_stl_dir/bsg_misc/bsg_tiehi.v
  $basejump_stl_dir/bsg_misc/bsg_tielo.v
  $basejump_stl_dir/bsg_misc/bsg_dff_async_reset.v
  $basejump_stl_dir/bsg_tag/bsg_tag_master_decentralized.v
  $basejump_stl_dir/bsg_link/bsg_link_sdr.v
  $basejump_stl_dir/bsg_link/bsg_link_sdr_downstream.v
  $basejump_stl_dir/bsg_link/bsg_link_sdr_upstream.v
  $basejump_stl_dir/bsg_link/bsg_link_isdr_phy.v
  $basejump_stl_dir/bsg_link/bsg_link_osdr_phy.v
  $basejump_stl_dir/bsg_link/bsg_link_osdr_phy_phase_align.v
  $basejump_stl_dir/bsg_link/bsg_link_source_sync_upstream_sync.v

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

  $bsg_manycore_dir/v/bsg_manycore_pod_ruche_row.v
  $bsg_manycore_dir/v/bsg_manycore_hor_io_router.v
  $bsg_manycore_dir/v/bsg_manycore_dram_hash_function.v

  $bsg_manycore_dir/imports/HardFloat/source/compareRecFN.v
  $bsg_manycore_dir/imports/HardFloat/source/divSqrtRecFN_small.v
  $bsg_manycore_dir/imports/HardFloat/source/fNToRecFN.v
  $bsg_manycore_dir/imports/HardFloat/source/HardFloat_primitives.v
  $bsg_manycore_dir/imports/HardFloat/source/HardFloat_rawFN.v
  $bsg_manycore_dir/imports/HardFloat/source/iNToRecFN.v
  $bsg_manycore_dir/imports/HardFloat/source/isSigNaNRecFN.v
  $bsg_manycore_dir/imports/HardFloat/source/mulAddRecFN.v
  $bsg_manycore_dir/imports/HardFloat/source/recFNToFN.v
  $bsg_manycore_dir/imports/HardFloat/source/recFNToIN.v
  $bsg_manycore_dir/imports/HardFloat/source/RISCV/HardFloat_specialize.v

  $bsg_manycore_dir/v/vanilla_bean/bsg_manycore_proc_vanilla.v
  $bsg_manycore_dir/v/vanilla_bean/network_rx.v
  $bsg_manycore_dir/v/vanilla_bean/network_tx.v
  $bsg_manycore_dir/v/vanilla_bean/vanilla_core.v
  $bsg_manycore_dir/v/vanilla_bean/load_packer.v
  $bsg_manycore_dir/v/vanilla_bean/icache.v
  $bsg_manycore_dir/v/vanilla_bean/cl_decode.v
  $bsg_manycore_dir/v/vanilla_bean/regfile.v
  $bsg_manycore_dir/v/vanilla_bean/regfile_synth.v
  $bsg_manycore_dir/v/vanilla_bean/scoreboard.v
  $bsg_manycore_dir/v/vanilla_bean/alu.v
  $bsg_manycore_dir/v/vanilla_bean/idiv.v
  $bsg_manycore_dir/v/vanilla_bean/lsu.v
  $bsg_manycore_dir/v/vanilla_bean/fcsr.v
  $bsg_manycore_dir/v/vanilla_bean/mcsr.v
  $bsg_manycore_dir/v/vanilla_bean/fpu_int.v
  $bsg_manycore_dir/v/vanilla_bean/fpu_float.v
  $bsg_manycore_dir/v/vanilla_bean/fpu_float_aux.v
  $bsg_manycore_dir/v/vanilla_bean/fpu_int_fclass.v
  $bsg_manycore_dir/v/vanilla_bean/fpu_fmin_fmax.v
  $bsg_manycore_dir/v/vanilla_bean/fpu_fdiv_fsqrt.v
  $bsg_manycore_dir/v/vanilla_bean/fpu_float_fma.v
  $bsg_manycore_dir/v/vanilla_bean/fpu_float_fma_round.v

  $bsg_designs_target_dir/v/bsg_chip.v

  $bsg_designs_target_dir/../bigblade_io_link_ddr/v/bsg_chip_io_link_ddr.v

  $bsg_designs_target_dir/../bigblade_toplevel_block/v/bsg_chip_block.v
  $bsg_designs_target_dir/../bigblade_toplevel_block/v/bsg_chip_block_core_complex.v

  $bsg_designs_target_dir/../bigblade_noc_mem_link/v/bsg_ready_and_link_round_robin_static.v
  $bsg_designs_target_dir/../bigblade_noc_mem_link/v/bsg_chip_noc_mem_link.v

  $bsg_designs_target_dir/../bigblade_noc_io_link/v/bsg_then_ready_link_round_robin_static.v
  $bsg_designs_target_dir/../bigblade_noc_io_link/v/bsg_wide_link_to_then_ready_link.v
  $bsg_designs_target_dir/../bigblade_noc_io_link/v/bsg_chip_noc_io_link.v

  $bsg_designs_target_dir/../bigblade_pod_row/v/bsg_manycore_pod_row_sdr.v

  $bsg_designs_target_dir/../bigblade_clk_gen/v/bigblade_clk_gen.v

  $bsg_designs_target_dir/../common/v/bsg_chip_clk_gen.v
  $bsg_designs_target_dir/../common/v/bsg_clk_gen_osc.v
  $bsg_designs_target_dir/../common/v/bsg_manycore_link_resp_credit_to_ready_and_handshake.v
  $bsg_designs_target_dir/../common/v/bsg_link_delay_line.v
  $bsg_designs_target_dir/../bsg_manycore_link_to_sdr_north_row/v/bsg_manycore_link_to_sdr_north_row.v
  $bsg_designs_target_dir/../bsg_manycore_link_to_sdr_south_row/v/bsg_manycore_link_to_sdr_south_row.v
  $bsg_designs_target_dir/../common/sdr/sdr_horizontal/v/bsg_manycore_link_ruche_to_sdr_west.v
  $bsg_designs_target_dir/../common/sdr/sdr_horizontal/v/bsg_manycore_link_ruche_to_sdr_east.v
  $bsg_designs_target_dir/../common/sdr/sdr_vertical/v/bsg_manycore_link_to_sdr_north.v
  $bsg_designs_target_dir/../common/sdr/sdr_vertical/v/bsg_manycore_link_to_sdr_south.v
  $bsg_designs_target_dir/../common/sdr/sdr_corner/v/bsg_manycore_link_wh_to_sdr_ne.v
  $bsg_designs_target_dir/../common/sdr/sdr_corner/v/bsg_manycore_link_wh_to_sdr_nw.v
  $bsg_designs_target_dir/../common/sdr/sdr_corner/v/bsg_manycore_link_wh_to_sdr_sw.v
  $bsg_designs_target_dir/../common/sdr/sdr_corner/v/bsg_manycore_link_wh_to_sdr_se.v

"]

set SVERILOG_INCLUDE_PATHS [join "
  $bsg_packaging_dir/common/verilog
  $bsg_packaging_dir/common/foundry/portable/verilog
  $bsg_packaging_dir/$bsg_package/pinouts/$bsg_pinout/common/verilog
  $bsg_packaging_dir/$bsg_package/pinouts/$bsg_pinout/portable/verilog
  $bsg_packaging_dir/$bsg_package/pinouts/$bsg_pinout/portable/verilog/padmappings/$bsg_padmapping
  $basejump_stl_dir/bsg_misc
  $basejump_stl_dir/bsg_cache
  $basejump_stl_dir/bsg_clk_gen
  $basejump_stl_dir/bsg_noc
  $basejump_stl_dir/bsg_tag
  $bsg_manycore_dir/imports/HardFloat/source
  $bsg_manycore_dir/imports/HardFloat/source/RISCV

  $bsg_designs_target_dir/../common/v
  $bsg_designs_target_dir/../common/sdr/sdr_horizontal/v
  $bsg_designs_target_dir/../common/sdr/sdr_vertical/v
  $bsg_designs_target_dir/../common/sdr/sdr_corner/v
"]

