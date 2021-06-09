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

set bsg_out_dir       $::env(TESTING_BSG_OUT_DIR)

set BIGBLADE_BP_UNICORE_SOURCE_FILES [join "
    $bsg_designs_target_dir/../bigblade_bp_unicore/v/hard/gf_14/bsg_mem/bsg_mem_1rw_sync.v
    $bsg_designs_target_dir/../bigblade_bp_unicore/v/hard/gf_14/bsg_mem/bsg_mem_1rw_sync_mask_write_bit.v
    $bsg_designs_target_dir/../bigblade_bp_unicore/v/hard/gf_14/bsg_mem/bsg_mem_1rw_sync_mask_write_byte.v
    $bsg_designs_target_dir/../bigblade_bp_unicore/v/hard/gf_14/bsg_mem/bsg_mem_1r1w_sync.v
    $bsg_designs_target_dir/../bigblade_bp_unicore/v/hard/gf_14/bsg_mem/bsg_mem_2r1w_sync.v
    $bsg_designs_target_dir/../bigblade_bp_unicore/v/hard/gf_14/bsg_mem/bsg_mem_3r1w_sync.v
"]
