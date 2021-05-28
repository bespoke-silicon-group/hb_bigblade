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

set basejump_stl_dir "$bsg_out_dir/bigblade_noc_mem_link/$bsg_designs_target/basejump_stl"
set common_dir       "$bsg_out_dir/bigblade_noc_mem_link/$bsg_designs_target/../common"

source $::env(HB_BIGBLADE_NETLISTS_DIR)/bigblade_noc_mem_link-post-apr_filelist.tcl
