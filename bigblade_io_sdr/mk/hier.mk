ifeq ($(EAST_NOT_WEST),1)
  export TOP_HIER_BLOCK := bsg_manycore_link_ruche_to_sdr_east
else
  export TOP_HIER_BLOCK := bsg_manycore_link_ruche_to_sdr_west
  export EAST_NOT_WEST  := 0
endif
export MID_HIER_BLOCKS :=
export BOT_HIER_BLOCKS :=
