
# Top hierarchical block design name. This variable is not a list and should be just a single design
# name. Used in both flat and hierarchical design flows.
export TOP_HIER_BLOCK :=bsg_manycore_link_to_sdr_north_row

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
export ETM_BLOCKS := bsg_manycore_link_to_sdr_north,$(BSG_DESIGNS_TARGET_DIR)/../bsg_manycore_link_to_sdr_north/bsg_14/current_build

