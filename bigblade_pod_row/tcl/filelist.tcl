set  basejump_stl_dir        $::env(BASEJUMP_STL_DIR)
set  bsg_manycore_dir        $::env(BSG_MANYCORE_DIR)
set  bsg_designs_target_dir  $::env(BSG_DESIGNS_TARGET_DIR)
set  bsg_packaging_dir       $::env(BSG_PACKAGING_DIR)
set  bsg_package             $::env(BSG_PACKAGE)
set  bsg_pinout              $::env(BSG_PINOUT)
set  bsg_padmapping          $::env(BSG_PADMAPPING)

set SVERILOG_INCLUDE_PATHS [join "
  $basejump_stl_dir/bsg_misc
  $basejump_stl_dir/bsg_noc
  $basejump_stl_dir/bsg_tag
"]

set SVERILOG_PACKAGE_FILES [join "
  $basejump_stl_dir/bsg_noc/bsg_noc_pkg.v
  $basejump_stl_dir/bsg_tag/bsg_tag_pkg.v
  $bsg_manycore_dir/v/bsg_manycore_pkg.v
  $bsg_designs_target_dir/../common/v/bsg_chip_pkg.v
"]

set SVERILOG_SOURCE_FILES [join "
  $SVERILOG_PACKAGE_FILES
  $basejump_stl_dir/bsg_async/bsg_launch_sync_sync.v
  $basejump_stl_dir/bsg_async/bsg_sync_sync.v
  $basejump_stl_dir/bsg_misc/bsg_buf.v
  $basejump_stl_dir/bsg_misc/bsg_dff.v
  $basejump_stl_dir/bsg_misc/bsg_dff_chain.v
  $basejump_stl_dir/bsg_misc/bsg_dff_reset_en.v
  $basejump_stl_dir/bsg_misc/bsg_inv.v
  $basejump_stl_dir/bsg_misc/bsg_mux2_gatestack.v
  $basejump_stl_dir/bsg_tag/bsg_tag_client.v
  $bsg_manycore_dir/v/bsg_manycore_pod_ruche.v
  $bsg_manycore_dir/v/bsg_manycore_pod_ruche_row.v
  $bsg_designs_target_dir/v/bsg_manycore_pod_row_sdr.v
"]
