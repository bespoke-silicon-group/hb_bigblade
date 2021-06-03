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

# redirect to point to symlinks
set bsg_designs_target $::env(BSG_DESIGNS_TARGET)
set bsg_out_dir $::env(TESTING_BSG_OUT_DIR)

set bsg_designs_target_dir "$bsg_out_dir/bigblade_io_link_ddr/$bsg_designs_target"
set basejump_stl_dir       "$bsg_designs_target_dir/basejump_stl"

set BIGBLADE_IO_LINK_DDR_SOURCE_FILES [join "
    $bsg_designs_target_dir/../bigblade_io_link_ddr/v/hard/gf_14/bsg_mem/bsg_mem_1r1w_sync.v
    $basejump_stl_dir/hard/gf_14/bsg_async/bsg_launch_sync_sync.v
    $basejump_stl_dir/hard/gf_14/bsg_async/bsg_sync_sync.v
    $basejump_stl_dir/hard/gf_14/bsg_clk_gen/bsg_clk_gen_osc.v
    $basejump_stl_dir/hard/gf_14/bsg_misc/bsg_mux.v

    $basejump_stl_dir/hard/gf_14/bsg_clk_gen/bsg_rp_clk_gen_atomic_delay_tuner.v
    $basejump_stl_dir/hard/gf_14/bsg_clk_gen/bsg_rp_clk_gen_coarse_delay_tuner.v
    $basejump_stl_dir/hard/gf_14/bsg_clk_gen/bsg_rp_clk_gen_fine_delay_tuner.v
"]
