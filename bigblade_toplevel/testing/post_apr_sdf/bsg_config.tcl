source ../tcl/bsg_config_util.tcl

# scripts for creating filelist and library
#source $::env(BSG_TESTING_COMMON_DIR)/bsg_vcs_create_filelist_library.tcl

# chip source (rtl) files and include paths list
source $::env(BSG_DESIGNS_TARGET_DIR)/testing/tcl/chip_filelist.tcl
source $::env(BSG_DESIGNS_TARGET_DIR)/testing/tcl/chip_include.tcl

# testing source (rtl) files and include paths list
source $::env(BSG_DESIGNS_TARGET_DIR)/testing/tcl/gateway_filelist.tcl
source $::env(BSG_DESIGNS_TARGET_DIR)/testing/tcl/gateway_include.tcl

source $::env(HB_BIGBLADE_NETLISTS_DIR)/pdk_stdlib_filelist.tcl
set SVERILOG_SOURCE_FILES [concat $SVERILOG_SOURCE_FILES $PDK_SOURCE_FILES]


set bsg_designs_dir        $::env(BSG_DESIGNS_DIR)

##################################
# bsg_manycore_tile source files #
##################################
# comment this out to use post_synth netlist
#source $::env(HB_BIGBLADE_NETLISTS_DIR)/bsg_manycore_tile-post-synth_filelist.tcl
# comment this out to use rtl
#source $::env(BSG_DESIGNS_TARGET_DIR)/testing/tcl/bsg_manycore_tile-rtl_filelist.tcl

set SRAM_FILES [ join "
  $bsg_designs_dir/bigblade_toplevel/bsg_14/.pdk_prep/memgen/gf14_1rw_d1024_w32_m4_byte/gf14_1rw_d1024_w32_m4_byte.v
  $bsg_designs_dir/bigblade_toplevel/bsg_14/.pdk_prep/memgen/gf14_1rw_d1024_w46_m4/gf14_1rw_d1024_w46_m4.v
  $bsg_designs_dir/bigblade_toplevel/bsg_14/.pdk_prep/memgen/gf14_1rw_d512_w128_m2_byte/gf14_1rw_d512_w128_m2_byte.v
  $bsg_designs_dir/bigblade_toplevel/bsg_14/.pdk_prep/memgen/gf14_1rw_d64_w7_m4_bit/gf14_1rw_d64_w7_m4_bit.v
  $bsg_designs_dir/bigblade_toplevel/bsg_14/.pdk_prep/memgen/gf14_1rw_d64_w80_m2_bit/gf14_1rw_d64_w80_m2_bit.v
"]
set SVERILOG_SOURCE_FILES [concat $SVERILOG_SOURCE_FILES $SRAM_FILES]

set POST_APR_SOURCE_FILES [join "
  $bsg_designs_dir/bigblade_manycore_tile/bsg_14/current_build/pnr/bsg_manycore_tile_compute_ruche/results/bsg_manycore_tile_compute_ruche_chip_finish.v.gz
  $bsg_designs_dir/bigblade_vcache/bsg_14/current_build/pnr/bsg_manycore_tile_vcache/results/bsg_manycore_tile_vcache_chip_finish.v.gz
  $bsg_designs_dir/bigblade_manycore_tile_array_16x2/bsg_14/current_build/pnr/bsg_manycore_tile_compute_array_ruche/results/bsg_manycore_tile_compute_array_ruche_chip_finish.v.gz
  $bsg_designs_dir/bigblade_vcache_array_16x1/bsg_14/current_build/pnr/bsg_manycore_tile_vcache_array/results/bsg_manycore_tile_vcache_array_chip_finish.v.gz

  $bsg_designs_dir/bsg_manycore_link_to_sdr_north/bsg_14/current_build/pnr/bsg_manycore_link_to_sdr_north/results/bsg_manycore_link_to_sdr_north_chip_finish.v.gz
  $bsg_designs_dir/bsg_manycore_link_to_sdr_south/bsg_14/current_build/pnr/bsg_manycore_link_to_sdr_south/results/bsg_manycore_link_to_sdr_south_chip_finish.v.gz
  $bsg_designs_dir/bsg_manycore_link_to_sdr_north_row/bsg_14/current_build/pnr/bsg_manycore_link_to_sdr_north_row/results/bsg_manycore_link_to_sdr_north_row_chip_finish.v.gz
  $bsg_designs_dir/bsg_manycore_link_to_sdr_south_row/bsg_14/current_build/pnr/bsg_manycore_link_to_sdr_south_row/results/bsg_manycore_link_to_sdr_south_row_chip_finish.v.gz

  $bsg_designs_dir/bsg_manycore_link_ruche_to_sdr_east/bsg_14/current_build/pnr/bsg_manycore_link_ruche_to_sdr_east/results/bsg_manycore_link_ruche_to_sdr_east_chip_finish.v.gz
  $bsg_designs_dir/bsg_manycore_link_ruche_to_sdr_west/bsg_14/current_build/pnr/bsg_manycore_link_ruche_to_sdr_west/results/bsg_manycore_link_ruche_to_sdr_west_chip_finish.v.gz

  $bsg_designs_dir/bsg_manycore_link_wh_to_sdr_ne/bsg_14/current_build/pnr/bsg_manycore_link_wh_to_sdr_ne/results/bsg_manycore_link_wh_to_sdr_ne_chip_finish.v.gz
  $bsg_designs_dir/bsg_manycore_link_wh_to_sdr_nw/bsg_14/current_build/pnr/bsg_manycore_link_wh_to_sdr_nw/results/bsg_manycore_link_wh_to_sdr_nw_chip_finish.v.gz
  $bsg_designs_dir/bsg_manycore_link_wh_to_sdr_se/bsg_14/current_build/pnr/bsg_manycore_link_wh_to_sdr_se/results/bsg_manycore_link_wh_to_sdr_se_chip_finish.v.gz
  $bsg_designs_dir/bsg_manycore_link_wh_to_sdr_sw/bsg_14/current_build/pnr/bsg_manycore_link_wh_to_sdr_sw/results/bsg_manycore_link_wh_to_sdr_sw_chip_finish.v.gz

  $bsg_designs_dir/bigblade_pod_row/bsg_14/current_build/pnr/bsg_manycore_pod_row_sdr/results/bsg_manycore_pod_row_sdr_chip_finish.v.gz
"]

set SVERILOG_SOURCE_FILES [concat $SVERILOG_SOURCE_FILES $POST_APR_SOURCE_FILES]

######################################
# bsg_manycore_link_sdr source files #
######################################
# comment this out to use post_synth netlist
#source $::env(HB_BIGBLADE_NETLISTS_DIR)/bsg_manycore_link_sdr-post-synth_filelist.tcl
# comment this out to use rtl
#source $::env(BSG_DESIGNS_TARGET_DIR)/testing/tcl/bsg_manycore_link_sdr-rtl_filelist.tcl

#set SVERILOG_SOURCE_FILES [concat $SVERILOG_SOURCE_FILES $BSG_MANYCORE_LINK_SDR_SOURCE_FILES]


#####################################
# bigblade_io_link_ddr source files #
#####################################
# comment this out to use post_synth netlist
#source $::env(HB_BIGBLADE_NETLISTS_DIR)/bigblade_io_link_ddr-post-synth_filelist.tcl
# comment this out to use rtl
source $::env(BSG_DESIGNS_TARGET_DIR)/testing/tcl/bigblade_io_link_ddr-rtl_filelist.tcl

set SVERILOG_SOURCE_FILES [concat $SVERILOG_SOURCE_FILES $BIGBLADE_IO_LINK_DDR_SOURCE_FILES]

#####################################
# bigblade_noc_io_link source files #
#####################################
# comment this out to use post_synth netlist
#source $::env(HB_BIGBLADE_NETLISTS_DIR)/bigblade_noc_io_link-post-synth_filelist.tcl
# comment this out to use rtl
source $::env(BSG_DESIGNS_TARGET_DIR)/testing/tcl/bigblade_noc_io_link-rtl_filelist.tcl

set SVERILOG_SOURCE_FILES [concat $SVERILOG_SOURCE_FILES $BIGBLADE_NOC_IO_LINK_SOURCE_FILES]


######################################
# bigblade_noc_mem_link source files #
######################################
# comment this out to use post_synth netlist
#source $::env(HB_BIGBLADE_NETLISTS_DIR)/bigblade_noc_mem_link-post-synth_filelist.tcl
# comment this out to use rtl
source $::env(BSG_DESIGNS_TARGET_DIR)/testing/tcl/bigblade_noc_mem_link-rtl_filelist.tcl

set SVERILOG_SOURCE_FILES [concat $SVERILOG_SOURCE_FILES $BIGBLADE_NOC_MEM_LINK_SOURCE_FILES]


######################################
# bigblade_clk_gen source files      #
######################################
# comment this out to use post_synth netlist
#source $::env(HB_BIGBLADE_NETLISTS_DIR)/bigblade_clk_gen-post-synth_filelist.tcl
# comment this out to use rtl
source $::env(BSG_DESIGNS_TARGET_DIR)/testing/tcl/bigblade_clk_gen-rtl_filelist.tcl

set SVERILOG_SOURCE_FILES [concat $SVERILOG_SOURCE_FILES $BIGBLADE_CLK_GEN_SOURCE_FILES]

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
