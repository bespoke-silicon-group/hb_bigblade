#------------------------------------------------------------
# Do NOT arbitrarily change the order of files. Some module
# and macro definitions may be needed by the subsequent files
#------------------------------------------------------------

set basejump_stl_dir       $::env(BASEJUMP_STL_DIR)
set bsg_manycore_dir       $::env(BSG_MANYCORE_DIR)
set bsg_designs_dir        $::env(BSG_DESIGNS_DIR)
set bsg_designs_target_dir $::env(BSG_DESIGNS_TARGET_DIR)
set bsg_packaging_dir      $::env(BSG_PACKAGING_DIR)

set bsg_package       $::env(BSG_PACKAGE)
set bsg_pinout        $::env(BSG_PINOUT)
set bsg_padmapping    $::env(BSG_PADMAPPING)

set BSG_MANYCORE_LINK_SDR_SOURCE_FILES [join "
  $bsg_designs_target_dir/../common/sdr/sdr_horizontal/v/bsg_manycore_link_ruche_to_sdr_west.v
  $bsg_designs_target_dir/../common/sdr/sdr_horizontal/v/bsg_manycore_link_ruche_to_sdr_east.v
  $bsg_designs_target_dir/../common/sdr/sdr_vertical/v/bsg_manycore_link_to_sdr_north.v
  $bsg_designs_target_dir/../common/sdr/sdr_vertical/v/bsg_manycore_link_to_sdr_south.v
  $bsg_designs_target_dir/../common/sdr/sdr_corner/v/bsg_manycore_link_wh_to_sdr_ne.v
  $bsg_designs_target_dir/../common/sdr/sdr_corner/v/bsg_manycore_link_wh_to_sdr_nw.v
  $bsg_designs_target_dir/../common/sdr/sdr_corner/v/bsg_manycore_link_wh_to_sdr_sw.v
  $bsg_designs_target_dir/../common/sdr/sdr_corner/v/bsg_manycore_link_wh_to_sdr_se.v
"]
