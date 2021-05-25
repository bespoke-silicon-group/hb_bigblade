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

set basejump_stl_dir "$bsg_out_dir/bigblade_noc_io_link/$bsg_designs_target/basejump_stl"
set common_dir       "$bsg_out_dir/bigblade_noc_io_link/$bsg_designs_target/../common"

set BIGBLADE_NOC_IO_LINK_SOURCE_FILES [join "
    $bsg_designs_target_dir/../bigblade_noc_io_link/v/hard/gf_14/bsg_mem/bsg_mem_1r1w_sync.v
    $common_dir/v/hard/gf_14/bsg_link_delay_line.v
    $basejump_stl_dir/hard/gf_14/bsg_misc/bsg_mux.v
    $basejump_stl_dir/hard/gf_14/bsg_link/bsg_link_osdr_phy.v
    $basejump_stl_dir/hard/gf_14/bsg_link/bsg_link_isdr_phy.v
    $basejump_stl_dir/hard/gf_14/bsg_async/bsg_sync_sync.v
    $basejump_stl_dir/hard/gf_14/bsg_async/bsg_launch_sync_sync.v
"]
