
# Top hierarchical block design name. This variable is not a list and should be just a single design
# name. Used in both flat and hierarchical design flows.
export TOP_HIER_BLOCK := bsg_chip_block

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
export ETM_BLOCKS := bsg_chip_noc_mem_link,$(BSG_DESIGNS_TARGET_DIR)/../bigblade_noc_mem_link/bsg_14/current_build
export ETM_BLOCKS += bsg_chip_noc_io_link,$(BSG_DESIGNS_TARGET_DIR)/../bigblade_noc_io_link/bsg_14/current_build

export ADDITIONAL_LIBS += bsg_chip_io_link_ddr,$(BSG_DESIGNS_TARGET_DIR)/../bigblade_io_link_ddr/bsg_14/current_build
