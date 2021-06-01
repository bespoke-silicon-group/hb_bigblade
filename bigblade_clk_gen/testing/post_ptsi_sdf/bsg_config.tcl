
source $::env(BSG_CAD_SETUP_SCRIPT)
source $::env(BSG_DESIGNS_TARGET_DIR)/testing/tcl/bsg_config_utils.tcl

# chip netlist files list
set netlist_source_files [glob $::env(BSG_14_DIR)/current_build/pnr/*/results/*chip_finish.pt.v.gz]
foreach lib [array name VERILOG_FILES] {
  if { $VERILOG_FILES($lib) != "" } {
    set netlist_source_files [concat $netlist_source_files [join $VERILOG_FILES($lib)]]
  }
}

bsg_create_filelist $::env(BSG_CHIP_FILELIST) \
                    $netlist_source_files

bsg_create_library $::env(BSG_CHIP_LIBRARY_NAME) \
                   $::env(BSG_CHIP_LIBRARY)      \
                   $netlist_source_files         \
                   [list]

# testing source (rtl) files and include paths list
source $::env(BSG_DESIGNS_TARGET_DIR)/tcl/filelist.tcl
source $::env(BSG_DESIGNS_TARGET_DIR)/testing/tcl/filelist.tcl

bsg_create_filelist $::env(BSG_DESIGNS_TESTING_FILELIST) \
                   [concat $SVERILOG_SOURCE_FILES [bsg_list_diff $TESTING_SOURCE_FILES $SVERILOG_SOURCE_FILES]] \

bsg_create_library $::env(BSG_DESIGNS_TESTING_LIBRARY_NAME) \
                   $::env(BSG_DESIGNS_TESTING_LIBRARY)      \
                   [concat $SVERILOG_SOURCE_FILES [bsg_list_diff $TESTING_SOURCE_FILES $SVERILOG_SOURCE_FILES]] \
                   [concat $SVERILOG_INCLUDE_PATHS $TESTING_INCLUDE_PATHS]

