source ../tcl/bsg_config_util.tcl

# scripts for creating filelist and library
#source $::env(BSG_TESTING_COMMON_DIR)/bsg_vcs_create_filelist_library.tcl

# chip source (rtl) files and include paths list
source $::env(BSG_DESIGNS_TARGET_DIR)/testing/tcl/chip_filelist.tcl
source $::env(BSG_DESIGNS_TARGET_DIR)/testing/tcl/chip_include.tcl

# testing source (rtl) files and include paths list
source $::env(BSG_DESIGNS_TARGET_DIR)/testing/tcl/gateway_filelist.tcl
source $::env(BSG_DESIGNS_TARGET_DIR)/testing/tcl/gateway_include.tcl

# pdk source files
source $::env(HB_BIGBLADE_NETLISTS_DIR)/pdk_stdlib_filelist.tcl
set SVERILOG_SOURCE_FILES [concat $SVERILOG_SOURCE_FILES $PDK_SOURCE_FILES]

##################################
# bsg_manycore_tile source files #
##################################
# comment this out to use post_synth netlist
# WARNING: THIS IS REALLY SLOW
#source $::env(HB_BIGBLADE_NETLISTS_DIR)/bsg_manycore_tile-post-synth_filelist.tcl
# comment this out to use rtl
source $::env(BSG_DESIGNS_TARGET_DIR)/testing/tcl/bsg_manycore_tile-rtl_filelist.tcl

set SVERILOG_SOURCE_FILES [concat $SVERILOG_SOURCE_FILES $BSG_MANYCORE_TILE_SOURCE_FILES]

######################################
# bsg_manycore_link_sdr source files #
######################################
# comment this out to use post_synth netlist
source $::env(HB_BIGBLADE_NETLISTS_DIR)/bsg_manycore_link_sdr-post-synth_filelist.tcl
# comment this out to use rtl
#source $::env(BSG_DESIGNS_TARGET_DIR)/testing/tcl/bsg_manycore_link_sdr-rtl_filelist.tcl

set SVERILOG_SOURCE_FILES [concat $SVERILOG_SOURCE_FILES $BSG_MANYCORE_LINK_SDR_SOURCE_FILES]


#####################################
# bigblade_io_link_ddr source files #
#####################################
# comment this out to use post_synth netlist
source $::env(HB_BIGBLADE_NETLISTS_DIR)/bigblade_io_link_ddr-post-synth_filelist.tcl
# comment this out to use rtl
#source $::env(BSG_DESIGNS_TARGET_DIR)/testing/tcl/bigblade_io_link_ddr-rtl_filelist.tcl

set SVERILOG_SOURCE_FILES [concat $SVERILOG_SOURCE_FILES $BIGBLADE_IO_LINK_DDR_SOURCE_FILES]

#####################################
# bigblade_noc_io_link source files #
#####################################
# comment this out to use post_synth netlist
source $::env(HB_BIGBLADE_NETLISTS_DIR)/bigblade_noc_io_link-post-synth_filelist.tcl
# comment this out to use rtl
#source $::env(BSG_DESIGNS_TARGET_DIR)/testing/tcl/bigblade_noc_io_link-rtl_filelist.tcl

set SVERILOG_SOURCE_FILES [concat $SVERILOG_SOURCE_FILES $BIGBLADE_NOC_IO_LINK_SOURCE_FILES]


######################################
# bigblade_noc_mem_link source files #
######################################
# comment this out to use post_synth netlist
source $::env(HB_BIGBLADE_NETLISTS_DIR)/bigblade_noc_mem_link-post-synth_filelist.tcl
# comment this out to use rtl
#source $::env(BSG_DESIGNS_TARGET_DIR)/testing/tcl/bigblade_noc_mem_link-rtl_filelist.tcl

set SVERILOG_SOURCE_FILES [concat $SVERILOG_SOURCE_FILES $BIGBLADE_NOC_MEM_LINK_SOURCE_FILES]

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
