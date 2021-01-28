
source $::env(BSG_CHIP_DIR)/cad/setup/default_setup.tcl
source $::env(BSG_CHIP_DIR)/cad/flow/dc/bsg_dc_scripts/target_design.filelist.tcl
source ../tcl/bsg_config_util.tcl



# SCRIPT STARTS HERE
foreach lib [array name VERILOG_FILES] {
  if { $VERILOG_FILES($lib) != "" } {
    set all_final_source_files [concat $all_final_source_files [join $VERILOG_FILES($lib)]]
  }
}

bsg_create_filelist $::env(BSG_CHIP_FILELIST) \
                    $all_final_source_files

bsg_create_library  $::env(BSG_CHIP_LIBRARY_NAME) \
                    $::env(BSG_CHIP_LIBRARY) \
                    $all_final_source_files \
                    $final_sverilog_include_paths



# testing source (rtl) files and include paths list
source $::env(BSG_DESIGNS_TARGET_DIR)/testing/tcl/filelist.tcl
source $::env(BSG_DESIGNS_TARGET_DIR)/testing/tcl/include.tcl

# testing filelist
bsg_create_filelist $::env(BSG_DESIGNS_TESTING_FILELIST) \
                   [bsg_list_diff $TESTING_SOURCE_FILES $SVERILOG_SOURCE_FILES] \

# testing library
bsg_create_library $::env(BSG_DESIGNS_TESTING_LIBRARY_NAME) \
                   $::env(BSG_DESIGNS_TESTING_LIBRARY)      \
                   [bsg_list_diff $TESTING_SOURCE_FILES $SVERILOG_SOURCE_FILES] \
                   $TESTING_INCLUDE_PATHS
