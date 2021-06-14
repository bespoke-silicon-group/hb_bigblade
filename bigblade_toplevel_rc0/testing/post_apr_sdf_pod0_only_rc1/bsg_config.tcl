source ../tcl/bsg_config_util.tcl

# chip source (rtl) files and include paths list
source $::env(BSG_DESIGNS_TARGET_DIR)/testing/post_apr_sdf_pod0_only_rc1/chip_filelist.tcl
source $::env(BSG_DESIGNS_TARGET_DIR)/testing/post_apr_sdf_pod0_only_rc1/chip_include.tcl

# testing source (rtl) files and include paths list
source $::env(BSG_DESIGNS_TARGET_DIR)/testing/post_apr_sdf_pod0_only_rc1/gateway_filelist.tcl
source $::env(BSG_DESIGNS_TARGET_DIR)/testing/post_apr_sdf_pod0_only_rc1/gateway_include.tcl

# pdk source files
source $::env(HB_BIGBLADE_NETLISTS_DIR)/pdk_stdlib_filelist.tcl
set SVERILOG_SOURCE_FILES [concat $SVERILOG_SOURCE_FILES $PDK_SOURCE_FILES]

#########################
# list of hardened rams #
#########################
source $::env(HB_BIGBLADE_NETLISTS_DIR)/hardened_rams_filelist.tcl

set SVERILOG_SOURCE_FILES [concat $SVERILOG_SOURCE_FILES $HARDENED_RAMS_SOURCE_FILES]

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
                   [bsg_list_diff $TESTING_SOURCE_FILES $SVERILOG_SOURCE_FILES]

# testing library
bsg_create_library $::env(BSG_DESIGNS_TESTING_LIBRARY_NAME) \
                   $::env(BSG_DESIGNS_TESTING_LIBRARY)      \
                   [bsg_list_diff $TESTING_SOURCE_FILES $SVERILOG_SOURCE_FILES] \
                   $TESTING_INCLUDE_PATHS
