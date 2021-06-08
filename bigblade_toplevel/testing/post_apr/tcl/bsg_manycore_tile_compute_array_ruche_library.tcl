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

# Historically BSG_MANYCORE_TILE_SOURCE_FILES were all specified in
# one file. This has changed, and they are now per-module, as
# below. However, for backward compatibility we've reused the
# variable.

# Old Way:
# source $::env(HB_BIGBLADE_NETLISTS_DIR)/bsg_manycore_tile-post-apr_filelist.tcl

# New Way: For now, include each of the sub-modules.

# defines BIGBLADE_MANYCORE_TILE_ARRAY_16X2_SOURCE_FILES
source $::env(HB_BIGBLADE_NETLISTS_DIR)/bsg_manycore_tile_compute_array_ruche-post-apr_filelist.tcl

set BIGBLADE_MANYCORE_TILE_ARRAY_16X2_INCLUDE_PATHS [ join "
  $basejump_stl_dir/hard/gf_14/bsg_mem/
"]

bsg_create_filelist $::env(BSG_MANYCORE_TILE_COMPUTE_ARRAY_FILELIST) \
    $BIGBLADE_MANYCORE_TILE_ARRAY_16X2_SOURCE_FILES

bsg_create_library $::env(BSG_MANYCORE_TILE_COMPUTE_ARRAY_LIBRARY_NAME) \
    $::env(BSG_MANYCORE_TILE_COMPUTE_ARRAY_LIBRARY) \
    $BIGBLADE_MANYCORE_TILE_ARRAY_16X2_SOURCE_FILES \
    $BIGBLADE_MANYCORE_TILE_ARRAY_16X2_INCLUDE_PATHS
