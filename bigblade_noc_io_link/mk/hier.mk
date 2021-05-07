export TOP_HIER_BLOCK  := bsg_chip_noc_io_link
export MID_HIER_BLOCKS :=
export BOT_HIER_BLOCKS :=

# ETM (hard macro) hierarchical blocks. The blocks are a space separated list elements whose format
# is <design_name>,<build_dir>. These blocks should be previously built in a separate bsg_design
# directory. Note: this does not include hardened SRAMs and RFs. Can be used in both flat and
# hierarchical design flows.
export ETM_BLOCKS := bsg_chip_io_link_ddr,$(BSG_DESIGNS_TARGET_DIR)/../bigblade_io_link_ddr/bsg_14/current_build