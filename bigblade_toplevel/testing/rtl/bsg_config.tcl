
source ../tcl/bsg_config_util.tcl



# scripts for creating filelist and library
#source $::env(BSG_TESTING_COMMON_DIR)/bsg_vcs_create_filelist_library.tcl

# chip source (rtl) files and include paths list
source $::env(BSG_DESIGNS_TARGET_DIR)/testing/tcl/chip_filelist.tcl
source $::env(BSG_DESIGNS_TARGET_DIR)/testing/tcl/chip_include.tcl

# testing source (rtl) files and include paths list
source $::env(BSG_DESIGNS_TARGET_DIR)/testing/tcl/gateway_filelist.tcl
source $::env(BSG_DESIGNS_TARGET_DIR)/testing/tcl/gateway_include.tcl

# bsg_manycore_tile source files
source $::env(BSG_DESIGNS_TARGET_DIR)/testing/tcl/bsg_manycore_tile-rtl_filelist.tcl
set SVERILOG_SOURCE_FILES [concat $SVERILOG_SOURCE_FILES $BSG_MANYCORE_TILE_SOURCE_FILES]

# comment this out to use rtl
source $::env(BSG_DESIGNS_TARGET_DIR)/testing/tcl/bsg_manycore_link_sdr-rtl_filelist.tcl
set SVERILOG_SOURCE_FILES [concat $SVERILOG_SOURCE_FILES $BSG_MANYCORE_LINK_SDR_SOURCE_FILES]

# chip filelist
bsg_create_filelist $::env(BSG_CHIP_FILELIST) \
                    $SVERILOG_SOURCE_FILES

# chip library
bsg_create_library $::env(BSG_CHIP_LIBRARY_NAME) \
                   $::env(BSG_CHIP_LIBRARY)      \
                   $SVERILOG_SOURCE_FILES        \
                   $SVERILOG_INCLUDE_PATHS

# testing filelist
bsg_create_filelist $::env(BSG_DESIGNS_TESTING_FILELIST) \
                   [bsg_list_diff $TESTING_SOURCE_FILES $SVERILOG_SOURCE_FILES] \

# testing library
bsg_create_library $::env(BSG_DESIGNS_TESTING_LIBRARY_NAME) \
                   $::env(BSG_DESIGNS_TESTING_LIBRARY)      \
                   [bsg_list_diff $TESTING_SOURCE_FILES $SVERILOG_SOURCE_FILES] \
                   $TESTING_INCLUDE_PATHS
