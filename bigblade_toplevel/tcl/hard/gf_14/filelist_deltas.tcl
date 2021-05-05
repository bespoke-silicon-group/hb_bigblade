set basejump_stl_dir $::env(BASEJUMP_STL_DIR)
set bsg_designs_target_dir $::env(BSG_DESIGNS_TARGET_DIR)

set HARD_INCLUDE_PATHS [join "
  $basejump_stl_dir/hard/gf_14/bsg_mem/
"]

set HARD_SWAP_FILELIST [join "
"]

set NETLIST_SOURCE_FILES [join "
"]

set NEW_SVERILOG_SOURCE_FILES [join "
"]
