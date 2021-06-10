
# Top hierarchical block design name. This variable is not a list and should be just a single design
# name. Used in both flat and hierarchical design flows.
export TOP_HIER_BLOCK := bsg_chip

# Intermediate hierarchical blocks. This is a list of all non-toplevel blocks that have sub-block
# dependancies. Only used in hierarchical design flows.
export MID_HIER_BLOCKS :=

# Bottom hierarchical blocks. This is a lost of all non-toplevel blocks that have no sub-block
# dependancies (ie. leaf blocks). Only used in hierarchical design flows.
export BOT_HIER_BLOCKS :=

# ETM (hard macro) hierarchical blocks. The blocks are a space separated list elements whose format
# is <design_name>,<build_dir>. These blocks should be previously built in a separate bsg_design
# directory. Note: this does not include hardened SRAMs and RFs. Can be used in both flat and
# hierarchical design flows.
#export ETM_BLOCKS := bsg_chip_block,$(BSG_DESIGNS_TARGET_DIR)/../bigblade_toplevel_block_rc0/bsg_14/current_build
#
#export ADDITIONAL_LIBS := bsg_chip_io_link_ddr,$(BSG_DESIGNS_TARGET_DIR)/../bigblade_io_link_ddr/bsg_14/current_build
#export ADDITIONAL_LIBS += bsg_chip_noc_mem_link,$(BSG_DESIGNS_TARGET_DIR)/../bigblade_noc_mem_link/bsg_14/current_build
#export ADDITIONAL_LIBS += bsg_chip_noc_io_link,$(BSG_DESIGNS_TARGET_DIR)/../bigblade_noc_io_link/bsg_14/current_build
#export ADDITIONAL_LIBS += bsg_manycore_pod_row_sdr,$(BSG_DESIGNS_TARGET_DIR)/../bigblade_pod_row/bsg_14/current_build
#export ADDITIONAL_LIBS += bigblade_clk_gen,$(BSG_DESIGNS_TARGET_DIR)/../bigblade_clk_gen/bsg_14/current_build
#export ADDITIONAL_LIBS += bsg_blackparrot_halfpod,$(BSG_DESIGNS_TARGET_DIR)/../bigblade_bp_dummy/bsg_14/current_build
#export ADDITIONAL_LIBS += brg_cgra_pod,$(BSG_DESIGNS_TARGET_DIR)/../bigblade_cgra_dummy/bsg_14/current_build
#
#export ADDITIONAL_LIBS += bsg_manycore_link_wh_to_sdr_nw,$(BSG_DESIGNS_TARGET_DIR)/../bsg_manycore_link_wh_to_sdr_nw/bsg_14/current_build
#export ADDITIONAL_LIBS += bsg_manycore_link_wh_to_sdr_ne,$(BSG_DESIGNS_TARGET_DIR)/../bsg_manycore_link_wh_to_sdr_ne/bsg_14/current_build
#export ADDITIONAL_LIBS += bsg_manycore_link_wh_to_sdr_sw,$(BSG_DESIGNS_TARGET_DIR)/../bsg_manycore_link_wh_to_sdr_sw/bsg_14/current_build
#export ADDITIONAL_LIBS += bsg_manycore_link_wh_to_sdr_se,$(BSG_DESIGNS_TARGET_DIR)/../bsg_manycore_link_wh_to_sdr_se/bsg_14/current_build
#export ADDITIONAL_LIBS += bsg_manycore_link_ruche_to_sdr_west,$(BSG_DESIGNS_TARGET_DIR)/../bsg_manycore_link_ruche_to_sdr_west/bsg_14/current_build
#export ADDITIONAL_LIBS += bsg_manycore_link_ruche_to_sdr_east,$(BSG_DESIGNS_TARGET_DIR)/../bsg_manycore_link_ruche_to_sdr_east/bsg_14/current_build
#export ADDITIONAL_LIBS += bsg_manycore_tile_compute_array_ruche,$(BSG_DESIGNS_TARGET_DIR)/../bigblade_manycore_tile_array_16x2/bsg_14/current_build
#export ADDITIONAL_LIBS += bsg_manycore_tile_vcache_array,$(BSG_DESIGNS_TARGET_DIR)/../bigblade_vcache_array_16x1/bsg_14/current_build
#export ADDITIONAL_LIBS += bsg_manycore_link_to_sdr_north_row,$(BSG_DESIGNS_TARGET_DIR)/../bsg_manycore_link_to_sdr_north_row/bsg_14/current_build
#export ADDITIONAL_LIBS += bsg_manycore_link_to_sdr_south_row,$(BSG_DESIGNS_TARGET_DIR)/../bsg_manycore_link_to_sdr_south_row/bsg_14/current_build
#
#export ADDITIONAL_LIBS += bsg_manycore_tile_vcache,$(BSG_DESIGNS_TARGET_DIR)/../bigblade_vcache/bsg_14/current_build
#export ADDITIONAL_LIBS += bsg_manycore_tile_compute_ruche,$(BSG_DESIGNS_TARGET_DIR)/../bigblade_manycore_tile/bsg_14/current_build
#export ADDITIONAL_LIBS += bsg_manycore_link_to_sdr_north,$(BSG_DESIGNS_TARGET_DIR)/../bsg_manycore_link_to_sdr_north/bsg_14/current_build
#export ADDITIONAL_LIBS += bsg_manycore_link_to_sdr_south,$(BSG_DESIGNS_TARGET_DIR)/../bsg_manycore_link_to_sdr_south/bsg_14/current_build
