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


  $hb_bigblade_netlists_dir/rc-0-1/post-apr/bigblade_toplevel_rc0/bsg_chip_chip_finish.v
  $hb_bigblade_netlists_dir/rc-0-1/post-apr/bigblade_toplevel_block_rc0/bsg_chip_block_chip_finish.v
  $hb_bigblade_netlists_dir/rc-0-1/post-apr/bigblade_bp_unicore/bsg_blackparrot_halfpod_chip_finish.v

  $hb_bigblade_netlists_dir/rc-0-0/post-apr/bigblade_brg_cgra_xcel/brg_cgra_pod_chip_finish.v
  $hb_bigblade_netlists_dir/rc-0-0/post-apr/bigblade_brg_cgra_xcel/ProcElement_chip_finish.v
  $hb_bigblade_netlists_dir/rc-0-0/post-apr/bigblade_io_link_ddr/bsg_chip_io_link_ddr_chip_finish.v
  $hb_bigblade_netlists_dir/rc-0-0/post-apr/bigblade_noc_io_link/bsg_chip_noc_io_link_chip_finish.v
  $hb_bigblade_netlists_dir/rc-0-0/post-apr/bigblade_noc_mem_link/bsg_chip_noc_mem_link_chip_finish.v

  $hb_bigblade_netlists_dir/rc-alpha-rtlfreeze-2/post-apr/bigblade_clk_gen/bigblade_clk_gen_chip_finish.v

  $hb_bigblade_netlists_dir/rc-1-1/post-apr/bigblade_manycore_tile_array_16x2/bsg_manycore_tile_compute_array_ruche_chip_finish.v
  $hb_bigblade_netlists_dir/rc-1-1/post-apr/bigblade_manycore_tile/bsg_manycore_tile_compute_ruche_chip_finish.v
  $hb_bigblade_netlists_dir/rc-1-1/post-apr/bigblade_vcache_array_16x1/bsg_manycore_tile_vcache_array_chip_finish.v
  $hb_bigblade_netlists_dir/rc-1-1/post-apr/bigblade_vcache/bsg_manycore_tile_vcache_chip_finish.v

  $hb_bigblade_netlists_dir/rc-1-1/post-apr/bsg_manycore_link_ruche_to_sdr_east/bsg_manycore_link_ruche_to_sdr_east_chip_finish.v
  $hb_bigblade_netlists_dir/rc-1-1/post-apr/bsg_manycore_link_ruche_to_sdr_west/bsg_manycore_link_ruche_to_sdr_west_chip_finish.v
  $hb_bigblade_netlists_dir/rc-1-1/post-apr/bsg_manycore_link_to_sdr_north/bsg_manycore_link_to_sdr_north_chip_finish.v
  $hb_bigblade_netlists_dir/rc-1-1/post-apr/bsg_manycore_link_to_sdr_south/bsg_manycore_link_to_sdr_south_chip_finish.v
  $hb_bigblade_netlists_dir/rc-1-1/post-apr/bsg_manycore_link_to_sdr_north_row/bsg_manycore_link_to_sdr_north_row_chip_finish.v
  $hb_bigblade_netlists_dir/rc-1-1/post-apr/bsg_manycore_link_to_sdr_south_row/bsg_manycore_link_to_sdr_south_row_chip_finish.v
  $hb_bigblade_netlists_dir/rc-1-1/post-apr/bsg_manycore_link_wh_to_sdr_ne/bsg_manycore_link_wh_to_sdr_ne_chip_finish.v
  $hb_bigblade_netlists_dir/rc-1-1/post-apr/bsg_manycore_link_wh_to_sdr_nw/bsg_manycore_link_wh_to_sdr_nw_chip_finish.v
  $hb_bigblade_netlists_dir/rc-1-1/post-apr/bsg_manycore_link_wh_to_sdr_se/bsg_manycore_link_wh_to_sdr_se_chip_finish.v
  $hb_bigblade_netlists_dir/rc-1-1/post-apr/bsg_manycore_link_wh_to_sdr_sw/bsg_manycore_link_wh_to_sdr_sw_chip_finish.v
  $hb_bigblade_netlists_dir/rc-1-1/post-apr/bigblade_pod_row/bsg_manycore_pod_row_sdr_chip_finish.v


"]



#  $bsg_designs_dir/bigblade_toplevel/v/hard/gf_14/bsg_mem_2rw_sync.v
#  $bsg_designs_dir/bigblade_toplevel/v/hard/gf_14/bsg_mem_3rw_sync.v
