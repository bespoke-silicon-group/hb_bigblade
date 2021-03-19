ifeq ($(EAST_NOT_WEST),1)
  ifeq ($(SOUTH_NOT_NORTH),1)
    export TOP_HIER_BLOCK := bsg_manycore_link_wh_to_sdr_se
  else
    export TOP_HIER_BLOCK := bsg_manycore_link_wh_to_sdr_ne
    export SOUTH_NOT_NORTH := 0
  endif
else
  ifeq ($(SOUTH_NOT_NORTH),1)
    export TOP_HIER_BLOCK := bsg_manycore_link_wh_to_sdr_sw
  else
    export TOP_HIER_BLOCK := bsg_manycore_link_wh_to_sdr_nw
    export SOUTH_NOT_NORTH := 0
  endif
  export EAST_NOT_WEST := 0
endif
export MID_HIER_BLOCKS :=
export BOT_HIER_BLOCKS :=
