set hb_bigblade_netlists_dir $::env(HB_BIGBLADE_NETLISTS_DIR)

set BIGBLADE_NOC_IO_LINK_SOURCE_FILES [join "
  $bsg_designs_target_dir/../bigblade_noc_io_link/v/bsg_chip_noc_io_link.v
"]
