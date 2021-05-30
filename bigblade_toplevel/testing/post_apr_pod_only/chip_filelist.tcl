#------------------------------------------------------------
# Do NOT arbitrarily change the order of files. Some module
# and macro definitions may be needed by the subsequent files
#------------------------------------------------------------

set basejump_stl_dir       $::env(BASEJUMP_STL_DIR)
set bsg_manycore_dir       $::env(BSG_MANYCORE_DIR)
set bsg_designs_dir        $::env(BSG_DESIGNS_DIR)
set bsg_designs_target_dir $::env(BSG_DESIGNS_TARGET_DIR)
set bsg_packaging_dir      $::env(BSG_PACKAGING_DIR)

set bsg_package       $::env(BSG_PACKAGE)
set bsg_pinout        $::env(BSG_PINOUT)
set bsg_padmapping    $::env(BSG_PADMAPPING)

set hb_bigblade_netlists_dir $::env(HB_BIGBLADE_NETLISTS_DIR)

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
  $bsg_designs_target_dir/../common/v/bsg_chip_pkg.v
"]

# Best Practice: Keep bsg_defines first, then all pacakges (denoted by ending
# in _pkg). The rest of the files should allowed in any order.
set SVERILOG_SOURCE_FILES [join "
  $SVERILOG_PACKAGE_FILES
  $bsg_designs_target_dir/v/bsg_chip.v
  $bsg_designs_target_dir/../bigblade_toplevel_block/v/bsg_chip_block.v
  $bsg_designs_target_dir/../bigblade_toplevel_block/v/bsg_chip_block_core_complex.v
  $bsg_designs_target_dir/../bigblade_noc_mem_link/v/bsg_ready_and_link_round_robin_static.v
  $bsg_designs_target_dir/../bigblade_noc_io_link/v/bsg_then_ready_link_round_robin_static.v
  $bsg_designs_target_dir/../bigblade_noc_io_link/v/bsg_wide_link_to_then_ready_link.v
  $bsg_designs_target_dir/../bigblade_clk_gen/v/bigblade_clk_gen_monitor.v
  $bsg_designs_target_dir/../bigblade_clk_gen/v/bigblade_clk_gen_monitor_clk_buf.v
  $bsg_designs_target_dir/../common/v/bsg_manycore_link_resp_credit_to_ready_and_handshake.v
  $bsg_designs_target_dir/../common/v/bsg_lfsr_div30.v

  $bsg_designs_dir/bigblade_toplevel/v/hard/gf_14/bsg_mem_1r1w_sync.v
  $bsg_designs_dir/bigblade_toplevel/v/hard/gf_14/bsg_mem_1rw_sync_mask_write_bit.v
  $bsg_designs_dir/bigblade_toplevel/v/hard/gf_14/bsg_mem_1rw_sync_mask_write_byte.v
  $bsg_designs_dir/bigblade_toplevel/v/hard/gf_14/bsg_mem_1rw_sync.v
  $basejump_stl_dir/hard/gf_14/bsg_misc/bsg_mux.v
  $basejump_stl_dir/hard/gf_14/bsg_async/bsg_sync_sync.v
  $basejump_stl_dir/hard/gf_14/bsg_async/bsg_launch_sync_sync.v

  $bsg_designs_target_dir/../common/v/bsg_chip_clk_gen.v
  $basejump_stl_dir/bsg_clk_gen/bsg_clk_gen.v
  $basejump_stl_dir/hard/gf_14/bsg_clk_gen/bsg_clk_gen_osc.v
  $basejump_stl_dir/hard/gf_14/bsg_clk_gen/bsg_rp_clk_gen_atomic_delay_tuner.v
  $basejump_stl_dir/hard/gf_14/bsg_clk_gen/bsg_rp_clk_gen_coarse_delay_tuner.v
  $basejump_stl_dir/hard/gf_14/bsg_clk_gen/bsg_rp_clk_gen_fine_delay_tuner.v

  $bsg_designs_dir/bigblade_noc_io_link/v/bsg_chip_noc_io_link.v
  $bsg_designs_dir/bigblade_noc_mem_link/v/bsg_chip_noc_mem_link.v
  $bsg_designs_dir/bigblade_io_link_ddr/v/bsg_chip_io_link_ddr.v
  $bsg_designs_dir/bigblade_clk_gen/v/bigblade_clk_gen.v


  $basejump_stl_dir/bsg_tag/bsg_tag_client.v
  $basejump_stl_dir/bsg_tag/bsg_tag_client_unsync.v
  $basejump_stl_dir/bsg_tag/bsg_tag_master_decentralized.v

  $basejump_stl_dir/bsg_misc/bsg_circular_ptr.v
  $basejump_stl_dir/bsg_misc/bsg_mux2_gatestack.v
  $basejump_stl_dir/bsg_misc/bsg_dff.v
  $basejump_stl_dir/bsg_misc/bsg_decode_with_v.v
  $basejump_stl_dir/bsg_misc/bsg_decode.v
  $basejump_stl_dir/bsg_misc/bsg_counter_clear_up.v
  $basejump_stl_dir/bsg_misc/bsg_counter_set_down.v
  $basejump_stl_dir/bsg_misc/bsg_gray_to_binary.v
  $basejump_stl_dir/bsg_misc/bsg_scan.v
  $basejump_stl_dir/bsg_misc/bsg_mux_one_hot.v
  $basejump_stl_dir/bsg_misc/bsg_dff_reset.v
  $basejump_stl_dir/bsg_misc/bsg_dff_reset_en.v
  $basejump_stl_dir/bsg_misc/bsg_dff_en.v
  $basejump_stl_dir/bsg_misc/bsg_round_robin_arb.v
  $basejump_stl_dir/bsg_misc/bsg_counter_clock_downsample.v
  $basejump_stl_dir/bsg_misc/bsg_strobe.v
  $basejump_stl_dir/bsg_misc/bsg_reduce.v
  $basejump_stl_dir/bsg_misc/bsg_buf.v
  $basejump_stl_dir/bsg_misc/bsg_xnor.v
  $basejump_stl_dir/bsg_misc/bsg_nand.v
  $basejump_stl_dir/bsg_misc/bsg_nor3.v
  $basejump_stl_dir/bsg_misc/bsg_muxi2_gatestack.v
  $basejump_stl_dir/bsg_misc/bsg_counter_up_down_variable.v
  $basejump_stl_dir/bsg_misc/bsg_crossbar_o_by_i.v

  $basejump_stl_dir/bsg_noc/bsg_wormhole_concentrator.v
  $basejump_stl_dir/bsg_noc/bsg_wormhole_concentrator_in.v
  $basejump_stl_dir/bsg_noc/bsg_wormhole_concentrator_out.v
  $basejump_stl_dir/bsg_noc/bsg_wormhole_router_output_control.v
  $basejump_stl_dir/bsg_noc/bsg_wormhole_router_input_control.v

  $basejump_stl_dir/bsg_mem/bsg_mem_1r1w.v
  $basejump_stl_dir/bsg_mem/bsg_mem_1r1w_synth.v

  $basejump_stl_dir/bsg_async/bsg_async_credit_counter.v
  $basejump_stl_dir/bsg_async/bsg_async_fifo.v
  $basejump_stl_dir/bsg_async/bsg_async_ptr_gray.v


  $basejump_stl_dir/bsg_dataflow/bsg_serial_in_parallel_out_full.v
  $basejump_stl_dir/bsg_dataflow/bsg_serial_in_parallel_out.v
  $basejump_stl_dir/bsg_dataflow/bsg_channel_tunnel.v
  $basejump_stl_dir/bsg_dataflow/bsg_channel_tunnel_in.v
  $basejump_stl_dir/bsg_dataflow/bsg_channel_tunnel_out.v
  $basejump_stl_dir/bsg_dataflow/bsg_round_robin_1_to_n.v
  $basejump_stl_dir/bsg_dataflow/bsg_round_robin_n_to_1.v
  $basejump_stl_dir/bsg_dataflow/bsg_parallel_in_serial_out.v
  $basejump_stl_dir/bsg_dataflow/bsg_1_to_n_tagged_fifo.v
  $basejump_stl_dir/bsg_dataflow/bsg_1_to_n_tagged.v
  $basejump_stl_dir/bsg_dataflow/bsg_two_fifo.v
  $basejump_stl_dir/bsg_dataflow/bsg_fifo_1r1w_small.v
  $basejump_stl_dir/bsg_dataflow/bsg_fifo_1r1w_small_hardened.v
  $basejump_stl_dir/bsg_dataflow/bsg_one_fifo.v
  $basejump_stl_dir/bsg_dataflow/bsg_fifo_tracker.v


  $basejump_stl_dir/bsg_link/bsg_link_ddr_downstream.v
  $basejump_stl_dir/bsg_link/bsg_link_ddr_upstream.v
  $basejump_stl_dir/bsg_link/bsg_link_iddr_phy.v
  $basejump_stl_dir/bsg_link/bsg_link_oddr_phy.v
  $basejump_stl_dir/bsg_link/bsg_link_source_sync_upstream.v

  $basejump_stl_dir/bsg_link/bsg_link_sdr.v
  $basejump_stl_dir/bsg_link/bsg_link_sdr_downstream.v
  $basejump_stl_dir/bsg_link/bsg_link_sdr_upstream.v
  $basejump_stl_dir/bsg_link/bsg_link_source_sync_downstream.v
  $basejump_stl_dir/bsg_link/bsg_link_source_sync_upstream_sync.v
  $basejump_stl_dir/hard/gf_14/bsg_link/bsg_link_osdr_phy.v
  $basejump_stl_dir/hard/gf_14/bsg_link/bsg_link_isdr_phy.v
  $bsg_designs_dir/common/v/hard/gf_14/bsg_link_delay_line.v

  $hb_bigblade_netlists_dir/rc-alpha-rtlfreeze-1/post-apr/bsg_manycore_tile/bsg_manycore_tile_compute_array_ruche_chip_finish.v
  $hb_bigblade_netlists_dir/rc-alpha-rtlfreeze-1/post-apr/bsg_manycore_tile/bsg_manycore_tile_compute_ruche_chip_finish.v
  $hb_bigblade_netlists_dir/rc-alpha-rtlfreeze-1/post-apr/bsg_manycore_tile/bsg_manycore_tile_vcache_array_chip_finish.v
  $hb_bigblade_netlists_dir/rc-alpha-rtlfreeze-1/post-apr/bsg_manycore_tile/bsg_manycore_tile_vcache_chip_finish.v

  $hb_bigblade_netlists_dir/rc-alpha-rtlfreeze-1/post-apr/bsg_manycore_link_sdr/bsg_manycore_link_ruche_to_sdr_east_chip_finish.v
  $hb_bigblade_netlists_dir/rc-alpha-rtlfreeze-1/post-apr/bsg_manycore_link_sdr/bsg_manycore_link_ruche_to_sdr_west_chip_finish.v
  $hb_bigblade_netlists_dir/rc-alpha-rtlfreeze-1/post-apr/bsg_manycore_link_sdr/bsg_manycore_link_to_sdr_north_chip_finish.v
  $hb_bigblade_netlists_dir/rc-alpha-rtlfreeze-1/post-apr/bsg_manycore_link_sdr/bsg_manycore_link_to_sdr_south_chip_finish.v
  $hb_bigblade_netlists_dir/rc-alpha-rtlfreeze-1/post-apr/bsg_manycore_link_sdr/bsg_manycore_link_to_sdr_north_row_chip_finish.v
  $hb_bigblade_netlists_dir/rc-alpha-rtlfreeze-1/post-apr/bsg_manycore_link_sdr/bsg_manycore_link_to_sdr_south_row_chip_finish.v
  $hb_bigblade_netlists_dir/rc-alpha-rtlfreeze-1/post-apr/bsg_manycore_link_sdr/bsg_manycore_link_wh_to_sdr_ne_chip_finish.v
  $hb_bigblade_netlists_dir/rc-alpha-rtlfreeze-1/post-apr/bsg_manycore_link_sdr/bsg_manycore_link_wh_to_sdr_nw_chip_finish.v
  $hb_bigblade_netlists_dir/rc-alpha-rtlfreeze-1/post-apr/bsg_manycore_link_sdr/bsg_manycore_link_wh_to_sdr_se_chip_finish.v
  $hb_bigblade_netlists_dir/rc-alpha-rtlfreeze-1/post-apr/bsg_manycore_link_sdr/bsg_manycore_link_wh_to_sdr_sw_chip_finish.v
  $hb_bigblade_netlists_dir/rc-alpha-rtlfreeze-1/post-apr/bsg_manycore_link_sdr/bsg_manycore_pod_row_sdr_chip_finish.v

"]



#  $bsg_designs_dir/bigblade_toplevel/v/hard/gf_14/bsg_mem_2rw_sync.v
#  $bsg_designs_dir/bigblade_toplevel/v/hard/gf_14/bsg_mem_3rw_sync.v
