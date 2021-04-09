
set HARD_INCLUDE_PATHS [join "
"]

set HARD_SWAP_FILELIST [join  "
  $basejump_stl_dir/hard/gf_14/bsg_async/bsg_launch_sync_sync.v
  $basejump_stl_dir/hard/gf_14/bsg_async/bsg_sync_sync.v
  $basejump_stl_dir/hard/gf_14/bsg_clk_gen/bsg_clk_gen_osc.v
  $basejump_stl_dir/hard/gf_14/bsg_misc/bsg_mux.v
"]

set NETLIST_SOURCE_FILES [join "
  $basejump_stl_dir/hard/gf_14/bsg_clk_gen/bsg_rp_clk_gen_fine_delay_tuner.v
  $basejump_stl_dir/hard/gf_14/bsg_clk_gen/bsg_rp_clk_gen_coarse_delay_tuner.v
  $basejump_stl_dir/hard/gf_14/bsg_clk_gen/bsg_rp_clk_gen_atomic_delay_tuner.v
"]

set NEW_SVERILOG_SOURCE_FILES [join "
"]

