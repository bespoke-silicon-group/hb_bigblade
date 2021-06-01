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

set basejump_stl_dir "$bsg_out_dir/bsg_manycore_link_sdr/$bsg_designs_target/basejump_stl"
set common_dir       "$bsg_out_dir/bsg_manycore_link_sdr/$bsg_designs_target/../common"

# Historically BSG_MANYCORE_LINK_SDR_SOURCE_FILES were all specified in
# one file. This has changed, and they are now per-module, as
# below. However, for backward compatibility we've reused the
# variable.

# Old Way:
# source $::env(HB_BIGBLADE_NETLISTS_DIR)/bsg_manycore_link_sdr-post-synth_filelist.tcl

# New Way: For now, include each of the sub-modules.
set BSG_MANYCORE_LINK_SDR_SOURCE_FILES []
source $::env(HB_BIGBLADE_NETLISTS_DIR)/bsg_manycore_link_ruche_to_sdr_east-post-synth_filelist.tcl
set BSG_MANYCORE_LINK_SDR_SOURCE_FILES [concat $BSG_MANYCORE_LINK_SDR_SOURCE_FILES $BSG_MANYCORE_LINK_RUCHE_TO_SDR_EAST_SOURCE_FILES]

source $::env(HB_BIGBLADE_NETLISTS_DIR)/bsg_manycore_link_ruche_to_sdr_west-post-synth_filelist.tcl
set BSG_MANYCORE_LINK_SDR_SOURCE_FILES [concat $BSG_MANYCORE_LINK_SDR_SOURCE_FILES $BSG_MANYCORE_LINK_RUCHE_TO_SDR_WEST_SOURCE_FILES]

source $::env(HB_BIGBLADE_NETLISTS_DIR)/bsg_manycore_link_to_sdr_north-post-synth_filelist.tcl
set BSG_MANYCORE_LINK_SDR_SOURCE_FILES [concat $BSG_MANYCORE_LINK_SDR_SOURCE_FILES $BSG_MANYCORE_LINK_TO_SDR_NORTH_SOURCE_FILES]

source $::env(HB_BIGBLADE_NETLISTS_DIR)/bsg_manycore_link_to_sdr_north_row-post-synth_filelist.tcl
set BSG_MANYCORE_LINK_SDR_SOURCE_FILES [concat $BSG_MANYCORE_LINK_SDR_SOURCE_FILES $BSG_MANYCORE_LINK_TO_SDR_NORTH_ROW_SOURCE_FILES]

source $::env(HB_BIGBLADE_NETLISTS_DIR)/bsg_manycore_link_to_sdr_south-post-synth_filelist.tcl
set BSG_MANYCORE_LINK_SDR_SOURCE_FILES [concat $BSG_MANYCORE_LINK_SDR_SOURCE_FILES $BSG_MANYCORE_LINK_TO_SDR_SOUTH_SOURCE_FILES]

source $::env(HB_BIGBLADE_NETLISTS_DIR)/bsg_manycore_link_to_sdr_south_row-post-synth_filelist.tcl
set BSG_MANYCORE_LINK_SDR_SOURCE_FILES [concat $BSG_MANYCORE_LINK_SDR_SOURCE_FILES $BSG_MANYCORE_LINK_TO_SDR_SOUTH_ROW_SOURCE_FILES]

source $::env(HB_BIGBLADE_NETLISTS_DIR)/bsg_manycore_link_wh_to_sdr_ne-post-synth_filelist.tcl
set BSG_MANYCORE_LINK_SDR_SOURCE_FILES [concat $BSG_MANYCORE_LINK_SDR_SOURCE_FILES $BSG_MANYCORE_LINK_WH_TO_SDR_NE_SOURCE_FILES]

source $::env(HB_BIGBLADE_NETLISTS_DIR)/bsg_manycore_link_wh_to_sdr_nw-post-synth_filelist.tcl
set BSG_MANYCORE_LINK_SDR_SOURCE_FILES [concat $BSG_MANYCORE_LINK_SDR_SOURCE_FILES $BSG_MANYCORE_LINK_WH_TO_SDR_NW_SOURCE_FILES]

source $::env(HB_BIGBLADE_NETLISTS_DIR)/bsg_manycore_link_wh_to_sdr_se-post-synth_filelist.tcl
set BSG_MANYCORE_LINK_SDR_SOURCE_FILES [concat $BSG_MANYCORE_LINK_SDR_SOURCE_FILES $BSG_MANYCORE_LINK_WH_TO_SDR_SE_SOURCE_FILES]

source $::env(HB_BIGBLADE_NETLISTS_DIR)/bsg_manycore_link_wh_to_sdr_sw-post-synth_filelist.tcl
set BSG_MANYCORE_LINK_SDR_SOURCE_FILES [concat $BSG_MANYCORE_LINK_SDR_SOURCE_FILES $BSG_MANYCORE_LINK_WH_TO_SDR_SW_SOURCE_FILES]

source $::env(HB_BIGBLADE_NETLISTS_DIR)/bsg_manycore_pod_row_sdr-post-synth_filelist.tcl
set BSG_MANYCORE_LINK_SDR_SOURCE_FILES [concat $BSG_MANYCORE_LINK_SDR_SOURCE_FILES $BIGBLADE_POD_ROW_SOURCE_FILES]
