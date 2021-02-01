
# Top hierarchical block design name. This variable is not a list and should be just a single design
# name. Used in both flat and hierarchical design flows.
export TOP_HIER_BLOCK := bsg_chip

# Intermediate hierarchical blocks. This is a list of all non-toplevel blocks that have sub-block
# dependancies. Only used in hierarchical design flows.
export MID_HIER_BLOCKS :=

# Bottom hierarchical blocks. This is a lost of all non-toplevel blocks that have no sub-block
# dependancies (ie. leaf blocks). Only used in hierarchical design flows.
export BOT_HIER_BLOCKS :=

# TODO -- This is experimental right now
export ETM_BLOCKS := bsg_router_tile,$(BSG_DESIGNS_TARGET_DIR)/../router_tile_etm

