
set basejump_stl_dir       $::env(BASEJUMP_STL_DIR)
set bsg_designs_target_dir $::env(BSG_DESIGNS_TARGET_DIR)

# list of files to replace
set HARD_SWAP_FILELIST [join "
  $basejump_stl_dir/hard/gf_14/bsg_misc/bsg_mux.v
  $basejump_stl_dir/hard/gf_14/bsg_link/bsg_link_osdr_phy.v
  $basejump_stl_dir/hard/gf_14/bsg_link/bsg_link_isdr_phy.v
  $basejump_stl_dir/hard/gf_14/bsg_async/bsg_sync_sync.v
  $basejump_stl_dir/hard/gf_14/bsg_async/bsg_launch_sync_sync.v
"]


set NETLIST_SOURCE_FILES [join "
"]

set NEW_SVERILOG_SOURCE_FILES [join "
"]

