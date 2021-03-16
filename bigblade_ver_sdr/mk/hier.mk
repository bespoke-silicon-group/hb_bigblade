ifeq ($(SOUTH_NOT_NORTH),1)
  export TOP_HIER_BLOCK := bsg_manycore_link_to_sdr_south
else
  export TOP_HIER_BLOCK := bsg_manycore_link_to_sdr_north
  export SOUTH_NOT_NORTH  := 0
endif
export MID_HIER_BLOCKS :=
export BOT_HIER_BLOCKS :=
