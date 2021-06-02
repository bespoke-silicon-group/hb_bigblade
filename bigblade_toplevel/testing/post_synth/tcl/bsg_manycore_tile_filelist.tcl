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
# source $::env(HB_BIGBLADE_NETLISTS_DIR)/bsg_manycore_tile-post-synth_filelist.tcl

# New Way: For now, include each of the sub-modules.
set BSG_MANYCORE_TILE_SOURCE_FILES []
source $::env(HB_BIGBLADE_NETLISTS_DIR)/bsg_manycore_tile_compute_array_ruche-post-synth_filelist.tcl
set BSG_MANYCORE_TILE_SOURCE_FILES [concat $BSG_MANYCORE_TILE_SOURCE_FILES $BIGBLADE_MANYCORE_TILE_ARRAY_16X2_SOURCE_FILES]

source $::env(HB_BIGBLADE_NETLISTS_DIR)/bsg_manycore_tile_compute_ruche-post-synth_filelist.tcl
set BSG_MANYCORE_TILE_SOURCE_FILES [concat $BSG_MANYCORE_TILE_SOURCE_FILES $BIGBLADE_MANYCORE_TILE_SOURCE_FILES]

source $::env(HB_BIGBLADE_NETLISTS_DIR)/bsg_manycore_tile_vcache_array-post-synth_filelist.tcl
set BSG_MANYCORE_TILE_SOURCE_FILES [concat $BSG_MANYCORE_TILE_SOURCE_FILES $BIGBLADE_VCACHE_ARRAY_16X1_SOURCE_FILES]

source $::env(HB_BIGBLADE_NETLISTS_DIR)/bsg_manycore_tile_vcache-post-synth_filelist.tcl
set BSG_MANYCORE_TILE_SOURCE_FILES [concat $BSG_MANYCORE_TILE_SOURCE_FILES $BIGBLADE_VCACHE_SOURCE_FILES]
