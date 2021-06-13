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
source $::env(BSG_DESIGNS_TARGET_DIR)/testing/rtl_hard/tcl/bsg_manycore_tile_filelist.tcl
source $::env(BSG_DESIGNS_TARGET_DIR)/testing/rtl_hard/tcl/bsg_manycore_tile_include.tcl

# clk_gen
source $::env(BSG_DESIGNS_TARGET_DIR)/testing/rtl_hard/tcl/bigblade_clk_gen_filelist.tcl
source $::env(BSG_DESIGNS_TARGET_DIR)/testing/rtl_hard/tcl/bigblade_clk_gen_include.tcl

# io link ddr
source $::env(BSG_DESIGNS_TARGET_DIR)/testing/rtl_hard/tcl/bigblade_io_link_ddr_filelist.tcl
source $::env(BSG_DESIGNS_TARGET_DIR)/testing/rtl_hard/tcl/bigblade_io_link_ddr_include.tcl

# noc io link
source $::env(BSG_DESIGNS_TARGET_DIR)/testing/rtl_hard/tcl/bigblade_noc_io_link_filelist.tcl
source $::env(BSG_DESIGNS_TARGET_DIR)/testing/rtl_hard/tcl/bigblade_noc_io_link_include.tcl

# noc mem link
source $::env(BSG_DESIGNS_TARGET_DIR)/testing/rtl_hard/tcl/bigblade_noc_mem_link_filelist.tcl
source $::env(BSG_DESIGNS_TARGET_DIR)/testing/rtl_hard/tcl/bigblade_noc_mem_link_include.tcl

# sdr link
source $::env(BSG_DESIGNS_TARGET_DIR)/testing/rtl_hard/tcl/bsg_manycore_link_sdr_filelist.tcl
source $::env(BSG_DESIGNS_TARGET_DIR)/testing/rtl_hard/tcl/bsg_manycore_link_sdr_include.tcl

# bsg tie hi/lo
source $::env(BSG_DESIGNS_TARGET_DIR)/testing/rtl_hard/tcl/bsg_tiehilo_filelist.tcl
source $::env(BSG_DESIGNS_TARGET_DIR)/testing/rtl_hard/tcl/bsg_tiehilo_include.tcl

# BlackParrot
source $::env(BSG_DESIGNS_TARGET_DIR)/testing/rtl_hard/tcl/bigblade_bp_unicore_filelist.tcl
source $::env(BSG_DESIGNS_TARGET_DIR)/testing/rtl_hard/tcl/bigblade_bp_unicore_include.tcl

# cgra
source $::env(BSG_DESIGNS_TARGET_DIR)/testing/post_apr/tcl/bigblade_brg_cgra_pod_filelist.tcl
source $::env(BSG_DESIGNS_TARGET_DIR)/testing/post_apr/tcl/bigblade_brg_cgra_pod_include.tcl

# bigblade_toplevel_block
source $::env(BSG_DESIGNS_TARGET_DIR)/testing/rtl_hard/tcl/bigblade_toplevel_block_filelist.tcl
source $::env(BSG_DESIGNS_TARGET_DIR)/testing/rtl_hard/tcl/bigblade_toplevel_block_include.tcl

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

# tile filelist
bsg_create_filelist $::env(BSG_MANYCORE_TILE_FILELIST) \
                    $BSG_MANYCORE_TILE_SOURCE_FILES

# tile library
bsg_create_library $::env(BSG_MANYCORE_TILE_LIBRARY_NAME) \
    $::env(BSG_MANYCORE_TILE_LIBRARY) \
    $BSG_MANYCORE_TILE_SOURCE_FILES \
    $BSG_MANYCORE_TILE_INCLUDE_PATHS

# clk_gen filelist
bsg_create_filelist $::env(BIGBLADE_CLK_GEN_FILELIST) \
    $BIGBLADE_CLK_GEN_SOURCE_FILES

# clk_gen library
bsg_create_library $::env(BIGBLADE_CLK_GEN_LIBRARY_NAME) \
    $::env(BIGBLADE_CLK_GEN_LIBRARY) \
    $BIGBLADE_CLK_GEN_SOURCE_FILES \
    $BIGBLADE_CLK_GEN_INCLUDE_PATHS

# io_link_ddr filelist
bsg_create_filelist $::env(BIGBLADE_IO_LINK_DDR_FILELIST) \
    $BIGBLADE_IO_LINK_DDR_SOURCE_FILES

# io_link_ddr library
bsg_create_library $::env(BIGBLADE_IO_LINK_DDR_LIBRARY_NAME)\
    $::env(BIGBLADE_IO_LINK_DDR_LIBRARY) \
    $BIGBLADE_IO_LINK_DDR_SOURCE_FILES \
    $BIGBLADE_IO_LINK_DDR_INCLUDE_PATHS


# noc_io_link filelist
bsg_create_filelist $::env(BIGBLADE_NOC_IO_LINK_FILELIST) \
    $BIGBLADE_NOC_IO_LINK_SOURCE_FILES

# noc_io_link library
bsg_create_library $::env(BIGBLADE_NOC_IO_LINK_LIBRARY_NAME)\
    $::env(BIGBLADE_NOC_IO_LINK_LIBRARY) \
    $BIGBLADE_NOC_IO_LINK_SOURCE_FILES \
    $BIGBLADE_NOC_IO_LINK_INCLUDE_PATHS


# noc_io_link filelist
bsg_create_filelist $::env(BIGBLADE_NOC_MEM_LINK_FILELIST) \
    $BIGBLADE_NOC_MEM_LINK_SOURCE_FILES

# noc_io_link library
bsg_create_library $::env(BIGBLADE_NOC_MEM_LINK_LIBRARY_NAME)\
    $::env(BIGBLADE_NOC_MEM_LINK_LIBRARY) \
    $BIGBLADE_NOC_MEM_LINK_SOURCE_FILES \
    $BIGBLADE_NOC_MEM_LINK_INCLUDE_PATHS


# sdr_link filelist
bsg_create_filelist $::env(BSG_MANYCORE_LINK_SDR_FILELIST) \
    $BSG_MANYCORE_LINK_SDR_SOURCE_FILES

# sdr_link library
bsg_create_library $::env(BSG_MANYCORE_LINK_SDR_LIBRARY_NAME)\
    $::env(BSG_MANYCORE_LINK_SDR_LIBRARY) \
    $BSG_MANYCORE_LINK_SDR_SOURCE_FILES \
    $BSG_MANYCORE_LINK_SDR_INCLUDE_PATHS


# tie hi/lo filelist
bsg_create_filelist $::env(BSG_TIEHILO_FILELIST) \
    $BSG_TIEHILO_SOURCE_FILES

# tie hi/lo library
bsg_create_library $::env(BSG_TIEHILO_LIBRARY_NAME)\
    $::env(BSG_TIEHILO_LIBRARY) \
    $BSG_TIEHILO_SOURCE_FILES \
    $BSG_TIEHILO_INCLUDE_PATHS

# blackparrot filelist
bsg_create_filelist $::env(BIGBLADE_BP_UNICORE_FILELIST) \
                    $BIGBLADE_BP_UNICORE_SOURCE_FILES

# blackparrot library
bsg_create_library $::env(BIGBLADE_BP_UNICORE_LIBRARY_NAME) \
    $::env(BIGBLADE_BP_UNICORE_LIBRARY) \
    $BIGBLADE_BP_UNICORE_SOURCE_FILES \
    $BIGBLADE_BP_UNICORE_INCLUDE_PATHS

# cgra filelist
bsg_create_filelist $::env(BIGBLADE_BRG_CGRA_POD_FILELIST) \
    $BIGBLADE_BRG_CGRA_XCEL_SOURCE_FILES

# cgra library
bsg_create_library $::env(BIGBLADE_BRG_CGRA_POD_LIBRARY_NAME)\
    $::env(BIGBLADE_BRG_CGRA_POD_LIBRARY) \
    $BIGBLADE_BRG_CGRA_XCEL_SOURCE_FILES \
    $BIGBLADE_BRG_CGRA_POD_INCLUDE_PATHS

# bigblade_toplevel_block filelist
bsg_create_filelist $::env(BIGBLADE_TOPLEVEL_BLOCK_FILELIST) \
    $BIGBLADE_TOPLEVEL_BLOCK_SOURCE_FILES

# bigblade_toplevel_block library
bsg_create_library $::env(BIGBLADE_TOPLEVEL_BLOCK_LIBRARY_NAME)\
    $::env(BIGBLADE_TOPLEVEL_BLOCK_LIBRARY) \
    $BIGBLADE_TOPLEVEL_BLOCK_SOURCE_FILES \
    $BIGBLADE_TOPLEVEL_BLOCK_INCLUDE_PATHS

# testing filelist
bsg_create_filelist $::env(BSG_DESIGNS_TESTING_FILELIST) \
                   [bsg_list_diff $TESTING_SOURCE_FILES $SVERILOG_SOURCE_FILES] \

# testing library
bsg_create_library $::env(BSG_DESIGNS_TESTING_LIBRARY_NAME) \
                   $::env(BSG_DESIGNS_TESTING_LIBRARY)      \
                   [bsg_list_diff $TESTING_SOURCE_FILES $SVERILOG_SOURCE_FILES] \
                   $TESTING_INCLUDE_PATHS
