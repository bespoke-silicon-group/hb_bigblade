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
source $::env(BSG_DESIGNS_TARGET_DIR)/testing/tcl/bigblade_manycore_tile_filelist.tcl
source $::env(BSG_DESIGNS_TARGET_DIR)/testing/tcl/bigblade_manycore_tile_include.tcl

# pdk source files
source $::env(HB_BIGBLADE_NETLISTS_DIR)/pdk_stdlib_filelist.tcl
set SVERILOG_SOURCE_FILES [concat $SVERILOG_SOURCE_FILES $PDK_SOURCE_FILES]

#########################
# list of hardened rams #
#########################
source $::env(HB_BIGBLADE_NETLISTS_DIR)/hardened_rams_filelist.tcl

set SVERILOG_SOURCE_FILES [concat $SVERILOG_SOURCE_FILES $HARDENED_RAM_FILES]

# swap in hardend modules
source $::env(BSG_CHIP_DIR)/cad/flow/dc/bsg_dc_scripts/target_design.filelist.tcl

set SVERILOG_SOURCE_FILES $final_sverilog_source_files
set SVERILOG_SOURCE_FILES [concat $SVERILOG_SOURCE_FILES $PDK_SOURCE_FILES]
set SVERILOG_SOURCE_FILES [concat $SVERILOG_SOURCE_FILES $HARDENED_RAM_FILES]
set SVERILOG_INCLUDE_PATHS $final_sverilog_include_paths

# chip filelist
bsg_create_filelist $::env(BSG_CHIP_FILELIST) \
                    $SVERILOG_SOURCE_FILES

# chip library
bsg_create_library $::env(BSG_CHIP_LIBRARY_NAME) \
                   $::env(BSG_CHIP_LIBRARY)      \
                   $SVERILOG_SOURCE_FILES        \
                   $SVERILOG_INCLUDE_PATHS

# tile filelist
bsg_create_filelist $::env(BIGBLADE_MANYCORE_TILE_FILELIST) \
                    $BIGBLADE_MANYCORE_TILE_SOURCE_FILES

# tile library
bsg_create_library $::env(BIGBLADE_MANYCORE_TILE_LIBRARY_NAME) \
    $::env(BIGBLADE_MANYCORE_TILE_LIBRARY) \
    $BIGBLADE_MANYCORE_TILE_SOURCE_FILES \
    $BIGBLADE_MANYCORE_TILE_INCLUDE_PATHS


# testing filelist
bsg_create_filelist $::env(BSG_DESIGNS_TESTING_FILELIST) \
                   [bsg_list_diff $TESTING_SOURCE_FILES $SVERILOG_SOURCE_FILES] \

# testing library
bsg_create_library $::env(BSG_DESIGNS_TESTING_LIBRARY_NAME) \
                   $::env(BSG_DESIGNS_TESTING_LIBRARY)      \
                   [bsg_list_diff $TESTING_SOURCE_FILES $SVERILOG_SOURCE_FILES] \
                   $TESTING_INCLUDE_PATHS
